$LOAD_PATH.push File.expand_path('../../lib/', __dir__)
require 'concurrent_task'

class TaskMap < ::ConcurrentTask::Base
  scope to_process: nil, data: nil

  def self.reduce(objects, memo)
    memo_scope = ::ConcurrentTask::Scope.new(memo)
    new { [objects, ->(object) { yield(memo_scope, object) }] }
      .run[:data]
      .value
  end

  init do |this|
    this.scope.update do |scope|
      scope[:to_process] = this.subject[0].length
      scope
    end

    this.subject[0].each do |object|
      this.perform(:map, object)
    end
  end

  on_process :map do |this, object|
    new_value = this.subject[1].call(object)

    this.scope.update do |scope|
      scope[:to_process] -= 1
      scope[:data] = new_value
      scope
    end
  end

  finish_when { |scope| scope[:to_process].zero? }
end

result = TaskMap.reduce([1, 2, 3, 4, 5, 6], 0) do |memo, number|
  memo.update { |old_value| old_value + number }
  memo
end

puts result
