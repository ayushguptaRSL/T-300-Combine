import UIKit

class SearchItemView: UITableViewCell {
    static let identifier = "SearchItemCell"

    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .systemGray6
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .systemGreen
        return label
    }()
    
    private let categoryContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 215/255, green: 231/255, blue: 231/255, alpha: 0.6)
        return view
    }()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 11, weight: .semibold)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private var imageTask: URLSessionDataTask?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()
        imageTask = nil
        thumbnailImageView.image = nil
        titleLabel.text = nil
        descriptionLabel.text = nil
        priceLabel.text = nil
        categoryLabel.text = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        categoryContainerView.layer.cornerRadius = categoryContainerView.frame.height / 2
    }

    private func setupViews() {
        categoryContainerView.addSubview(categoryLabel)

        let textStackView = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
        textStackView.translatesAutoresizingMaskIntoConstraints = false
        textStackView.axis = .vertical
        textStackView.spacing = 4
        textStackView.alignment = .leading

        let sideStackView = UIStackView(arrangedSubviews: [priceLabel, categoryContainerView])
        sideStackView.translatesAutoresizingMaskIntoConstraints = false
        sideStackView.axis = .vertical
        sideStackView.spacing = 6
        sideStackView.alignment = .trailing
        sideStackView.setContentCompressionResistancePriority(.required, for: .horizontal)
        sideStackView.setContentHuggingPriority(.required, for: .horizontal)

        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(textStackView)
        contentView.addSubview(sideStackView)

        NSLayoutConstraint.activate([
            thumbnailImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            thumbnailImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            thumbnailImageView.widthAnchor.constraint(equalToConstant: 48),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: 48),
            thumbnailImageView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 12),
            thumbnailImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12),

            textStackView.leadingAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor, constant: 12),
            textStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            textStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            textStackView.trailingAnchor.constraint(equalTo: sideStackView.leadingAnchor, constant: -12),

            sideStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            sideStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            categoryLabel.topAnchor.constraint(equalTo: categoryContainerView.topAnchor, constant: 4),
            categoryLabel.bottomAnchor.constraint(equalTo: categoryContainerView.bottomAnchor, constant: -4),
            categoryLabel.leadingAnchor.constraint(equalTo: categoryContainerView.leadingAnchor, constant: 8),
            categoryLabel.trailingAnchor.constraint(equalTo: categoryContainerView.trailingAnchor, constant: -8)
        ])
    }

    func configure(for item: SearchItem) {
        titleLabel.text = item.title
        descriptionLabel.text = item.description
        categoryLabel.text = item.category.uppercased()
        priceLabel.text = String(format: "$%.2f", item.price)

        if let url = URL(string: item.thumbnail) {
            imageTask = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                guard let self = self, let data = data, error == nil, let image = UIImage(data: data) else { return }
                DispatchQueue.main.async {
                    self.thumbnailImageView.image = image
                }
            }
            imageTask?.resume()
        }
    }
}
