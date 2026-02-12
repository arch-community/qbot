# frozen_string_literal: true

module Queries
  ##
  # Presenter methods for Queries module embeds and formatting
  module Presenters
    ##
    # Format a query as a field for embed display
    def self.query_field(query)
      query => { id:, created_at:, text: }

      name = QBot::Helpers.t('queries.oq.entry-name', id, query.user.distinct, created_at)

      { name:, value: text }
    end
  end
end
