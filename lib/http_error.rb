# frozen_string_literal: true

module HiringExercise
  # This is the only provider error type used by the exercise.
  class HttpError < StandardError
    attr_reader :status, :retry_after_s

    def initialize(status, retry_after_s: nil)
      @status = status
      @retry_after_s = retry_after_s
      super("Search provider returned HTTP #{status}")
    end
  end

  class StoreError < StandardError; end
end
