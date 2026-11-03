# frozen_string_literal: true

require_relative '../lib/http_error'

module HiringExercise
  class QuoteWorker
    def initialize(client:, store:, events:, sleeper:)
      @client = client
      @store = store
      @events = events
      @sleeper = sleeper
    end

    def perform(request_id)
      result = @client.search(request_id)
      @store.save(request_id, result)
      @events.record(:quote_ready, request_id)
      result
    end
  end
end
