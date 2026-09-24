import UIKit

protocol SearchViewDelegate: AnyObject {
    func searchView(didChangeSearchText text: String)
}

final class SearchView: UIView {
    weak var delegate: SearchViewDelegate?

    private let headerView: SearchHeaderView = {
        let view = SearchHeaderView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private lazy var dataSource: UITableViewDiffableDataSource<SectionType, SearchItem> = {
        return UITableViewDiffableDataSource<SectionType, SearchItem>(tableView: tableView) { tableView, indexPath, searchItem in
            let cell = tableView.dequeueReusableCell(withIdentifier: SearchItemView.identifier, for: indexPath) as? SearchItemView
            cell?.configure(for: searchItem)
            return cell
        }
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        configureDataSource()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func apply(results: [SearchItem], animatingDifferences: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<SectionType, SearchItem>()
        snapshot.appendSections([.searchResult])
        snapshot.appendItems(results, toSection: .searchResult)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }

    private func setupViews() {
        backgroundColor = .systemBackground
        headerView.delegate = self

        addSubview(headerView)
        addSubview(tableView)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            headerView.bottomAnchor.constraint(equalTo: tableView.topAnchor),

            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func configureDataSource() {
        tableView.register(SearchItemView.self, forCellReuseIdentifier: SearchItemView.identifier)
    }
}

extension SearchView: SearchHeaderViewDelegate {
    func searchHeaderView(changeSearchText text: String) {
        delegate?.searchView(didChangeSearchText: text)
    }
}
