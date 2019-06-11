require "gig/version"
require "gig/greper"
require 'pry'

module Gig
  def self.call(options = [])
    greper = Greper.new(options)
    greper.grep
  end
end
