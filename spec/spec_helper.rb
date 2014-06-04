$:.unshift File.expand_path('..', __FILE__)
$:.unshift File.expand_path('../lib', __FILE__)

require 'rubygems'
require 'bundler/setup'
Bundler.setup

require 'simplecov'
SimpleCov.start do
	add_filter 'spec/'
end

require 'trollop'
require 'argumental'

def capture_stdout(&block)
  original_stdout = $stdout
  $stdout = fake = StringIO.new
  begin
    yield
  ensure
    $stdout = original_stdout
  end
  fake.string
end

RSpec.configure do |config|
	config.before(:each){
		# Don't need anything yet.
	}
end


