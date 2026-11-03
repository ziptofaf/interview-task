# Part A - Quote retry exercise

A background job retrieves quote data from a search provider, saves the result, and records a completion event. Temporary HTTP 503 failures can leave some requests without a quote. A retry change has been proposed.

## Setup

Use Ruby 3.2 or newer with Minitest available. No Rails, database, Redis, cloud account, credentials, or network access is required.

From this folder run:

```sh
ruby --version
ruby bin/test
```

If Minitest is missing:

```sh
gem install minitest -v 5.20.0
```

The starter suite contains four tests. Three pass and one intentionally fails because it reproduces a problem in the proposed change.

## Files

- `baseline/quote_worker.rb` - implementation before the proposed change; reference only
- `lib/quote_worker.rb` - proposed implementation to review and fix
- `proposed.diff` - change from baseline to the proposed implementation
- `lib/http_error.rb` - supplied provider error type
- `test/` - starter tests and simple in-memory fakes
- `ANSWER.md` - short place to record your review verdict and comments

## Required behavior

1. Retry only HTTP 503 errors raised by the provider search.
2. Retry at most twice after the initial attempt: three provider calls total.
3. Use delays of 1 and 2 seconds before the first and second retries. The supplied fake sleeper records these delays; no real waiting occurs.
4. On success, save the result and record completion once, then return the original result. An empty result is valid.
5. Exhausted 503s, non-503 provider errors, and other errors must propagate.
6. A failure while saving or recording completion must not restart the provider search or repeat downstream work.
7. Preserve the existing public constructor and `perform(request_id)` interface. Add tests as needed; do not remove or weaken existing assertions.

## What to submit for Part A

- Your modified code and tests
- `ANSWER.md` with your merge/no-merge verdict and up to three prioritized review comments
- Test output or the command you used to run the tests

Keep the solution focused on the behavior above. No real queue, HTTP client, database, or cloud integration is required.
