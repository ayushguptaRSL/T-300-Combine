import Foundation

nonisolated enum SectionType: Hashable {
    case searchResult
}

struct SearchResult: Codable, Hashable {
    let products: [SearchItem]
    let total: Int
    let skip: Int
    let limit: Int
}

nonisolated struct SearchItem: Codable, Hashable, Identifiable {
    let id: Int
    let title: String
    let description: String
    let category: String
    let price: Double
    let thumbnail: String
}
