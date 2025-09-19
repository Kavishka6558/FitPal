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
            GeometryReader { geometry in
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                        // Modern Header Section
                        Section {
                            VStack(spacing: 24) {
                                // Hero Search Bar
                                VStack(spacing: 16) {
                                    HStack(spacing: 16) {
                                        HStack(spacing: 12) {
                                            Image(systemName: "magnifyingglass")
                                                .font(.system(size: 18, weight: .medium))
                                                .foregroundStyle(
                                                    LinearGradient(
                                                        colors: [.blue, .purple],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                            
                                            TextField("Discover health insights...", text: $searchText)
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.primary)
                                            
                                            if !searchText.isEmpty {
                                                Button {
                                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                                        searchText = ""
                                                    }
                                                } label: {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .font(.system(size: 16, weight: .medium))
                                                        .foregroundColor(.gray)
                                                }
                                            }
                                        }
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 16)
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(.ultraThinMaterial)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 20)
                                                        .stroke(
                                                            LinearGradient(
                                                                colors: [.white.opacity(0.3), .clear],
                                                                startPoint: .topLeading,
                                                                endPoint: .bottomTrailing
                                                            ),
                                                            lineWidth: 1
                                                        )
                                                )
                                        )
                                        .shadow(color: .black.opacity(0.08), radius: 15, x: 0, y: 8)
                                    }
                                    .padding(.horizontal, 24)
                                }
                                
                                // Modern Category Picker
                                ScrollView(.horizontal, showsIndicators: false) {
                                    LazyHStack(spacing: 14) {
                                        ForEach(NewsCategory.allCases, id: \.self) { category in
                                            Button {
                                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                                    selectedCategory = category
                                                    newsService.loadNews(category: category)
                                                }
                                            } label: {
                                                HStack(spacing: 10) {
                                                    Image(systemName: category.icon)
                                                        .font(.system(size: 14, weight: .semibold))
                                                    
                                                    Text(category.displayName)
                                                        .font(.system(size: 15, weight: .semibold))
                                                }
                                                .padding(.horizontal, 20)
                                                .padding(.vertical, 12)
                                                .background(
                                                    Group {
                                                        if selectedCategory == category {
                                                            RoundedRectangle(cornerRadius: 25)
                                                                .fill(
                                                                    LinearGradient(
                                                                        colors: [.blue, .purple],
                                                                        startPoint: .topLeading,
                                                                        endPoint: .bottomTrailing
                                                                    )
                                                                )
                                                                .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                                                        } else {
                                                            RoundedRectangle(cornerRadius: 25)
                                                                .fill(.thinMaterial)
                                                                .overlay(
                                                                    RoundedRectangle(cornerRadius: 25)
                                                                        .stroke(.white.opacity(0.2), lineWidth: 1)
                                                                )
                                                        }
                                                    }
                                                )
                                                .foregroundColor(selectedCategory == category ? .white : .primary)
                                                .scaleEffect(selectedCategory == category ? 1.05 : 1.0)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                    .padding(.horizontal, 24)
                                }
                                .padding(.bottom, 8)
                            }
                            .padding(.vertical, 20)
                            .background(
                                Rectangle()
                                    .fill(.ultraThinMaterial)
                                    .ignoresSafeArea()
                            )
                        } header: {
                            EmptyView()
                        }
                        
                        // Content Section
                        Section {
                            if newsService.isLoading {
                                VStack(spacing: 24) {
                                    ProgressView()
                                        .scaleEffect(1.2)
                                        .tint(.blue)
                                    
                                    Text("Discovering health insights...")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                                .frame(height: 300)
                                .frame(maxWidth: .infinity)
                                
                            } else if filteredNews.isEmpty {
                                VStack(spacing: 24) {
                                    ZStack {
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 120, height: 120)
                                        
                                        Image(systemName: "newspaper")
                                            .font(.system(size: 50, weight: .light))
                                            .foregroundStyle(
                                                LinearGradient(
                                                    colors: [.blue, .purple],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                    }
                                    
                                    VStack(spacing: 12) {
                                        Text("No News Found")
                                            .font(.system(size: 22, weight: .bold))
                                            .foregroundColor(.primary)
                                        
                                        Text("Try adjusting your search or check back later for the latest health insights")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.secondary)
                                            .multilineTextAlignment(.center)
                                            .lineLimit(3)
                                    }
                                }
                                .padding(.horizontal, 32)
                                .frame(height: 300)
                                .frame(maxWidth: .infinity)
                                
                            } else {
                                LazyVStack(spacing: 16) {
                                    ForEach(filteredNews) { article in
                                        NewsRowView(article: article)
                                            .onTapGesture {
                                                selectedArticle = article
                                                showingArticleDetail = true
                                            }
                                    }
                                }
                                .padding(.horizontal, 24)
                                .padding(.vertical, 16)
                            }
                            
                            // Error Message
                            if let errorMessage = newsService.errorMessage {
                                HStack(spacing: 12) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.orange)
                                    
                                    Text(errorMessage)
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(.primary)
                                        .multilineTextAlignment(.leading)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(.orange.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(.orange.opacity(0.3), lineWidth: 1)
                                        )
                                )
                                .padding(.horizontal, 24)
                                .padding(.bottom, 16)
                            }
                        } header: {
                            EmptyView()
                        }
                    }
                }
                .refreshable {
                    newsService.refreshNews(category: selectedCategory)
                }
            }
            .navigationTitle("Health News")
            .navigationBarTitleDisplayMode(.large)
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
    @State private var imageLoaded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 16) {
                // Modern Article Image
                AsyncImageView(
                    url: URL(string: article.urlToImage ?? ""),
                    placeholder: "photo"
                )
                .frame(width: 90, height: 90)
                .cornerRadius(16)
                .clipped()
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.5).delay(0.1)) {
                        imageLoaded = true
                    }
                }
                .scaleEffect(imageLoaded ? 1 : 0.8)
                .opacity(imageLoaded ? 1 : 0.8)
                
                VStack(alignment: .leading, spacing: 8) {
                    // Source and Date Header
                    HStack(spacing: 8) {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 6, height: 6)
                            
                            Text(article.source.name)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        }
                        
                        Spacer()
                        
                        Text(article.formattedDate)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    // Modern Title
                    Text(article.title)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Enhanced Description
                    Text(article.description)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Spacer(minLength: 4)
                    
                    // Read More Indicator
                    HStack {
                        Spacer()
                        
                        HStack(spacing: 6) {
                            Text("Read more")
                                .font(.system(size: 13, weight: .semibold))
                            
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 11, weight: .bold))
                        }
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    }
                }
                .padding(.vertical, 2)
            }
            .padding(20)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.regularMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.3), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 6)
    }
}

struct NewsDetailView: View {
    let article: HealthNews
    @Environment(\.dismiss) private var dismiss
    @State private var scrollOffset: CGFloat = 0
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 0) {
                        // Hero Image Section
                        if let imageUrl = article.urlToImage, let url = URL(string: imageUrl) {
                            GeometryReader { proxy in
                                AsyncImageView(url: url, placeholder: "photo")
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: proxy.size.width, height: proxy.size.height)
                                    .clipped()
                                    .overlay(
                                        LinearGradient(
                                            colors: [.clear, .black.opacity(0.3)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                            }
                            .frame(height: 300)
                            .cornerRadius(0)
                        }
                        
                        // Content Section
                        VStack(alignment: .leading, spacing: 20) {
                            VStack(alignment: .leading, spacing: 16) {
                                // Source and Date
                                HStack(spacing: 12) {
                                    HStack(spacing: 8) {
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [.blue, .purple],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 8, height: 8)
                                        
                                        Text(article.source.name)
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundStyle(
                                                LinearGradient(
                                                    colors: [.blue, .purple],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                    }
                                    
                                    Spacer()
                                    
                                    Text(article.formattedDate)
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                                
                                // Title
                                Text(article.title)
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .lineLimit(nil)
                                
                                // Author
                                if let author = article.author {
                                    HStack(spacing: 8) {
                                        Image(systemName: "person.circle")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.secondary)
                                        
                                        Text("By \(author)")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            
                            Divider()
                                .background(.tertiary)
                            
                            // Description
                            Text(article.description)
                                .font(.system(size: 18, weight: .regular))
                                .foregroundColor(.primary)
                                .lineSpacing(4)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            // Content
                            if let content = article.content {
                                Text(content)
                                    .font(.system(size: 17, weight: .regular))
                                    .foregroundColor(.primary)
                                    .lineSpacing(6)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            
                            // Modern CTA Button
                            Button {
                                if let url = URL(string: article.url) {
                                    UIApplication.shared.open(url)
                                }
                            } label: {
                                HStack(spacing: 12) {
                                    Text("Read Full Article")
                                        .font(.system(size: 17, weight: .bold))
                                    
                                    Image(systemName: "arrow.up.right")
                                        .font(.system(size: 16, weight: .bold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(
                                            LinearGradient(
                                                colors: [.blue, .purple],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .shadow(color: .blue.opacity(0.3), radius: 12, x: 0, y: 6)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.top, 12)
                            
                            Spacer(minLength: 50)
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 24)
                        .background(.ultraThinMaterial)
                    }
                }
            }
            .navigationTitle("Article")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.secondary, .thinMaterial)
                    }
                }
            }
        }
    }
}

#Preview {
    HealthNewsView()
}
