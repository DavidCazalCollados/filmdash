import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.apiUrl = this.element.dataset.apiUrl;
    this.headers = JSON.parse(this.element.dataset.headers);
    this.moviesContainer = this.element.querySelector(".result-search-grid");
    this.searchInput = this.element.querySelector(".form-control");
    this.searchButton = this.element.querySelector("#button-addon2");

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
          <div class="movie-date-overlay">${releaseYear}</div>
          <a href="${movieLink}" class="btn btn-dark button-overlay"><strong>See more</strong></a>
        </div>
        <div class="overlay"></div>
      </div>
    `;
  }

  appendMoviesToDom(movies) {
    // Clear existing content
    this.moviesContainer.innerHTML = "";

    movies.forEach((movie) => {
      if ((movie.media_type === "movie" || movie.media_type === "tv") && (movie.poster_path !== null)) {
        const cardHTML = this.createMoviePoster(movie);
        this.moviesContainer.insertAdjacentHTML('beforeend', cardHTML);

        // Get the newly added poster elements
        const posterContainer = this.moviesContainer.querySelector('.poster-container:last-child');
        const posterImage = posterContainer.querySelector('img');
        const movieInfo = posterContainer.querySelector('.movie-info-overlay');
        const overlay = posterContainer.querySelector('.overlay');
        const seeMoreButton = movieInfo.querySelector('.btn');

        // IMPORTANT: Make sure overlay and info are hidden initially
        movieInfo.style.display = 'none';
        overlay.style.display = 'none';

        // Handle poster image click - should ONLY show overlay, never navigate
        posterImage.addEventListener('click', (e) => {
          e.preventDefault(); // Prevent any default navigation

          // Hide all other overlays first
          const allMovieInfos = this.moviesContainer.querySelectorAll('.movie-info-overlay');
          const allOverlays = this.moviesContainer.querySelectorAll('.overlay');

          allMovieInfos.forEach(info => info.style.display = 'none');
          allOverlays.forEach(ol => ol.style.display = 'none');

          // Show this movie's info and overlay
          movieInfo.style.display = 'flex';
          overlay.style.display = 'block';
        });

        // Add click handler to the See More button - should ONLY navigate
        if (seeMoreButton) {
          seeMoreButton.addEventListener('click', (e) => {
            e.stopPropagation(); // Prevent event from bubbling to poster
            window.location.href = `/search/${movie.media_type}/${movie.id}`;
          });
        }

        // Also handle clicks on the overlay - should close the overlay
        overlay.addEventListener('click', (e) => {
          if (e.target === overlay) { // Only if directly clicking the overlay
            movieInfo.style.display = 'none';
            overlay.style.display = 'none';
          }
        });
      }
    });
  }
}
