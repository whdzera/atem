require 'net/http'
require 'uri'
require 'json'

class Random
  def self.api_url
    ENV.fetch('apiurl', nil)
  end

  def self.api_token
    ENV.fetch('apikey', nil)
  end

  def self.card
    return nil if api_url.nil? || api_token.nil?

    uri = URI.join(api_url, '/api/yugioh/random')

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')

    request = Net::HTTP::Get.new(uri.request_uri)
    request['Authorization'] = "Bearer #{api_token}"

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
