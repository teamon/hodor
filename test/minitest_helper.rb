$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'hodor'

require 'support/capture'
require 'minitest/pride'
require 'minitest/autorun'
require "minitest/reporters"
require 'minitest/hooks/test'

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

