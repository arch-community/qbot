# frozen_string_literal: true

require './lib/youtube'

# Music Bot
module Music # rubocop: disable Metrics/ModuleLength, Style/CommentedKeyword
  extend Discordrb::Commands::CommandContainer

  # Now playing list
  @np = {}

  # Play queues
  @queues = Hash.new { |hash, key| hash[key] = Queue.new }

  @threads = {}
  # rubocop: disable Metrics/AbcSize, Metrics/MethodLength
  def self.play_thread(id, queue)
    @threads[queue] = Thread.new do
      v = nil
      loop do
        # Wait for the voicebot to initialize
        until v
          v = QBot.bot.voice(id)
          sleep 1
        end

        while (fn, info = queue.pop)
          # Play the next queued track
          Music.np[id] = info.fulltitle || info.url
          v.play_file(fn)
          Music.np[id] = nil

          # If there is no more music, disconnect and clear the voicebot
          next unless queue.empty?

          v.destroy
          v = nil
          break
        end
      end
    end
  end
  # rubocop: enable Metrics/AbcSize, Metrics/MethodLength

  def self.init_server(server)
    play_thread server.id, @queues[server.id]
  end

  class << self
    attr_accessor :queues, :np
  end

  # Voice functionality

  command :join, {
    help_available: true,
    usage: '.join',
    min_args: 0,
    max_args: 0
  } do |event|
    vc = event.author.voice_channel
    if vc
      event.bot.voice_connect(vc)
      embed t('music.join.success', vc.mention)
    else
      embed t('music.join.not-in-voice')
    end
  end

  command :play, {
    help_available: true,
    usage: '.play <url>',
    min_args: 1
  } do |event, *args|
    # Join the channel if not joined already
    event.bot.execute_command(:join, event, []) unless event.bot.voice(event.server)

    url = args.join(' ')

    # Search YouTube if it's not a URL
    url = "ytsearch:#{url}" unless url =~ URI::DEFAULT_PARSER.make_regexp

    # Temporary file for the track based on a hash of its URL
    filename = "/tmp/amb-#{Digest::SHA256.hexdigest url}.opus"
    data_filename = "#{filename}.dat"

    info = nil
    # Download the track; get info
    if File.exist?(filename) && File.exist?(data_filename)
      info = Marshal.load(File.read(data_filename)) # rubocop: disable Security/MarshalLoad
    else
      event.respond t('music.play.downloading')
      info = YoutubeDL.download url, output: filename, extract_audio: true, audio_format: :opus
      File.write(data_filename, Marshal.dump(info))
    end

    # Add it to this server's queue
    Music.queues[event.server.id] << [filename, info]
    embed t('music.play.success', info.fulltitle || info.url)

    nil
  end

  command :yt, {
    help_available: true,
    description: 'Searches YouTube for a video to play',
    usage: '.yt <query>',
    min_args: 1
  } do |event, *args|
    # Get the search query
    query = args.join(' ')

    # Search YouTube
    results = YouTube.search(query)

    # Show the search results in the channel
    embed do |m|
      m.title = t('music.yt.results-title', query)
      m.description = t('music.yt.ping-with-number')
      m.fields = results.map.with_index do |r, idx|
        emoji = ":#{to_word(idx + 1)}:"

        desc = r.snippet.description
        truncated_desc = desc.size < 192 ? desc : "#{desc[0..191].chomp}..."

        {
          name: "#{emoji}  #{r.snippet.title}",
          value: truncated_desc + "\nhttps://youtu.be/#{r.id.video_id}"
        }
      end
    end

    # Get the user's response
    number = user_response(event)
    ytid = results[number - 1].id.video_id

    # Actually play the found video
    event.bot.execute_command(:play, event, [ytid])
  end

  command :pause, {
    help_available: true,
    usage: '.pause',
    min_args: 0,
    max_args: 0
  } do |event|
    event.bot.voice(event.server).pause
  end

  command :resume, {
    help_available: true,
    usage: '.pause',
    min_args: 0,
    max_args: 0
  } do |event|
    event.bot.voice(event.server).continue
  end

  command :stop, {
    help_available: true,
    usage: '.pause',
    min_args: 0,
    max_args: 0
  } do |event|
    Music.queues[event.server.id].clear
    event.bot.voice(event.server).stop_playing
  end

  command :skip, {
    help_available: true,
    usage: '.skip',
    min_args: 0,
    max_args: 0
  } do |event|
    event.bot.voice(event.server).stop_playing
    event.bot.execute_command(:np, event, [])
  end

  command :volume, {
    help_available: true,
    usage: '.volume <percentage>',
    min_args: 1,
    max_args: 1
  } do |event, vol_str|
    vol = vol_str.to_f

    # Allow for both 0-1 and percentages
    vol /= 100.0 if vol > 1

    event.bot.voice(event.server).volume = vol
  end

  command :seek, {
    help_available: true,
    usage: '.seek <time>',
    min_args: 1,
    max_args: 1
  } do |event, sec_str|
    sec = sec_str.to_i
    event.bot.voice(event.server).skip(sec)
  end

  command :np, {
    help_available: true,
    usage: '.np',
    min_args: 0,
    max_args: 0
  } do |event|
    embed do |m|
      m.title = t('music.np.title')
      m.description = Music.np[event.server.id] || t('music.np.nothing')
    end

    nil
  end
end

QBot.bot.ready do |e|
  e.bot.servers.each { |_id, server| Music.init_server server }
end
QBot.bot.server_create { Music.init_server _1.server }
