# frozen_string_literal: true

require_relative '../../lib/http_error'

module HiringExercise
  class FakeClient
    attr_reader :calls

    def initialize(*responses)
      @responses = responses.dup
      @calls = []
    end

    def search(request_id)
      @calls << request_id
      raise 'No response left in FakeClient' if @responses.empty?

      response = @responses.shift
      raise response if response.is_a?(Exception)

      response
    end
  end

  class FakeStore
    attr_reader :writes, :calls

    # error_after_write mimics an uncertain acknowledgement: a write happened,
    # but the caller saw an error. It does NOT implement an idempotency policy.
    def initialize(error_after_write: nil)
      @writes = []
      @calls = 0
      @error_after_write = error_after_write
    end

    def save(request_id, result)
      @calls += 1
      @writes << [request_id, result]
      if @error_after_write
        error = @error_after_write
        @error_after_write = nil
        raise error
      end
      true
    end
  end

  class FakeEvents
    attr_reader :records

    def initialize(error: nil)
      @records = []
      @error = error
    end

    def record(event, request_id)
      @records << [event, request_id]
      if @error
        error = @error
        @error = nil
        raise error
      end
      true
    end
  end

  class FakeSleeper
    attr_reader :delays

    def initialize
      @delays = []
    end

    def call(seconds)
      @delays << seconds
    end
  end
end
