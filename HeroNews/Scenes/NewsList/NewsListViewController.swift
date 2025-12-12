//
//  NewsListViewController.swift
//  HeroNews
//
//  Created by Yusuf Muhammet Yıldırım on 12/11/25.
//

import UIKit

final class NewsListViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: NewsListViewModel

    // MARK: - UI Components
    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.placeholder = "Search news..."
        sc.searchBar.tintColor = .label
        return sc
    }()

    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.rowHeight = Constants.rowHeight
        table.separatorStyle = .singleLine
        table.backgroundColor = .systemBackground
        table.register(NewsCell.self, forCellReuseIdentifier: Constants.cellIdentifier)
        return table
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        return control
    }()

    // MARK: - Init
    init(viewModel: NewsListViewModel = NewsListViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = NewsListViewModel()
        super.init(coder: coder)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        bindViewModel()
        
        // Initial Fetch
        viewModel.loadNews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.startAutoRefresh()
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.stopAutoRefresh()
    }
}

// MARK: - UI Setup
private extension NewsListViewController {
    
    func setupUI() {
        title = Constants.screenTitle
        view.backgroundColor = .systemBackground
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = refreshControl
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

// MARK: - ViewModel Binding
private extension NewsListViewController {
    
    func bindViewModel() {
        viewModel.onStateChanged = { [weak self] state in
            guard let self = self else { return }
            
            switch state {
            case .idle:
                break
                
            case .loading:
                self.setLoading(true)
                
            case .success:
                self.setLoading(false)
                self.reloadTablePreservingScroll()
                
            case .newHeadlinesFetched:
                self.reloadTablePreservingScroll()
                self.showToast(message: "New headlines added")
                
            case .updatedRows(let indexPaths):
                self.tableView.reloadRows(at: indexPaths, with: .none)
                
            case .error(let message):
                self.setLoading(false)
                // Only show alert if it's a user-initiated action, not background refresh
                if !self.viewModel.isSilentRefreshActive {
                    self.showAlert(title: Constants.errorTitle, message: message)
                }
            }
        }
    }
    
    func setLoading(_ isLoading: Bool) {
        if isLoading && !refreshControl.isRefreshing {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
            refreshControl.endRefreshing()
        }
    }
    
    func reloadTablePreservingScroll() {
        if refreshControl.isRefreshing {
            tableView.reloadData()
            refreshControl.endRefreshing()
            return
        }
        
        let contentOffset = tableView.contentOffset
        tableView.reloadData()
        tableView.layoutIfNeeded()
        tableView.setContentOffset(contentOffset, animated: false)
    }
    
    @objc func didPullToRefresh() {
        viewModel.loadNews()
    }
}

// MARK: - UITableView Delegate & DataSource
extension NewsListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath) as? NewsCell else {
            return UITableViewCell()
        }
        
        let articleVM = viewModel.articleViewModel(at: indexPath.row)
        cell.configure(with: articleVM)
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let article = viewModel.article(at: indexPath.row)
        let detailVM = NewsDetailViewModel(article: article)
        let detailVC = NewsDetailViewController(viewModel: detailVM)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - Search Logic
extension NewsListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.search(searchController.searchBar.text)
    }
}

// MARK: - NewsCell Delegate
extension NewsListViewController: NewsCellDelegate {
    
    func didTapReadingListButton(on cell: NewsCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        Task {
            let isSaved = await viewModel.toggleReadingListStatus(at: indexPath.row)
            let message = isSaved ? "Added to Reading List" : "Removed from Reading List"
            self.showToast(message: message)
        }
    }
}

// MARK: - Constants & Extensions
extension NewsListViewModel {
    // Helper to determine if we should suppress error alerts
    var isSilentRefreshActive: Bool {
        return false // Simplified for this implementation
    }
}

private enum Constants {
    static let rowHeight: CGFloat = 130
    static let cellIdentifier = "NewsCell"
    static let screenTitle = "Startup Heroes News"
    static let errorTitle = "Error"
}
