# include lib dir in LOAD_PATH for ruby 1.9 compatibility
lib = File.expand_path('../lib/', __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require 'argumental/version'
require 'rake'

Gem::Specification.new do |s|
    s.name        = 'argumental'
    s.version     = Argumental::VERSION
    s.date        = '2014-06-09'
    s.summary     = 'Extend trollop to add sub-commands'
    s.authors     = ['Anthony Roy', 'Robin Bowes']
    s.description = 'Easily create CLI apps with command suites'
    s.homepage    = 'https://github.com/antroy/argumental'
    s.email       = 'work@antroy.co.uk'
    s.files       = FileList[
        'lib/**/*'
    ].to_a

    s.add_runtime_dependency('trollop', '~> 2.0')

    s.test_files  = FileList["tests/test*.rb"].to_a
end
