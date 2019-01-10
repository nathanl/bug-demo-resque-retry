class SuccessfulJob
  @queue = :testing_successful

  # Perform that does nothing
  def self.perform(*args)
    # perform heavy lifting here.
  end
end

class FailingJob
  @queue = :testing_failure

  # Perform that raises an exception
  def self.perform(*args)
    raise 'this job is expected to fail!'
  end
end

class FailingWithRetryJob
  extend Resque::Plugins::Retry

  @queue = :testing_failure
  @retry_limit = 4
  @retry_delay = 2

  # Perform that raises an exception, but we will retry the job on failure
  def self.perform(some_hash)
    puts "AAA Redis Retry Key #{redis_retry_key(some_hash)}"
    dup_before_mutate = false # toggle to compare
    if dup_before_mutate
      some_hash = some_hash.dup
      some_hash['some_key'] = 'some_val'
    else
      # Mutate the arg hash directly. This will cause an orphaned retry job to
      # be left in Redis, visible in redis-cli with  'keys
      # resque:resque-retry*'
      some_hash['some_key'] = 'some_val'
    end
    raise 'this job is expected to fail! but it will retry =)'
  end
end
