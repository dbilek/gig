require "net/http"
require "open-uri"
require 'json'

ITEMS_PER_PAGE = 50
API_URL        = "https://api.github.com"

module Gig
  class Greper
    attr_reader :options
    attr_accessor :uri

    def initialize(options = [])
      @options = options
      url      = API_URL + "/search/repositories"
      @uri     = generate_uri(url, options)
    end

    def grep
      begin
        response         = get_http_response(uri)
        response_parsed  = JSON.parse(response.body)
        response_message = response_parsed["message"]

        raise StandardError.new(response_message) unless response.code == "200"

        items           = response_parsed["items"]
        directory_name  = options.join("-")
        images_before   = count_files(directory_name)

        make_storage_directory(directory_name)

        items.each do |item|
          avatar_url  = item["owner"]["avatar_url"]
          download_image(avatar_url, directory_name)
          print "."
        end

        show_download_info(images_before, directory_name)

        handle_pagination(response["link"])

      rescue StandardError => error
        puts "An error occurred, please check parameters you typed or contact technical support."
        puts "Error message: " + error.inspect
      end
    end

    private

    def generate_uri(api_url, options)
      query_option = options.any? ? options.join("+") : ""
      search_url   = api_url + "?q=#{query_option}&per_page=#{ITEMS_PER_PAGE}"

      URI.parse(search_url)
    end

    def get_http_response(uri)
      Net::HTTP.get_response(uri)
    end

    def make_storage_directory(directory_name)
      Dir.mkdir directory_name unless Dir.exist?(directory_name)
    end

    def download_image(avatar_url, directory_name)
      raise StandardError.new("Missing storage directory") unless Dir.exist?(directory_name)

      avatar_name = "avatar_" + avatar_url.split("/").last.split("?").first + ".jpg"
      return if File.exist?("#{directory_name}/#{avatar_name}")

      open(avatar_url) do |image|
        File.open("#{directory_name}/#{avatar_name}", "wb") do |file|
          file.write(image.read)
        end
      end
    end

    def show_download_info(images_before, directory_name)
      all_images        = count_files(directory_name)
      downloaded_images = (images_before - all_images).abs

      puts
      puts "Total: #{all_images} images"
      if downloaded_images > 0
        puts "Downloaded #{downloaded_images} images."
      else
        puts "There's no new downloaded images."
      end
      puts "----------------------------------------------------------"
    end

    def count_files(directory_name)
      Dir["#{directory_name}/*"].length
    end

    def handle_pagination(response_link)
      puts "Do want to continue with next page? Type 'yes' or 'no'"
      user_answer = STDIN.gets.strip

      if user_answer == "yes"
        pagination_links = pagination_links(response_link)
        next_page_url    = pagination_links["next"]

        @uri = URI.parse(next_page_url)
        self.grep
      end
    end

    def pagination_links(response_link)
      links = {}

      response_link.split(',').each do |link|
        link.strip!

        parts = link.match(/<(.+)>; *rel="(.+)"/)
        links[parts[2]] = parts[1]
      end

      links
    end
  end
end
