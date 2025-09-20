require 'net/http'
require 'uri'
require 'json'

class List
  API_URL   = ENV.fetch('apiurl')
  API_TOKEN = ENV.fetch('apikey')

  def self.name(input, only: nil)
    return nil if API_URL.nil? || API_TOKEN.nil? || input.nil? || input.strip.empty?

    encoded = URI.encode_www_form_component(input)

    query = "name=#{encoded}"
    query += "&only=#{only}" if only

    uri = URI.join(API_URL, "/api/yugioh/list?#{query}")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')

    request = Net::HTTP::Get.new(uri.request_uri)
    request['Authorization'] = "Bearer #{API_TOKEN}"

    response = http.request(request)

    if response.is_a?(Net::HTTPSuccess)
      JSON.parse(response.body)
    else
      puts "HTTP Error: #{response.code} #{response.message}"
      nil
    end
  rescue StandardError => e
    puts "Request failed: #{e.class} - #{e.message}"
    nil
  end
end
