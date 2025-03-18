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




  <div class="header-text">
    <h1>Welcome to Filmdash</h1>
    <h2>Your cinematic journey!</h2>
  </div>
  <%= image_tag "home_page/Chaplin.webp", alt: "Charlie Chaplin" %>
  <div class="get-started-button">
    <%= link_to "Get started", preferences_path, class: "button-get-started" %>
  </div>
</div>
<div class="bottom-image">
<%= image_tag "home_page/Truffaut.jpg", alt: "François Truffaut" %>
</div>





TEST FOR JS IN search

<script>

  const tmdbapiUrl = "https://api.themoviedb.org/3/search/multi";
  const requestHeaders = <%= raw @request_headers.to_json %>;
  const moviesContainer = document.querySelector(".result-search-grid");
  const title = document.querySelector(".form-control");
  const searchButton = document.getElementById("button-addon2");

  // Create a spinner element
  const spinner = document.createElement("div");
  spinner.className = "spinner";
  spinner.innerHTML = `
    <div class="spinner-border text-primary" role="status">
      <span class="visually-hidden">Loading...</span>
    </div>
  `;

  // Add some CSS for the spinner positioning
  const style = document.createElement("style");
  style.textContent = `
    .spinner {
      display: flex;
      justify-content: center;
      padding: 2rem;
    }
  `;
  document.head.appendChild(style);

  searchButton.addEventListener('click', (e) => {
    e.preventDefault();
    const titleValue = title.value;

    // Clear previous results
    moviesContainer.innerHTML = "";

    // Add spinner
    moviesContainer.appendChild(spinner);

    // Array to store all results from all pages
    let allMovies = [];

    // Fetch first page
    fetch(`${tmdbapiUrl}?query=${encodeURIComponent(titleValue)}`, {
      method: 'GET',
      headers: requestHeaders
    })
    .then(response => response.json())
    .then(data => {
      // Add first page results to allMovies array
      allMovies = [...data.results];

      // Create an array of fetch promises for remaining pages
      const fetchPromises = [];
      for (let i = 2; i <= Math.min(data.total_pages, 350); i++) { // Limiting to 5 pages to avoid too many requests
        fetchPromises.push(
          fetch(`${tmdbapiUrl}?query=${encodeURIComponent(titleValue)}&page=${i}`, {
            method: 'GET',
            headers: requestHeaders
          })
          .then(response => response.json())
          .then(pageData => {
            // Add this page's results to the allMovies array
            allMovies = [...allMovies, ...pageData.results];
          })
        );
      }

      // Wait for all fetch promises to resolve
      return Promise.all(fetchPromises);
    })
    .then(() => {
      // Sort all movies by popularity in descending order
      allMovies.sort((a, b) => b.popularity - a.popularity);

      // Remove spinner
      moviesContainer.removeChild(spinner);

      // Append sorted movies to DOM
      appendMoviesToDom(allMovies);
    })
    .catch(error => {
      console.error('Error fetching movies:', error);
      moviesContainer.removeChild(spinner);
      moviesContainer.innerHTML = "<p>Error loading results. Please try again.</p>";
    });
  });

  const appendMoviesToDom = (movies) => {
    const moviesContainer = document.querySelector(".result-search-grid");
    movies.forEach((movie) => {
      if ((movie.media_type === "movie" || movie.media_type === "tv") && (movie.poster_path !== null)) {
        cardHTML = createMoviePoster(movie);
        moviesContainer.insertAdjacentHTML('beforeend', cardHTML);
      }
    });
  };

  const createMoviePoster = (movie) => {
    const movieLink = `/search/${movie.media_type}/${movie.id}`;
    const title = movie.title || movie.name; // Handle both movie and TV show titles

    return `
      <div class="poster-container">
        <a href="${movieLink}">
          <img class="poster" src="https://image.tmdb.org/t/p/w185/${movie.poster_path}" alt="${title}">
        </a>
      </div>
    `;
  };
</script>
