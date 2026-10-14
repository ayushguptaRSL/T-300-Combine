import UIKit
import Foundation
import Combine

class SearchViewModel {
    let searchTextPublisher = PassthroughSubject<String, Never>()
    @Published private var result: [SearchItem] = []
    private var cancellables = Set<AnyCancellable>()
    private var decoder = JSONDecoder()
    
    init() {
        createSubscriber()
    }
    
    func sendUpdatedText(searchText: String) {
        searchTextPublisher.send(searchText)
    }
    
    private func createSubscriber() {
        searchTextPublisher
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .map({ [weak self] searchText -> AnyPublisher<[SearchItem], Never> in
                guard let self,
                      searchText.trimmingCharacters(in: .whitespacesAndNewlines).count >= 3,
                      let url = URL(string: "https://dummyjson.com/products/search?q=\(searchText)") else {
                    return Just([]).eraseToAnyPublisher()
                }
                
                return self.publisherForAPIResult(url: url)
            })
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (result: [SearchItem]) in
                guard let self else {
                    return
                }
                
                self.result = result
            }
            .store(in: &cancellables)
    }
    
    func subscribeToResult(completion: @escaping ([SearchItem])->Void) {
        $result.sink { _ in
            
        } receiveValue: { result in
            completion(result)
        }.store(in: &cancellables)
    }
    
    private func publisherForAPIResult(url: URL) -> AnyPublisher<[SearchItem], Never> {
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse,
                    200..<300 ~= response.statusCode else {
                    throw URLError(.badServerResponse)
                }

                return output.data
            }
            .retry(2)
            .decode(type: SearchResult.self, decoder: self.decoder)
            .map(\.products)
            .catch { error in
                NSLog(error.localizedDescription)
                return Just<[SearchItem]>([])
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
