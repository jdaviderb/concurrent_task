# frozen_string_literal: true

module ConcurrentTask
  class Base
    class << self
      def init
        @init ||= ->(this) { yield(this) }
      end

      def events
        @events ||= ::ConcurrentTask::Scope.new([])
      end

      def on_process(name, workers: 10)
        events.swap do |value|
          task = ::ConcurrentTask::TaskQueueManager.new(workers: workers)
          value.push(
            name: name,
            handler: lambda do |this, data|
              task.perform { yield(this, data) }
            end
          )
        end
      end

      def finish_when
        @finish_when ||= ->(scope) { yield(scope.value) }
      end

      def scope(scopes = nil)
        return @scope if scopes.nil?

        atom_initial = block_given? ? yield : scopes
        @scope ||= ::ConcurrentTask::Scope.new(atom_initial)
      end
    end

    def initialize
      @data = -> { yield } if block_given?
    end

    def subject
      @subject_atom ||= ::ConcurrentTask::Scope.new(@data.call)
      @subject_atom.value
    end

    def perform(name, data)
      events.value.each do |event|
        event[:handler].call(self, data) if event[:name] == name
      end
    end

    def events
      @events ||= ::ConcurrentTask::Scope.new(self.class.events.value)
    end

    def scope
      @scope ||= ::ConcurrentTask::Scope.new(self.class.scope.value)
    end

    def run
      self.class.init.clone.call(self)

      loop do
        sleep(0.1)
        break if self.class.finish_when.call(scope)
      end

      scope.value
    end
  end
end
