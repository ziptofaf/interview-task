# frozen_string_literal: true

require_relative 'http_error'

module HiringExercise
  class QuoteWorker
    MAX_RETRIES = 2

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
        @store.save(request_id, result)
        @events.record(:quote_ready, request_id)
        result
      rescue StandardError
        raise if attempts >= MAX_RETRIES

        @sleeper.call(1.0)
        retry
      end
    end
  end
end
