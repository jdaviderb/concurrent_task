$LOAD_PATH.push File.expand_path('../../lib/', __dir__)
require 'concurrent_task'
require 'net/http'
require 'json'

class HttpTask < ::ConcurrentTask::Base
  scope to_process: nil, data: []

  init do |this|
    this.scope.update do |scope|
      scope[:to_process] = this.subject.length
      scope
    end

    this.subject.each do |ip|
      this.perform(:get_ip_location, ip)
    end
  end

  on_process :get_ip_location do |this, ip|
    uri = URI("https://ipapi.co/#{ip}/json/")
    response = Net::HTTP.get_response(uri).body

    this.scope.update do |scope|
      scope[:to_process] -= 1
      scope[:data].push(JSON.parse(response))
      scope
    end
  end

  finish_when { |scope| scope[:to_process].zero? }
end

ips = [
  '8.8.8.8',
  '4.4.4.4',
  '1.1.1.1',
  '2.2.2.2',
  '7.7.7.7'
]

puts JSON.pretty_generate(HttpTask.new { ips }.run)
