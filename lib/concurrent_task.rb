require 'concurrent_task/version'
require 'concurrent'
require 'concurrent_task/base'
require 'concurrent_task/scope'
require 'concurrent_task/task_queue_manager'
require 'concurrent_task/reduce_task'
require 'concurrent_task/map_task'

module ConcurrentTask
  def self.map(array)
    ::ConcurrentTask::MapTask.map(array) { |object| yield(object) }
  end

  def self.reduce(array, memo)
    ::ConcurrentTask::ReduceTask.reduce(array, memo) { |a, b| yield(a, b) }
  end
end
