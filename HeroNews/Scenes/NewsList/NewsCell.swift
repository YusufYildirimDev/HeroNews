//
//  NewsCell.swift
//  HeroNews
//
//  Created by Yusuf Muhammet Yıldırım on 12/11/25.
//

import UIKit

protocol NewsCellDelegate: AnyObject {
    func didTapReadingListButton(on cell: NewsCell)
}

final class NewsCell: UITableViewCell {
    
    // MARK: - Delegate
    weak var delegate: NewsCellDelegate?
    
    // MARK: - State
    private var currentImageURL: URL?
    private var downloadTask: Task<Void, Never>?
    
    // MARK: - UI Metrics
    private enum Metrics {
        static let padding: CGFloat = 12
        static let imageSize: CGFloat = 100
        static let buttonSize: CGFloat = 30
    }

    // MARK: - UI Components
    private let newsImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 8
        iv.contentMode = .scaleAspectFit
        iv.backgroundColor = .secondarySystemBackground
        return iv
    }()
    
    private let titleLabel = UILabel().apply {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .systemFont(ofSize: 15, weight: .bold)
        $0.numberOfLines = 2
        $0.textColor = .label
    }
    
    private let descriptionLabel = UILabel().apply {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .systemFont(ofSize: 13)
        $0.textColor = .secondaryLabel
        $0.numberOfLines = 2
    }
    
    /// Explicit creator/author label (required by case)
    private let creatorLabel = UILabel().apply {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .systemFont(ofSize: 11, weight: .semibold)
        $0.textColor = .label
        $0.numberOfLines = 1
    }
    
    /// Shows only date text (e.g. "3 hours ago")
    private let metaLabel = UILabel().apply {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .systemFont(ofSize: 11, weight: .medium)
        $0.textColor = .systemGray
        $0.numberOfLines = 1
    }
    
    private let readingListButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "bookmark")
        config.preferredSymbolConfigurationForImage = .init(pointSize: 18, weight: .medium)

        let btn = UIButton(configuration: config)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.tintColor = .systemGray
        return btn
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupLayout()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Görsel reset
        newsImageView.image = UIImage(systemName: "photo")
        newsImageView.tintColor = .systemGray4
        newsImageView.contentMode = .scaleAspectFit
        
        titleLabel.text = nil
        descriptionLabel.text = nil
        creatorLabel.text = nil
        metaLabel.text = nil
        
        currentImageURL = nil
        downloadTask?.cancel()
        downloadTask = nil
        
        updateButtonState(isSaved: false)
    }
    
    // MARK: - Configure
    func configure(with vm: ArticleViewModel) {
        titleLabel.text = vm.title
        descriptionLabel.text = vm.summary
        creatorLabel.text = vm.creator
        metaLabel.text = vm.dateText
        
        updateButtonState(isSaved: vm.isSaved)
        
        guard let url = vm.imageURL else { return }
        currentImageURL = url
        
        downloadTask = Task { [weak self] in
            guard let self = self else { return }
            
            if let image = await ImageLoader.shared.downloadImage(url: url),
               self.currentImageURL == url {
                await MainActor.run {
                    self.newsImageView.image = image
                    self.newsImageView.tintColor = nil
                    self.newsImageView.contentMode = .scaleAspectFill
                }
            }
        }
    }
}

// MARK: - UI Setup
private extension NewsCell {
    
    func setupViews() {
        selectionStyle = .none
        
        contentView.addSubviews(
            newsImageView,
            titleLabel,
            descriptionLabel,
            creatorLabel,
            metaLabel,
            readingListButton
        )
        
        readingListButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            
            // Image
            newsImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metrics.padding),
            newsImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            newsImageView.widthAnchor.constraint(equalToConstant: Metrics.imageSize),
            newsImageView.heightAnchor.constraint(equalToConstant: Metrics.imageSize),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: newsImageView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: newsImageView.trailingAnchor, constant: Metrics.padding),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Metrics.padding),
            
            // Description
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            // Reading List Button
            readingListButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Metrics.padding),
            readingListButton.bottomAnchor.constraint(equalTo: newsImageView.bottomAnchor),
            readingListButton.widthAnchor.constraint(equalToConstant: Metrics.buttonSize),
            readingListButton.heightAnchor.constraint(equalToConstant: Metrics.buttonSize),
            
            // Creator
            creatorLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 4),
            creatorLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            creatorLabel.trailingAnchor.constraint(lessThanOrEqualTo: readingListButton.leadingAnchor, constant: -8),
            
            // Meta (date)
            metaLabel.topAnchor.constraint(equalTo: creatorLabel.bottomAnchor, constant: 2),
            metaLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            metaLabel.trailingAnchor.constraint(lessThanOrEqualTo: readingListButton.leadingAnchor, constant: -8),
            metaLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -Metrics.padding)
        ])
    }
    
    func updateButtonState(isSaved: Bool) {
        var config = readingListButton.configuration
        config?.title = nil
        config?.image = UIImage(systemName: isSaved ? "bookmark.fill" : "bookmark")
        readingListButton.configuration = config
    }
    
    @objc func didTapButton() {
        delegate?.didTapReadingListButton(on: self)
    }
}

// MARK: - UIView helper
private extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
}

// MARK: - UILabel Builder helper
private extension UILabel {
    func apply(_ updates: (UILabel) -> Void) -> UILabel {
        updates(self)
        return self
    }
}
