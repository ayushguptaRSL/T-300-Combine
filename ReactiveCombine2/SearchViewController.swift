import UIKit

class SearchViewController: UIViewController {
    private let viewModel = SearchViewModel()

    private lazy var searchView: SearchView = {
        let view = SearchView()
        view.delegate = self
        return view
    }()

    override func loadView() {
        view = searchView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Search"
        viewModel.subscribeToResult { [weak self] results in
            self?.searchView.apply(results: results)
        }
    }
}

extension SearchViewController: SearchViewDelegate {
    func searchView(didChangeSearchText text: String) {
        viewModel.sendUpdatedText(searchText: text)
    }
}
