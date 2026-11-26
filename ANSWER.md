# Part A response

## Merge verdict
No merge

Main reason:

Current implementation rescues from EVERY standard error. Not just 503. A 400 class error, .save or .record failing could all trigger a retry. 

## Prioritized review comments
1. Changed method caught far too many exceptions. It wouldn't be limited to just 503s (service unavailable). Instead, it would catch anything that raises a StandardError - any kind of network error or even a missing method. Most importantly it could also cause save or record to be called more than once. It also causes unnecessary costs and delays (retrying on a method missing for instance definitely won't help, it just adds few seconds before we re-raise).
2. Off by 1 error - we didn't actually retry twice but just once. This is what caused a failing test. 
3. Delay was supposed to be 1s and then 2s. It was always 1. A relatively easy fix, we can just create a small array storing how long we should wait with each attempt.


## Notes / assumptions (optional)

We currently do nothing if .save returned false. It's not a failure according to specs and the code itself cannot return this value right now - so I am assuming it's not meant to act like ActiveRecord. Otherwise, we should probably do something like if @store.save and only record quote_ready event if saving succeeded.

One of the tests passed when it shouldn't (it didn't count number of repeats). Figured I should fix it instead of just making a new one.

retry_after_s - I see that http_error can return it. But the README explicitly wanted 1s and 2s delay. So I have used the provided values instead. We could utilize this value if present - but we would need to be aware on how long it takes. Since sleeping blocks a worker thread whereas a delay too long (eg. if we were told to retry in few minutes) could cause timeouts later in the user facing flow. 