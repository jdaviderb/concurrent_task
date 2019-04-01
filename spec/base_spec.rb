require 'spec_helper'

RSpec.describe ConcurrentTask::Base do
  let(:task_value) { subject.run }

  subject do
    class Subject < ConcurrentTask::Base
      scope to_process: 0, processed: 0, data: []

      init do |this|
        this.scope.update do |scope|
          scope[:to_process] = this.subject.length
          scope
        end

        this.subject.each { |data| this.perform(:test, data) }
      end

      on_process :test do |this, data|
        new_value = data + 1

        this.scope.update do |scope|
          scope[:processed] += 1
          scope[:data].push(new_value)
          scope
        end
      end

      finish_when { |scope| scope[:to_process] == scope[:processed] }
    end

    Subject.new { [1, 2, 3] }
  end

  it do
    expect(task_value[:processed]).to eq(3)
    expect(task_value[:to_process]).to eq(3)
    expect(task_value[:data]).to match_array([2, 3, 4])
  end
end
