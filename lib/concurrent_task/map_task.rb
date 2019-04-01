# frozen_string_literal: true

module ConcurrentTask
  class MapTask < ::ConcurrentTask::Base
    scope to_process: nil, data: []

    def self.map(subject)
      new { [subject, ->(object) { yield(object) }] }.run[:data]
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
        scope[:data].push(new_value)
        scope
      end
    end

    finish_when { |scope| scope[:to_process].zero? }
  end
end
