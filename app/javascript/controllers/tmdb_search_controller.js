export default class TmdbSearchController {
  constructor(element) {
    this.element = element;
    this.apiUrl = element.dataset.apiUrl;
    this.headers = JSON.parse(element.dataset.headers);
    this.moviesContainer = element.querySelector(".result-search-grid");
    this.searchInput = element.querySelector(".form-control");
    this.searchButton = element.querySelector("#button-addon2");

    // Add event listener
    this.searchButton.addEventListener('click', this.handleSearch.bind(this));

    // Create spinner element
    this.spinner = document.createElement("div");
    this.spinner.className = "search-spinner";
    this.spinner.innerHTML = `
      <div class="spinner-border text-primary" role="status">
        <span class="visually-hidden">Loading...</span>
      </div>
    `;

    // Add spinner styles
    const style = document.createElement("style");
    style.textContent = `
      .search-spinner {
        position: absolute;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        z-index: 10;
      }
    `;
    document.head.appendChild(style);
  }

  handleSearch(e) {
    e.preventDefault();
    const titleValue = this.searchInput.value;

    // Clear previous results
    this.moviesContainer.innerHTML = "";

    // Add spinner
    this.moviesContainer.appendChild(this.spinner);

    // Array to store all results from all pages
    let allMovies = [];

    // Fetch first page
    fetch(`${this.apiUrl}?query=${encodeURIComponent(titleValue)}`, {
      method: 'GET',
      headers: this.headers
    })
    .then(response => response.json())
    .then(data => {
      // Add first page results to allMovies array
      allMovies = [...data.results];

      // Create an array of fetch promises for remaining pages
      const fetchPromises = [];
      for (let i = 2; i <= Math.min(data.total_pages, 5); i++) {
        fetchPromises.push(
          fetch(`${this.apiUrl}?query=${encodeURIComponent(titleValue)}&page=${i}`, {
            method: 'GET',
            headers: this.headers
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
      if (this.spinner.parentNode === this.moviesContainer) {
        this.moviesContainer.removeChild(this.spinner);
      }

      // Append sorted movies to DOM
      this.appendMoviesToDom(allMovies);
    })
    .catch(error => {
      console.error('Error fetching movies:', error);
      if (this.spinner.parentNode === this.moviesContainer) {
        this.moviesContainer.removeChild(this.spinner);
      }
      this.moviesContainer.innerHTML = "<p>Error loading results. Please try again.</p>";
    });
  }

  createMoviePoster(movie) {
    const movieLink = `/search/${movie.media_type}/${movie.id}`;
    const title = movie.title || movie.name; // Handle both movie and TV show titles
    const releaseDate = movie.release_date || movie.first_air_date; // Handle release date for movies and air date for series

    // Extract the year from the date format "YYYY-MM-DD"
    const releaseYear = releaseDate ? new Date(releaseDate).getFullYear() : 'N/A'; // Extract the year

    // Create the movie poster HTML (now without inline styles)
    return `
      <div class="poster-container">
        <img src="https://image.tmdb.org/t/p/w185/${movie.poster_path}" alt="${title}" />
        <div class="movie-info-overlay">
          <div class="movie-title-overlay"><strong>${title}</strong></div>
          <div>${releaseYear}</div>
          <a href="${movieLink}" class="btn btn-dark button-overlay"><strong>See more</strong></a>
        </div>
        <div class="overlay"></div>
      </div>
    `;
  }

  appendMoviesToDom(movies) {
    // Clear existing content first
    this.moviesContainer.innerHTML = "";

    movies.forEach((movie) => {
      if ((movie.media_type === "movie" || movie.media_type === "tv") && (movie.poster_path !== null)) {
        const cardHTML = this.createMoviePoster(movie);
        this.moviesContainer.insertAdjacentHTML('beforeend', cardHTML);

        // After the movie poster is inserted, add an event listener for clicks on the poster
        const posterContainer = this.moviesContainer.querySelector('.poster-container:last-child');
        const posterImage = posterContainer.querySelector('img');
        const movieInfo = posterContainer.querySelector('.movie-info-overlay');
        const overlay = posterContainer.querySelector('.overlay');

        // Track clicks on this specific poster
        let isInfoShowing = false;

        // Handle poster click
        posterImage.addEventListener('click', () => {
          // If info is already showing on this poster, navigate to the detail page
          if (isInfoShowing) {
            window.location.href = `/search/${movie.media_type}/${movie.id}`;
            return;
          }

          // First, hide all other movie infos and overlays
          const allInfos = this.moviesContainer.querySelectorAll('.movie-info-overlay');
          const allOverlays = this.moviesContainer.querySelectorAll('.overlay');

          allInfos.forEach(info => {
            info.style.display = 'none';
          });

          allOverlays.forEach(ol => {
            ol.style.display = 'none';
          });

          // Reset all tracking variables
          const allPosters = this.moviesContainer.querySelectorAll('.poster-container');
          allPosters.forEach(poster => {
            poster.dataset.infoShowing = 'false';
          });

          // Show this movie's info and overlay
          movieInfo.style.display = 'flex';
          overlay.style.display = 'block';
          isInfoShowing = true;
          posterContainer.dataset.infoShowing = 'true';
        });

        // Also add click handler to the See More button
        const seeMoreButton = movieInfo.querySelector('.btn');
        if (seeMoreButton) {
          seeMoreButton.addEventListener('click', (e) => {
            // Prevent the event from bubbling to the poster image
            e.stopPropagation();
            window.location.href = `/search/${movie.media_type}/${movie.id}`;
          });
        }
      }
    });
  }

  // Initialize all instances on the page
  static initialize() {
    const elements = document.querySelectorAll("[data-controller='tmdb-search']");
    elements.forEach(element => {
      new TmdbSearchController(element);
    });
  }
}

// Initialize on page load and on Turbo navigation
document.addEventListener("DOMContentLoaded", TmdbSearchController.initialize);
document.addEventListener("turbo:load", TmdbSearchController.initialize);
