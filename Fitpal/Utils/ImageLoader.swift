import SwiftUI
import Combine

// MARK: - Async Image Loader
@MainActor
class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    @Published var isLoading = false
    
    private var cancellables = Set<AnyCancellable>()
    private static let imageCache = NSCache<NSString, UIImage>()
    
    func loadImage(from url: URL) {
        let urlString = url.absoluteString
        
        // Check cache first
        if let cachedImage = Self.imageCache.object(forKey: urlString as NSString) {
            self.image = cachedImage
            return
        }
        
        isLoading = true
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loadedImage in
                self?.isLoading = false
                self?.image = loadedImage
                
                // Cache the image
                if let image = loadedImage {
                    Self.imageCache.setObject(image, forKey: urlString as NSString)
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Async Image View
struct AsyncImageView: View {
    let url: URL?
    let placeholder: String
    
    @StateObject private var imageLoader = ImageLoader()
    
    var body: some View {
        Group {
            if let image = imageLoader.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if imageLoader.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.gray.opacity(0.1))
            } else {
                Image(systemName: placeholder)
                    .font(.system(size: 30))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.gray.opacity(0.1))
            }
        }
        .onAppear {
            if let url = url {
                imageLoader.loadImage(from: url)
            }
        }
    }
}

#Preview {
    AsyncImageView(
        url: URL(string: "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b"),
        placeholder: "photo"
    )
    .frame(width: 100, height: 100)
    .cornerRadius(10)
}
