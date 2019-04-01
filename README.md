# Concurrent-task
Run your code in parallel easily

## Install

Add this line to your application's Gemfile:

```bash
gem install concurrent_task
```

## ⚠️ Warning ⚠️
this gem is a work in progress, use at your own risk.

## Usage

Simple task async

```ruby
class SumTask < ConcurrentTask::Base
  # state initial
  scope to_process: nil, data: []

  # proccess data
  init do |this|
    this.scope.update do |scope|
      scope[:to_process] = this.subject.length
      scope
    end

    this.subject.each do |data|
      this.perform(:sum, data)
    end
  end

  on_process :sum do |this, data|
    new_value = data + 1

    this.scope.update do |scope|
      scope[:to_process] -= 1
      scope[:data].push(new_value)
      scope
    end
  end

  # the task stop when this condition is true
  finish_when { |scope| scope[:to_process].zero? }
end

result = SumTask.new { [1, 2, 3] }.run

# result: [2, 3, 4]
```



## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jdaviderb/concurrent_task. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ConcurrentTask project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/jdaviderb/concurrent_task/blob/master/CODE_OF_CONDUCT.md).
