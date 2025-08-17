# Health News API Integration Guide

## Overview
This guide explains how to integrate real health news APIs into your Fitpal app. The current implementation uses sample data but can easily be switched to real APIs.

## Supported APIs

### 1. NewsAPI.org (Recommended)
- **Free Tier**: 1,000 requests/day
- **Coverage**: Global news sources
- **Features**: Search, filtering, multiple languages

#### Setup Steps:
1. Visit [newsapi.org](https://newsapi.org)
2. Sign up for a free account
3. Get your API key from the dashboard
4. Update `HealthNewsService.swift`:
   ```swift
   private let apiKey = "YOUR_ACTUAL_API_KEY_HERE"
   private let useSampleData = false
   ```

#### Example API Call:
```
GET https://newsapi.org/v2/everything?q=health&language=en&sortBy=publishedAt&pageSize=20&apiKey=YOUR_API_KEY
```

### 2. Guardian API
- **Free Tier**: Unlimited requests with rate limits
- **Coverage**: The Guardian newspaper
- **Features**: Rich content, high-quality articles

#### Setup Steps:
1. Visit [open-platform.theguardian.com](https://open-platform.theguardian.com)
2. Register for an API key
3. Implement in `HealthNewsService.swift`:
   ```swift
   func fetchNewsFromGuardian(category: String = "wellness") {
       let urlString = "https://content.guardianapis.com/search?section=\(category)&show-fields=thumbnail,headline,body&api-key=YOUR_GUARDIAN_API_KEY"
       // Implementation
   }
   ```

### 3. RSS Feeds (Free Alternative)
- **Cost**: Completely free
- **Sources**: Mayo Clinic, WebMD, Healthline
- **Limitations**: Less structured data

#### Popular Health RSS Feeds:
- Mayo Clinic: `https://www.mayoclinic.org/rss`
- WebMD: `https://rss.webmd.com/rss/rss.aspx?RSSSource=RSS_PUBLIC`
- Healthline: `https://www.healthline.com/rss`

## Implementation Features

### Current Features ✅
- [x] Multiple news categories (Health, Fitness, Nutrition, etc.)
- [x] Search functionality
- [x] Image caching system
- [x] Pull-to-refresh
- [x] Offline fallback with sample data
- [x] Article detail view
- [x] External link integration
- [x] Error handling
- [x] Loading states

### API Configuration
```swift
// In HealthNewsService.swift
class HealthNewsService: ObservableObject {
    private let baseURL = "https://newsapi.org/v2"
    private let apiKey = "YOUR_API_KEY" // Replace this
    private let useSampleData = false   // Set to false for real API
}
```

### Error Handling
The service includes comprehensive error handling:
- Network errors
- API rate limiting
- Invalid API keys
- Fallback to sample data

### Caching System
Images are automatically cached using `NSCache`:
- Reduces bandwidth usage
- Improves performance
- Automatic memory management

## Testing

### 1. Sample Data Testing
- Set `useSampleData = true`
- No API key required
- Perfect for development and testing

### 2. API Testing
- Set `useSampleData = false`
- Add your API key
- Test with real data

### 3. Error Testing
- Use invalid API key
- Test network offline scenarios
- Verify fallback behavior

## Best Practices

### 1. API Key Security
```swift
// Don't commit API keys to version control
// Use environment variables or config files
#if DEBUG
private let apiKey = "development_api_key"
#else
private let apiKey = "production_api_key"
#endif
```

### 2. Rate Limiting
```swift
// Implement request throttling
private var lastRequestTime: Date?
private let minimumRequestInterval: TimeInterval = 1.0
```

### 3. Offline Support
```swift
// Always provide fallback content
private func loadSampleData() {
    DispatchQueue.main.async {
        self.news = HealthNews.sampleData
        self.isLoading = false
    }
}
```

## Customization

### Adding New Categories
```swift
enum NewsCategory: String, CaseIterable {
    case general = "health"
    case fitness = "fitness"
    case nutrition = "nutrition"
    case mentalHealth = "mental-health"
    case wellness = "wellness"
    case newCategory = "new-category" // Add here
}
```

### Custom News Sources
```swift
func fetchFromCustomSource() {
    let customURL = "https://your-custom-api.com/health-news"
    // Implementation
}
```

## Troubleshooting

### Common Issues
1. **No data loading**: Check API key and network connection
2. **Images not showing**: Verify image URLs and network permissions
3. **Rate limiting**: Implement request throttling
4. **Parse errors**: Validate API response format

### Debug Mode
```swift
#if DEBUG
print("API Response: \(response)")
print("Error: \(error)")
#endif
```

## Integration Checklist

- [ ] Choose your API provider
- [ ] Get API key
- [ ] Update `apiKey` in `HealthNewsService.swift`
- [ ] Set `useSampleData = false`
- [ ] Test with real data
- [ ] Implement error handling
- [ ] Add offline support
- [ ] Test on device
- [ ] Submit to App Store

## Next Steps

1. **Get API Key**: Sign up for NewsAPI.org
2. **Replace Sample Data**: Update the service configuration
3. **Test Integration**: Verify real data loading
4. **Enhance Features**: Add bookmarking, sharing, push notifications
5. **Monitor Usage**: Track API quotas and performance

## Support

For additional help:
- NewsAPI Documentation: [newsapi.org/docs](https://newsapi.org/docs)
- Guardian API Documentation: [open-platform.theguardian.com/documentation](https://open-platform.theguardian.com/documentation)
- Contact the development team for custom implementations
