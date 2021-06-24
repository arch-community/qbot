# frozen_string_literal: true

# what the fuck did i write here
# rubocop: disable all
def split_message_n(msg, maxlen)
  return [] if msg.empty?

  lines = msg.lines

  tri = [*0..(lines.length - 1)].map { |i| lines.combination(i + 1).first }
  joined = tri.map(&:join)

  ideal = joined.max_by { |e| e.length > maxlen ? -1 : e.length }
  ideal_ary = ideal.length > maxlen ? ideal.chars.each_slice(maxlen).map(&:join) : [ideal]

  rest = msg[ideal.length..-1].strip
  return [] unless rest

  ideal_ary + split_message_n(rest, maxlen)
end
# rubocop: enable all

module Discordrb
  module Events
    # Wrap Respondable#send_message to allow using keyword arguments
    # rubocop: disable Metrics/ParameterLists
    module Respondable
      def respond_wrapped(content, tts: false, embed: nil, attachments: nil,
                          allowed_mentions: nil, message_reference: nil, components: nil)
        send_message(content, tts, embed, attachments, allowed_mentions, message_reference, components)
      end
    end
    # rubocop: enable Metrics/ParameterLists
  end
end

##
# Patches to the CommandBot class that make certain things work better
module QBotPatches
  def blockify(chunk, ric)
    if ric
      chunk.prepend '```' unless chunk&.start_with? '```'
      chunk << '```'      unless chunk&.end_with? '```'
    end
    chunk
  end

  def chunked_respond(event, result)
    rc = result&.chomp
    res_is_codeblock = rc&.start_with?('```') && rc&.end_with?('```')

    split_message_n(result, 1992).each do |chunk|
      event.respond blockify(chunk, res_is_codeblock)
    end
  end

  def drain_chain(chain, event)
    result = if @attributes[:advanced_functionality]
               Discordrb::Commands::CommandChain.new(chain, self).execute(event)
             else
               simple_execute(chain, event)
             end

    event.drain_into(result)
  end

  # rubocop: disable Metrics/MethodLength
  def execute_chain(chain, event)
    t = Thread.new do
      @event_threads << t
      Thread.current[:discordrb_name] = "ct-#{@current_thread += 1}"

      begin
        debug("Parsing command chain #{chain}")

        result = drain_chain(chain, event)

        if event.file
          event.send_file(event.file, caption: result)
        elsif !result&.empty?
          chunked_respond(event, result)
        end
      rescue StandardError => e
        log_exception(e)
      ensure
        @event_threads.delete(t)
      end
    end
  end
  # rubocop: enable Metrics/MethodLength
end

##
# StringIO derivative that presents a fake path to discordrb
class ImageStringIO < StringIO
  attr_accessor :path

  def initialize(string = '', mode = nil, path: 'image.png')
    @path = path
    super(string, mode)
  end
end
