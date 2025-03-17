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
    this.spinner.className = "spinner";
    this.spinner.innerHTML = `
      <div class="spinner-border text-primary" role="status">
        <span class="visually-hidden">Loading...</span>
      </div>
    `;

    // Add spinner styles
    const style = document.createElement("style");
    style.textContent = `
      .spinner {
        display: flex;
        justify-content: center;
        padding: 2rem;
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

  appendMoviesToDom(movies) {
    movies.forEach((movie) => {
      if ((movie.media_type === "movie" || movie.media_type === "tv") && (movie.poster_path !== null)) {
        const cardHTML = this.createMoviePoster(movie);
        this.moviesContainer.insertAdjacentHTML('beforeend', cardHTML);
      }
    });
  }

  createMoviePoster(movie) {
    const movieLink = `/search/${movie.media_type}/${movie.id}`;
    const title = movie.title || movie.name; // Handle both movie and TV show titles

    return `
      <div class="poster-container">
        <a href="${movieLink}">
          <img class="poster" src="https://image.tmdb.org/t/p/w185/${movie.poster_path}" alt="${title}">
        </a>
      </div>
    `;
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
