import Foundation
import Combine

class HealthNewsService: ObservableObject {
    @Published var news: [HealthNews] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    // Using NewsAPI.org - you can get a free API key at https://newsapi.org/
    private let baseURL = "https://newsapi.org/v2"
    private let apiKey = "YOUR_NEWS_API_KEY" // Replace with your actual API key
    
    // Alternative: Use Guardian API (also free) - https://open-platform.theguardian.com/
    private let guardianBaseURL = "https://content.guardianapis.com"
    private let guardianApiKey = "YOUR_GUARDIAN_API_KEY" // Replace with your Guardian API key
    
    // Use sample data when API key is not configured
    private var useSampleData: Bool {
        return apiKey == "YOUR_NEWS_API_KEY" || apiKey.isEmpty
    }
    
    init() {
        loadNews(category: .all)
    }
    
    // MARK: - Public Methods
    
    func loadNews(category: NewsCategory = .all) {
        if useSampleData {
            loadSampleData(for: category)
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // Try NewsAPI first, fallback to Guardian API if needed
        fetchFromNewsAPI(category: category)
    }
    
    func fetchHealthNews(category: NewsCategory = .all, limit: Int = 20) {
        loadNews(category: category)
    }
    
    private func fetchFromNewsAPI(category: NewsCategory, limit: Int = 20) {
        let searchQuery = category.searchTerms.joined(separator: " OR ")
        let encodedQuery = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        let urlString = "\(baseURL)/everything?q=(\(encodedQuery))&language=en&sortBy=publishedAt&pageSize=\(limit)&apiKey=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid URL"
                self.isLoading = false
                self.loadSampleData(for: category)
            }
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: NewsAPIResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        print("NewsAPI Error: \(error)")
                        // Fallback to Guardian API
                        self?.fetchFromGuardianAPI(category: category)
                    }
                },
                receiveValue: { [weak self] response in
                    self?.news = response.articles
                }
            )
            .store(in: &cancellables)
    }
    
    private func fetchFromGuardianAPI(category: NewsCategory) {
        let searchQuery = category.searchTerms.first ?? "health"
        let urlString = "\(guardianBaseURL)/search?q=\(searchQuery)&section=lifeandstyle&page-size=20&show-fields=thumbnail,trailText&api-key=\(guardianApiKey)"
        
        guard let url = URL(string: urlString) else {
            loadSampleData(for: category)
            return
        }
        
        // Guardian API implementation would go here
        // For now, fallback to sample data
        loadSampleData(for: category)
    }
    
    func searchNews(query: String) {
        if useSampleData {
            // Filter sample data based on query
            let filtered = getCurrentSampleData().filter { article in
                article.title.localizedCaseInsensitiveContains(query) ||
                article.description.localizedCaseInsensitiveContains(query)
            }
            self.news = filtered
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "\(baseURL)/everything?q=\(encodedQuery)+health&language=en&sortBy=relevancy&pageSize=20&apiKey=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid URL"
                self.isLoading = false
            }
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: NewsAPIResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                        self?.loadSampleData(for: .all)
                    }
                },
                receiveValue: { [weak self] response in
                    self?.news = response.articles
                }
            )
            .store(in: &cancellables)
    }
    
    func refreshNews(category: NewsCategory = .all) {
        loadNews(category: category)
    }
    
    // MARK: - Private Methods
    
    private func loadSampleData(for category: NewsCategory) {
        DispatchQueue.main.async {
            switch category {
            case .all:
                self.news = HealthNews.allSampleData
            case .fitness:
                self.news = HealthNews.fitnessSampleData
            case .nutrition:
                self.news = HealthNews.nutritionSampleData
            case .mentalHealth:
                self.news = HealthNews.mentalHealthSampleData
            case .wellness:
                self.news = HealthNews.wellnessSampleData
            }
            self.isLoading = false
            self.errorMessage = nil
        }
    }
    
    private func getCurrentSampleData() -> [HealthNews] {
        return news.isEmpty ? HealthNews.allSampleData : news
    }
}

// MARK: - Alternative News Sources
extension HealthNewsService {
    
    // Alternative method using Guardian API (free tier available)
    func fetchNewsFromGuardian(category: String = "wellness") {
        // Implementation placeholder - replace with actual Guardian API implementation
        loadSampleData(for: .all)
    }
    
    // Alternative method using RSS feeds (free)
    func fetchHealthNewsFromRSS() {
        // You can use RSS feeds from health websites like:
        // - Mayo Clinic: https://www.mayoclinic.org/rss
        // - WebMD: https://rss.webmd.com/rss/rss.aspx?RSSSource=RSS_PUBLIC
        // - Healthline: https://www.healthline.com/rss
        
        // RSS parsing implementation would go here
        loadSampleData(for: .all)
    }
}

// MARK: - Network Manager Helper
class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    func downloadImage(from url: URL) -> AnyPublisher<Data, URLError> {
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .eraseToAnyPublisher()
    }
}
