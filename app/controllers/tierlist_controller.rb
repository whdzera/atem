require 'net/http'
require 'uri'
require 'json'

class Tierlist
  API_URL   = ENV.fetch('apiurl')
  API_TOKEN = ENV.fetch('apikey')

  def self.name(tier_type)
    return nil if API_URL.nil? || API_TOKEN.nil?

    uri = URI.join(API_URL, "/api/yugioh/tierlist?name=#{tier_type}")

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
