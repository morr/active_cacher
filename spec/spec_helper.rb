$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'active_cacher'
require 'pry-byebug'

require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start
