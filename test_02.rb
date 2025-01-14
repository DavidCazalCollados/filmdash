require "json"
require "rest-client"
require 'nokogiri'

url = "https://www.themoviedb.org/tv/1695-monk"
doc = Nokogiri::HTML.parse(RestClient.get(url), nil, "utf-8")

    streaming_providers = []
    return streaming_providers if url.empty?

    ott_providers = doc.search('div.ott_provider')
    stream_ott_providers = ott_providers.find { |ott_provider| ott_provider.search('h3').text.strip.downcase == 'stream' }
    return streaming_providers if stream_ott_providers.nil?

    streaming_providers_links = stream_ott_providers.search('li:not(.hide) a')
    streaming_providers_links.each do |streaming_providers_link|
      streaming_providers << {
        "streaming_link" => streaming_providers_link.attribute('href').value,
        "logo_path" => streaming_providers_link.search('img').first.attribute('src').value
      }
    end

    return streaming_providers
    print streaming_providers
