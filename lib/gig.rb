require "gig/version"
require "gig/greper"
require 'pry'

module Gig
  # class Error < StandardError; end
  def self.call(options = [])
    greper = Greper.new(options)
    greper.grep
  end
end
