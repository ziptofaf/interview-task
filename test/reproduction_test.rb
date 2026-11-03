# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/quote_worker'
require_relative 'support/fakes'

class ReproductionTest < Minitest::Test
  include HiringExercise

  # Deliberately fails on the proposed PR. Do not weaken this contract.
  def test_two_retries_means_three_total_provider_calls
    client = FakeClient.new(HttpError.new(503), HttpError.new(503),
                            HttpError.new(503))
    sleeper = FakeSleeper.new
    worker = QuoteWorker.new(client: client, store: FakeStore.new,
                             events: FakeEvents.new, sleeper: sleeper)

    assert_raises(HttpError) { worker.perform('request-4') }
    assert_equal 3, client.calls.length
    assert_equal [1.0, 2.0], sleeper.delays
  end
end
