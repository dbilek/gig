require "net/http"
require "open-uri"
require 'json'

require 'pry'


module Gig
  class Greper
    attr_reader :options, :uri

    def initialize(options = [])
      @options = options
      @uri     = generate_uri("https://api.github.com/search/repositories", options)
    end

    def grep
      begin
        response        = Net::HTTP.get_response(uri)
        response_parsed = JSON.parse(response.body)
        items           = response_parsed["items"]
        directory_name  = options.join("-")

        Dir.mkdir directory_name unless Dir.exist?(directory_name)

        items.each do |item|
          avatar_url = item["owner"]["avatar_url"]

          open(avatar_url) do |image|
            avatar_name = "avatar_" + avatar_url.split("/").last.split("?").first
            File.open("#{directory_name}/#{avatar_name}.jpg", "wb") do |file|
              file.write(image.read)
            end
          end
        end
      rescue StandardError => error
        puts "An error occurred, please check parameters you typed or contact technical support."
        puts "Error message: " + error.inspect
      end
    end

    def generate_uri(api_url, options)
      query_option = options.any? ? options.join("+") : ""
      search_url   = api_url + "?q=#{query_option}&per_page=5"

      URI.parse(search_url)
    end
  end
end
