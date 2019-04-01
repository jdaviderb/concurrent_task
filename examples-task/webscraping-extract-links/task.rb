$LOAD_PATH.push File.expand_path('../../lib/', __dir__)
require 'concurrent_task'
require 'json'
require 'mechanize'
class LinksScrapper < ::ConcurrentTask::Base
  scope to_process: nil, data: []

  init do |this|
    this.scope.update do |scope|
      scope[:to_process] = this.subject.length
      scope
    end

    this.subject.each do |link|
      this.perform(:get_links, link)
    end
  end

  on_process :get_links do |this, link|
    agent = Mechanize.new
    response = agent.get(link).search('a').map { |element| element['href'] }

    this.scope.update do |scope|
      scope[:to_process] -= 1
      scope[:data].concat(response)
      scope
    end
  end

  finish_when { |scope| scope[:to_process].zero? }
end

websites = [
  'https://www.google.co.ve/',
  'https://www.youtube.com/',
  'https://twitter.com/'
]

puts JSON.pretty_generate(LinksScrapper.new { websites }.run)
