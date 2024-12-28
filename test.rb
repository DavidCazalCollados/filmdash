require "json"
require "rest-client"

# response = RestClient.get "https://api.watchmode.com/v1/list-titles/?apiKey="
# selection = JSON.parse(response)

# pp selection

# it returns: {"titles"=>
  # [{"id"=>1627911, "title"=>"Damsel", "year"=>2024, "imdb_id"=>"tt13452446", "tmdb_id"=>763215, "tmdb_type"=>"movie", "type"=>"movie"},
  #   {"id"=>1530411, "title"=>"Beverly Hills Cop: Axel F", "year"=>2024, "imdb_id"=>"tt3083016", "tmdb_id"=>280180, "tmdb_type"=>"movie", "type"=>"movie"},
  #   {"id"=>1675091, "title"=>"Madame Web", "year"=>2024, "imdb_id"=>"tt11057302", "tmdb_id"=>634492, "tmdb_type"=>"movie", "type"=>"movie"}],
  # "page"=>1,
  # "total_pages"=>9,
  # "total_results"=>26}


# response = RestClient.get "https://api.watchmode.com/v1/releases/?apiKey="
# repos = JSON.parse(response)

# streaming = repos["releases"].map { |stream| "{ source_id: #{stream["source_id"]}, name: #{stream["source_name"]} }" }.uniq
# pp streaming




# list title:

# response = RestClient.get "https://api.watchmode.com/v1/title/tt17526714/sources/?apiKey="
# repos = JSON.parse(response)

# pp repos

# release_date_end = ("20100101").to_i + 100000
# release_date_end_s = release_date_end.to_s
# pp release_date_end_s


<div data-toggle-target="container2Element" class="row justify-content-center movie-info mb-3">
<div class="movie-card col-4" data-action="click->toggle#button2" style="background-image:url('<%= @result[1]["poster"] %>')">
  <%# <div class="placeholder" alt="Placeholder 3"></div> %>
  <div class="d-none play-button" data-toggle-target="play2Element">
    <p><i class="fa-solid fa-play"></i></p>
  </div>
</div>
<div data-toggle-target="appear2Element" class="d-none infos d-flex flex-column align-items-start col-8">
  <div class="title">
    <p><strong><%= @result[1]["title"] %></strong></p>
  </div>
  <div class="rating">
    <p><i class="fa-solid fa-star text-warning"></i> <%= @result[1]["user_rating"] %>/10</p>
  </div>
  <div class="description">
    <p><%= @result[1]["plot_overview"] %></p>
  </div>
  <div>
  </div>
</div>
</div>

<div data-toggle-target="container3Element" class="row justify-content-center movie-info mb-3">
<div class="movie-card col-4" data-action="click->toggle#button3" style="background-image:url('<%= @result[2]["poster"] %>')">
  <%# <div class="placeholder" alt="Placeholder 3"></div> %>
  <div class="d-none play-button" data-toggle-target="play3Element">
    <p><i class="fa-solid fa-play"></i></p>
  </div>
</div>
<div data-toggle-target="appear3Element" class="d-none infos d-flex flex-column align-items-start col-8">
  <div class="title">
    <p><strong><%= @result[2]["title"] %></strong></p>
  </div>
  <div class="rating">
    <p><i class="fa-solid fa-star text-warning"></i> <%= @result[2]["user_rating"] %>/10</p>
  </div>
  <div class="description">
    <p><%= @result[2]["plot_overview"] %></p>
  </div>
  <div>
  </div>
</div>
</div>


          <% @result[0]["sources"].each do |source| %>
            <% @streaming_services.each do |streaming_service| %>
              <% if (streaming_service.source_id == source["source_id"]) && (@country == source["region"]) %>
                <%= link_to source["name"], source["web_url"], target: :_blank %>
              <% end %>
            <% end %>
          <% end %>


          <div class="trailer mb-5 text-center" style="background-image:url('https://img.youtube.com/vi/<%= movie["trailer_youtube_key"] %>/maxresdefault.jpg');">
      <%= link_to "<i class='fa-solid fa-play'></i>".html_safe, "https://www.youtube.com/watch?v=#{movie["trailer_youtube_key"]}", target: "_blank" %>
    </div>
