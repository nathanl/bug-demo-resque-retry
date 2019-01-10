## Description

This is a fork of [resque-retry](https://github.com/lantins/resque-retry), created to demonstrate a surprising behavior (possibly a bug). Specifically, if a job mutates the argument it is given, an orphaned retry job is created which is never cleaned up.

## Demo

```
cd examples/demo
rm dump.rdb; foreman start
```

In another terminal:

```
redis-cli -p 6379
```

In a browser, visit the demo interface at [http://localhost:9295/](http://localhost:9295/) and click "Create Failing Job with Retry".

Go back to the `redis-cli` window and run `keys resque:resque-retry*` repeatedly. You will see that two retry keys are created. One of the retry keys is cleaned up when the job reaches its retry limit, but the other is never cleaned up.

This is because in `examples/demo/jobs.rb`, `FailingWithRetryJob` has been modified to mutate its argument hash, causing this issue. If it instead calls `.dup` on its argument hash and mutates the copy, the additional retry key is not created.
