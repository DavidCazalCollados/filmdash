require "json"
require "rest-client"

class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
  end

  def preferences
  end

  def movies
    # raise
    @vpn = current_user.vpn
    @country = current_user.country.code
    @streaming_services = current_user.streaming_services
    @streaming_names = @streaming_services.map { |service| service["name"] }
    # raise
    @streaming_services_ids = @streaming_services.map { |streaming| streaming.source_id }.join('|')
    @release_date_start = params[:period]
    @runtime_min = params[:runtime]
    @genre = params[:genre]
    @format = params[:format]

    request_headers = {
      Authorization: "Bearer #{ENV["API_KEY_TMDB"]}",
      accept: "application/JSON"
      }

    if params[:format] == "tv_series"
      request_url = build_tmdb_url_series
      response = RestClient.get(request_url, request_headers)
      result_tt = JSON.parse(response)
      @result_ids = result_tt["results"].sample(3).map { |movie| movie["id"] }

      @results = @result_ids.map do |result_id|
        details_serialized = RestClient.get("https://api.themoviedb.org/3/tv/#{result_id}?append_to_response=videos,watch/providers", request_headers)
        details = JSON.parse(details_serialized)
        prepare_result_series(details)
      end
    else
      request_url = build_tmdb_url_movies
      response = RestClient.get(request_url, request_headers)
      result_tt = JSON.parse(response)
      # @result_ids = result_tt["results"].sample(3).map { |movie| movie["id"] }
      @result_ids = result_tt["results"].first(3).map { |movie| movie["id"] }
      @results = @result_ids.map do |result_id|
        details_serialized = RestClient.get("https://api.themoviedb.org/3/movie/#{result_id}?append_to_response=videos,watch/providers", request_headers)
        details = JSON.parse(details_serialized)
        prepare_result(details)
      end

    end

    # raise
    # seed ={}
    # url = "https://api.watchmode.com/v1/list-titles/?apiKey=#{ENV["API_KEY_WATCHMODE"]}&types=#{params[:format]}&source_ids=#{@streaming_services_ids}&source_types=sub&region=#{@country}&genres=#{params[:genre]}&release_date_start=#{params[:period]}&release_date_end=#{@release_date_end_s}&critic_score_low=8&limit=250"

    # if seed.key?(url) == false
    #   response = RestClient.get(url)
    #   result_tt = JSON.parse(response)
    #   seed[url] = result_tt
    # end
    # @result_titles = result_tt["titles"].sample(3)
    # # raise
    # @result = @result_titles.map do |title_infos|
    #   titles_details_parse = RestClient.get "https://api.watchmode.com/v1/title/#{title_infos["imdb_id"]}/details/?apiKey=#{ENV["API_KEY_WATCHMODE"]}&append_to_response=sources"
    #   JSON.parse(titles_details_parse)
    # end
    # @result = result_tt
  end

  def details
  end

  private

  def build_tmdb_url_movies
    base_url = "https://api.themoviedb.org/3/discover/movie"
    params = {
      include_adult: false,
      include_video: false,
      page: 1,
      sort_by: "popularity.desc",
      watch_region: "#{@country}",
      "primary_release_date.gte" => "#{@release_date_start}",
      with_watch_monetization_types: "flatrate",
      with_watch_providers: "#{@streaming_services_ids}",
      "with_runtime.lte" => "#{@runtime_min}",
      with_genres: "#{@genre}",
      "primary_release_date.lte" => "#{Date.parse(@release_date_start).advance(years: 10).strftime("%Y-%m-%d")}",
      # "with_runtime.lte" => "#{@runtime_min.to_i + 60}",
      "vote_average.gte" => 7
    }
    return "#{base_url}?#{params.map { |key, value| "#{key}=#{value}" }.join('&')}"
  end

  def build_tmdb_url_series
    base_url = "https://api.themoviedb.org/3/discover/tv"
    params = {
      include_adult: false,
      # include_null_first_air_dates: false,
      page: 1,
      sort_by: "popularity.desc",
      watch_region: "#{@country}",
      "first_air_date.gte" => "#{@release_date_start}",
      with_watch_monetization_types: "flatrate",
      with_watch_providers: "#{@streaming_services_ids}",
      # "with_runtime.gte" => "#{@runtime_min}",
      with_genres: "#{@genre}",
      "first_air_date.lte" => "#{Date.parse(@release_date_start).advance(years: 10).strftime("%Y-%m-%d")}",
      # "with_runtime.lte" => "#{@runtime_min.to_i + 60}",
      "vote_average.gte" => 7
    }
    return "#{base_url}?#{params.map { |key, value| "#{key}=#{value}" }.join('&')}"
  end

  def prepare_result(full_results)

    streaming_services_names = current_user.streaming_services.map do |streaming_services|
      streaming_services.name
    end
    final_result = full_results.slice("backdrop_path", "id", "overview", "poster_path", "release_date", "title", "vote_average", "runtime")

    final_result["genre"] = @genre
    final_result["tmdb_id"] = full_results["id"]
    watch_providers = full_results["watch/providers"]["results"][@country]
    tmdb_watch_providers_page_link = watch_providers["link"]
    user_subscribed_providers = []

    user_subscribed_watch_providers = watch_providers["flatrate"].select { |provider| streaming_services_names.include?(provider['provider_name']) }

    watch_providers["flatrate"].each do |provider|
      # puts provider['provider_name']
      if streaming_services_names.include?(provider['provider_name'])
        user_subscribed_providers << provider
      end
    end

    tmdb_watch_providers = tmdb_watch_providers_page_link.empty? ? [] : scrape_tmdb_streaming_links(tmdb_watch_providers_page_link)
    final_result["watch_providers"] = filter_watch_providers(tmdb_watch_providers, user_subscribed_providers)

    trailer_condition = full_results["videos"]["results"].find { |video| video["type"].downcase == "trailer" && video["site"].downcase == "youtube" }
    final_result["trailer_youtube_key"] = trailer_condition["key"] if trailer_condition
    # final_result["trailer_youtube_key"] = full_results["videos"]["results"].find { |video| video["type"].downcase == "trailer" && video["site"].downcase == "youtube" }["key"]
    final_result
  end

  def prepare_result_series(full_results)
    streaming_services_names = current_user.streaming_services.map do |streaming_services|
      streaming_services.name
    end

    final_result = full_results.slice("backdrop_path", "id", "overview", "poster_path", "first_air_date", "name", "vote_average")
    final_result["genre"] = @genre
    watch_providers = full_results["watch/providers"]["results"][@country]
    final_result["streaming_link"] = watch_providers["link"]
    final_result["watch_providers"] = []
    watch_providers["flatrate"].each do |provider|
      puts provider['provider_name']
      if streaming_services_names.include?(provider['provider_name'])
        final_result["watch_providers"] << provider
      end
    end
    trailer_condition = full_results["videos"]["results"].find { |video| video["type"].downcase == "trailer" && video["site"].downcase == "youtube" }
    final_result["trailer_youtube_key"] = trailer_condition["key"] if trailer_condition
    # final_result["trailer_youtube_key"] = full_results["videos"]["results"].find { |video| video["type"].downcase == "trailer" && video["site"].downcase == "youtube" }["key"]
    final_result = final_result.transform_keys ({"name" => "title", "first_air_date" => "release_date"})
    return final_result
  end

  def scrape_tmdb_streaming_links(url)
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
  end

  def filter_watch_providers(tmdb_watch_providers, user_subscribed_providers)
    return [] if tmdb_watch_providers.empty? || user_subscribed_providers.empty?

    user_subscribed_providers_logo_paths = user_subscribed_providers.map { |user_subscribed_provider| user_subscribed_provider["logo_path"] }

    tmdb_watch_providers.select do |tmdb_watch_provider|
      scraped_url_path = tmdb_watch_provider["logo_path"].split('/').last
      user_subscribed_providers_logo_paths.include?("/#{scraped_url_path}")
    end
  end
end
