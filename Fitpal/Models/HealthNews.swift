import Foundation

// MARK: - Health News Models
struct HealthNews: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String
    let url: String
    let urlToImage: String?
    let publishedAt: String
    let source: NewsSource
    let author: String?
    let content: String?
    
    private enum CodingKeys: String, CodingKey {
        case title, description, url, urlToImage, publishedAt, source, author, content
    }
    
    var publishedDate: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        return formatter.date(from: publishedAt) ?? Date()
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: publishedDate)
    }
}

struct NewsSource: Codable {
    let id: String?
    let name: String
}

// MARK: - API Response Models
struct NewsAPIResponse: Codable {
    let status: String
    let totalResults: Int
    let articles: [HealthNews]
}

// MARK: - News Categories
enum NewsCategory: String, CaseIterable {
    case all = "health+fitness+nutrition+mental-health+wellness"
    case fitness = "fitness+workout+exercise"
    case nutrition = "nutrition+diet+healthy-eating"
    case mentalHealth = "mental-health+mindfulness+meditation"
    case wellness = "wellness+wellbeing+self-care"
    
    var displayName: String {
        switch self {
        case .all:
            return "All"
        case .fitness:
            return "Fitness"
        case .nutrition:
            return "Nutrition"
        case .mentalHealth:
            return "Mental Health"
        case .wellness:
            return "Wellness"
        }
    }
    
    var icon: String {
        switch self {
        case .all:
            return "newspaper"
        case .fitness:
            return "figure.run"
        case .nutrition:
            return "leaf"
        case .mentalHealth:
            return "brain.head.profile"
        case .wellness:
            return "heart.circle"
        }
    }
    
    var searchTerms: [String] {
        switch self {
        case .all:
            return ["health", "fitness", "nutrition", "mental health", "wellness", "wellbeing", "exercise", "diet", "mindfulness"]
        case .fitness:
            return ["fitness", "workout", "exercise", "training", "gym", "cardio", "strength", "running", "yoga"]
        case .nutrition:
            return ["nutrition", "diet", "healthy eating", "vitamins", "supplements", "food", "meal planning", "recipes"]
        case .mentalHealth:
            return ["mental health", "mindfulness", "meditation", "stress", "anxiety", "depression", "therapy", "self-care"]
        case .wellness:
            return ["wellness", "wellbeing", "self-care", "sleep", "relaxation", "spa", "holistic health", "lifestyle"]
        }
    }
}

// MARK: - Sample Data for Development
extension HealthNews {
    static let fitnessSampleData: [HealthNews] = [
        HealthNews(
            title: "10 Benefits of High-Intensity Interval Training (HIIT)",
            description: "Discover how HIIT workouts can transform your fitness routine and boost your metabolism in just 20 minutes.",
            url: "https://example.com/hiit-benefits",
            urlToImage: "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b",
            publishedAt: "2025-08-17T08:00:00Z",
            source: NewsSource(id: "fitness-mag", name: "Fitness Magazine"),
            author: "Sarah Johnson",
            content: "High-intensity interval training has revolutionized the fitness world..."
        ),
        HealthNews(
            title: "Strength Training for Beginners: Complete Guide",
            description: "Learn the fundamentals of weight lifting and how to build a sustainable strength training routine.",
            url: "https://example.com/strength-training-guide",
            urlToImage: "https://images.unsplash.com/photo-1583454110551-21f2fa2afe61",
            publishedAt: "2025-08-16T15:30:00Z",
            source: NewsSource(id: "muscle-fitness", name: "Muscle & Fitness"),
            author: "Mike Rodriguez",
            content: "Starting a strength training routine can be intimidating for beginners..."
        ),
        HealthNews(
            title: "Yoga vs Pilates: Which is Better for You?",
            description: "Compare the benefits of yoga and pilates to find the perfect mind-body workout for your goals.",
            url: "https://example.com/yoga-vs-pilates",
            urlToImage: "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b",
            publishedAt: "2025-08-15T12:00:00Z",
            source: NewsSource(id: "wellness-today", name: "Wellness Today"),
            author: "Emma Chen",
            content: "Both yoga and pilates offer unique benefits for physical and mental health..."
        )
    ]
    
    static let nutritionSampleData: [HealthNews] = [
        HealthNews(
            title: "The Complete Guide to Plant-Based Nutrition",
            description: "Everything you need to know about getting optimal nutrition from a plant-based diet.",
            url: "https://example.com/plant-based-nutrition",
            urlToImage: "https://images.unsplash.com/photo-1490645935967-10de6ba17061",
            publishedAt: "2025-08-17T10:15:00Z",
            source: NewsSource(id: "nutrition-news", name: "Nutrition News"),
            author: "Dr. Lisa Wang",
            content: "Plant-based diets are gaining popularity for their health and environmental benefits..."
        ),
        HealthNews(
            title: "Intermittent Fasting: Science-Based Benefits and Risks",
            description: "Explore the latest research on intermittent fasting and whether it's right for your lifestyle.",
            url: "https://example.com/intermittent-fasting",
            urlToImage: "https://images.unsplash.com/photo-1498837167922-ddd27525d352",
            publishedAt: "2025-08-16T09:45:00Z",
            source: NewsSource(id: "health-science", name: "Health Science"),
            author: "Dr. James Smith",
            content: "Intermittent fasting has shown promising results in clinical studies..."
        ),
        HealthNews(
            title: "Superfoods That Actually Live Up to the Hype",
            description: "Discover which superfoods provide real nutritional benefits and how to incorporate them into your diet.",
            url: "https://example.com/real-superfoods",
            urlToImage: "https://images.unsplash.com/photo-1610348725531-843dff563e2c",
            publishedAt: "2025-08-15T14:20:00Z",
            source: NewsSource(id: "nutrition-facts", name: "Nutrition Facts"),
            author: "Maria Garcia",
            content: "While many foods are marketed as superfoods, only some truly deserve the title..."
        )
    ]
    
    static let mentalHealthSampleData: [HealthNews] = [
        HealthNews(
            title: "5 Mindfulness Techniques to Reduce Daily Stress",
            description: "Simple, science-backed mindfulness practices you can do anywhere to manage stress and anxiety.",
            url: "https://example.com/mindfulness-stress",
            urlToImage: "https://images.unsplash.com/photo-1506905925346-21bda4d32df4",
            publishedAt: "2025-08-17T11:30:00Z",
            source: NewsSource(id: "mindful-living", name: "Mindful Living"),
            author: "Dr. Rachel Green",
            content: "Mindfulness meditation has been shown to significantly reduce stress levels..."
        ),
        HealthNews(
            title: "Understanding Depression: Signs, Symptoms, and Support",
            description: "A comprehensive guide to recognizing depression and finding appropriate help and treatment options.",
            url: "https://example.com/understanding-depression",
            urlToImage: "https://images.unsplash.com/photo-1573496359142-b8d87734a5a2",
            publishedAt: "2025-08-16T16:00:00Z",
            source: NewsSource(id: "mental-health-today", name: "Mental Health Today"),
            author: "Dr. David Thompson",
            content: "Depression affects millions of people worldwide, but effective treatments are available..."
        ),
        HealthNews(
            title: "The Power of Positive Psychology in Daily Life",
            description: "Learn how positive psychology principles can improve your mental well-being and overall life satisfaction.",
            url: "https://example.com/positive-psychology",
            urlToImage: "https://images.unsplash.com/photo-1522202176988-66273c2fd55f",
            publishedAt: "2025-08-15T13:45:00Z",
            source: NewsSource(id: "psychology-weekly", name: "Psychology Weekly"),
            author: "Dr. Amy Liu",
            content: "Positive psychology focuses on what makes life worth living and how to flourish..."
        )
    ]
    
    static let wellnessSampleData: [HealthNews] = [
        HealthNews(
            title: "Creating the Perfect Sleep Sanctuary for Better Rest",
            description: "Transform your bedroom into a sleep-optimized environment for deeper, more restorative sleep.",
            url: "https://example.com/sleep-sanctuary",
            urlToImage: "https://images.unsplash.com/photo-1586953208448-b95a79798f07",
            publishedAt: "2025-08-17T07:00:00Z",
            source: NewsSource(id: "sleep-wellness", name: "Sleep & Wellness"),
            author: "Dr. Sleep Specialist",
            content: "Quality sleep is fundamental to overall health and well-being..."
        ),
        HealthNews(
            title: "The Art of Self-Care: Beyond Bubble Baths",
            description: "Discover meaningful self-care practices that nourish your mind, body, and spirit.",
            url: "https://example.com/authentic-self-care",
            urlToImage: "https://images.unsplash.com/photo-1571731956672-f2b94d7dd0cb",
            publishedAt: "2025-08-16T18:30:00Z",
            source: NewsSource(id: "wellness-hub", name: "Wellness Hub"),
            author: "Caroline Johnson",
            content: "True self-care goes beyond trendy wellness products and involves genuine self-nurturing..."
        ),
        HealthNews(
            title: "Digital Detox: Reclaiming Your Mental Space",
            description: "Learn how to create healthy boundaries with technology for improved focus and well-being.",
            url: "https://example.com/digital-detox",
            urlToImage: "https://images.unsplash.com/photo-1516321497487-e288fb19713f",
            publishedAt: "2025-08-15T20:00:00Z",
            source: NewsSource(id: "modern-wellness", name: "Modern Wellness"),
            author: "Tech Wellness Expert",
            content: "Our constant connection to digital devices can overwhelm our mental capacity..."
        )
    ]
    
    static let allSampleData: [HealthNews] = 
        fitnessSampleData + nutritionSampleData + mentalHealthSampleData + wellnessSampleData
    
    // Legacy sample data for backwards compatibility
    static let sampleData: [HealthNews] = allSampleData
}
