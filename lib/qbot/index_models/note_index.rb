# frozen_string_literal: true

##
# Index for notes
class NoteIndex < ApplicationIndex
  def self.path
    File.join(QBot.options.state_dir, 'note-index')
  end

  def self.instantiate
    ngram = Tantiny::Tokenizer.new(:ngram, min: 1, max: 8)
    en_stemmer = Tantiny::Tokenizer.new(:stemmer)

    Tantiny::Index.new(path) do
      string :str_server_id
      text :username, tokenizer: ngram
      text :name, tokenizer: ngram
      text :text, tokenizer: en_stemmer
    end
  end

  def note_id_query(str, server_id: nil)
    q_username = smart_query(:username, str, boost: 0.5, prefix: false)
    q_name = smart_query(:name, str, boost: 5.0, prefix: false)
    q_text = smart_query(:text, str, boost: 1.1)

    if server_id
      q_server_id = term_query(:str_server_id, server_id.to_s)
      search(q_server_id & (q_username | q_name | q_text))
    else
      search(q_username | q_name | q_text)
    end
  end
end
