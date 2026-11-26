# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/quote_worker'
require_relative 'support/fakes'

class QuoteWorkerTest < Minitest::Test
  include HiringExercise

  def build_worker(*responses, store: FakeStore.new)
    @client = FakeClient.new(*responses)
    @store = store
    @events = FakeEvents.new
    @sleeper = FakeSleeper.new
    QuoteWorker.new(client: @client, store: @store, events: @events,
                    sleeper: @sleeper)
  end

  def test_success_without_retry
    result = { amount: 40, currency: 'EUR' }
    worker = build_worker(result)

    assert_equal result, worker.perform('request-1')
    assert_equal 1, @client.calls.length
    assert_equal 1, @store.calls
    assert_equal [[:quote_ready, 'request-1']], @events.records
    assert_empty @sleeper.delays
  end

  def test_recovers_from_one_503
    result = { amount: 40, currency: 'EUR' }
    worker = build_worker(HttpError.new(503), result)

    assert_equal result, worker.perform('request-2')
    assert_equal 2, @client.calls.length
    assert_equal [1.0], @sleeper.delays
    assert_equal 1, @store.calls
  end

  def test_permanent_failure_is_not_reported_as_success
    worker = build_worker(HttpError.new(503), HttpError.new(503),
                          HttpError.new(503))

    assert_raises(HttpError) { worker.perform('request-3') }
    assert_equal 3, @client.calls.length
    assert_equal [1.0, 2.0], @sleeper.delays
    assert_empty @store.writes
    assert_empty @events.records
  end

  def test_non_503_provider_error_is_not_retried
    result = { amount: 40, currency: 'EUR' }
    worker = build_worker(HttpError.new(400), result)

    error = assert_raises(HttpError) { worker.perform('request-5') }
    assert_equal 400, error.status
    assert_equal 1, @client.calls.length
    assert_empty @sleeper.delays
    assert_empty @store.writes
    assert_empty @events.records
  end

  def test_save_failure_does_not_restart_search_or_repeat_work
    result = { amount: 40, currency: 'EUR' }
    store = FakeStore.new(error_after_write: StoreError.new('db connection lost'))
    worker = build_worker(result, result, store: store)

    assert_raises(StoreError) { worker.perform('request-6') }
    assert_equal 1, @client.calls.length
    assert_equal [['request-6', result]], @store.writes
    assert_empty @events.records
    assert_empty @sleeper.delays
  end
end
