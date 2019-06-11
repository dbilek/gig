require "gig/version"
require "gig/greper"

module Gig
  def self.call(options = [])
    greper = Greper.new(options)
    greper.grep
  end
end
