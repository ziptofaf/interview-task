# frozen_string_literal: true

require_relative 'http_error'

module HiringExercise
  class QuoteWorker
    RETRY_DELAYS = [1.0, 2.0].freeze

    def initialize(client:, store:, events:, sleeper:)
      @client = client
      @store = store
      @events = events
      @sleeper = sleeper
    end

    def perform(request_id)
      attempts = 0
      begin
        attempts += 1
        result = @client.search(request_id)
      rescue HttpError => e
        raise unless e.status == 503 && attempts <= RETRY_DELAYS.length

        @sleeper.call(RETRY_DELAYS[attempts - 1])
        retry
      end
      @store.save(request_id, result)
      @events.record(:quote_ready, request_id)
      result
    end
  end
end
