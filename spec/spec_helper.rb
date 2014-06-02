$:.unshift File.expand_path('..', __FILE__)
$:.unshift File.expand_path('../../lib', __FILE__)

require 'rubygems'
require 'bundler/setup'
Bundler.setup

require 'simplecov'
SimpleCov.start do
	add_filter 'spec/'
end

require 'trollop'

RSpec.configure do |config|
	config.before(:each){
		# Don't need anything yet.
	}
end
