import SwiftUI

struct HealthNewsView: View {
    @StateObject private var newsService = HealthNewsService()
    @State private var selectedCategory: NewsCategory = .all
    @State private var searchText = ""
    @State private var showingArticleDetail = false
    @State private var selectedArticle: HealthNews?
    
    var filteredNews: [HealthNews] {
        if searchText.isEmpty {
            return newsService.news
        } else {
            return newsService.news.filter { article in
                article.title.localizedCaseInsensitiveContains(searchText) ||
                article.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header with Categories
                VStack(spacing: 16) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search health news...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                        
                        if !searchText.isEmpty {
                            Button("Clear") {
                                searchText = ""
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                    
                    // Category Picker
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(NewsCategory.allCases, id: \.self) { category in
                                Button(action: {
                                    selectedCategory = category
                                    newsService.loadNews(category: category)
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: category.icon)
                                            .font(.system(size: 12, weight: .medium))
                                        
                                        Text(category.displayName)
                                            .font(.system(size: 14, weight: .medium))
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(selectedCategory == category ? Color.blue : Color.gray.opacity(0.1))
                                    )
                                    .foregroundColor(selectedCategory == category ? .white : .primary)
                                }
                                .scaleEffect(selectedCategory == category ? 1.05 : 1.0)
                                .animation(.easeInOut(duration: 0.2), value: selectedCategory)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.top, 10)
                .padding(.bottom, 16)
                .background(Color(UIColor.systemGroupedBackground))
                
                // News Content
                if newsService.isLoading {
                    Spacer()
                    ProgressView("Loading health news...")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Spacer()
                } else if filteredNews.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "newspaper")
                            .font(.system(size: 50))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("No News Found")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Try adjusting your search or check back later")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    Spacer()
                } else {
                    List(filteredNews) { article in
                        NewsRowView(article: article)
                            .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
                            .listRowSeparator(.hidden)
                            .onTapGesture {
                                selectedArticle = article
                                showingArticleDetail = true
                            }
                    }
                    .listStyle(PlainListStyle())
                    .refreshable {
                        newsService.refreshNews(category: selectedCategory)
                    }
                }
                
                if let errorMessage = newsService.errorMessage {
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.orange)
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Health News")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        newsService.refreshNews(category: selectedCategory)
                    }) {
                        Image(systemName: newsService.isLoading ? "arrow.clockwise" : "arrow.clockwise")
                            .rotationEffect(.degrees(newsService.isLoading ? 360 : 0))
                            .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: newsService.isLoading)
                    }
                    .disabled(newsService.isLoading)
                }
            }
            .sheet(isPresented: $showingArticleDetail) {
                if let article = selectedArticle {
                    NewsDetailView(article: article)
                }
            }
            .onAppear {
                if newsService.news.isEmpty {
                    newsService.loadNews(category: selectedCategory)
                }
            }
            .onChange(of: searchText) { newValue in
                if !newValue.isEmpty {
                    newsService.searchNews(query: newValue)
                }
            }
        }
    }
}

struct NewsRowView: View {
    let article: HealthNews
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                // Article Image
                AsyncImageView(
                    url: URL(string: article.urlToImage ?? ""),
                    placeholder: "photo"
                )
                .frame(width: 80, height: 80)
                .cornerRadius(12)
                .clipped()
                
                VStack(alignment: .leading, spacing: 6) {
                    // Source and Date
                    HStack {
                        Text(article.source.name)
                            .font(.caption)
                            .foregroundColor(.blue)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Text(article.formattedDate)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    // Title
                    Text(article.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    // Description
                    Text(article.description)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}

struct NewsDetailView: View {
    let article: HealthNews
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header Image
                    if let imageUrl = article.urlToImage, let url = URL(string: imageUrl) {
                        AsyncImageView(url: url, placeholder: "photo")
                            .frame(height: 250)
                            .cornerRadius(16)
                            .clipped()
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // Source and Date
                        HStack {
                            Text(article.source.name)
                                .font(.subheadline)
                                .foregroundColor(.blue)
                                .fontWeight(.medium)
                            
                            Spacer()
                            
                            Text(article.formattedDate)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        // Title
                        Text(article.title)
                            .font(.title)
                            .fontWeight(.bold)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        // Author
                        if let author = article.author {
                            Text("By \(author)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        // Description
                        Text(article.description)
                            .font(.body)
                            .foregroundColor(.primary)
                        
                        // Content
                        if let content = article.content {
                            Text(content)
                                .font(.body)
                                .foregroundColor(.primary)
                        }
                        
                        // Read More Button
                        Button(action: {
                            if let url = URL(string: article.url) {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            HStack {
                                Text("Read Full Article")
                                    .font(.system(size: 16, weight: .semibold))
                                
                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 14))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.blue)
                            )
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 50)
                }
            }
            .navigationTitle("Article")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    HealthNewsView()
}
