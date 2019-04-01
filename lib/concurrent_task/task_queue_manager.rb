# frozen_string_literal: true

module ConcurrentTask
  class TaskQueueManager
    def initialize(workers: 10)
      @workers = workers
    end

    def perform
      return perform_later { yield } if tasks.value.length >= @workers

      tasks.update do |scope|
        promise = Concurrent::Promises.future { yield }

        promise.then { run_next!(promise) }

        scope.push(promise)
        scope
      end
    end

    private

    def perform_later
      tasks_enqueues.update do |scope|
        scope.push(-> { yield })
        scope
      end
    end

    def run_next!(completed_task)
      next_task = nil
      tasks_enqueues.update do |scope|
        next_task = scope.pop
        scope
      end

      tasks.update do |scope|
        scope.delete(completed_task)
        scope
      end

      perform { next_task.call } unless next_task.nil?
    end

    def tasks
      @tasks ||= ::ConcurrentTask::Scope.new([])
    end

    def tasks_enqueues
      @tasks_enqueues ||= ::ConcurrentTask::Scope.new([])
    end
  end
end
