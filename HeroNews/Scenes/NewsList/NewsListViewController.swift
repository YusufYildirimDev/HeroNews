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

    // MARK: - Search Controller
    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.placeholder = "Search news..."
        return sc
    }()

    // MARK: - TableView
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.rowHeight = Constants.rowHeight
        table.register(NewsCell.self, forCellReuseIdentifier: Constants.cellIdentifier)
        table.dataSource = self
        table.delegate = self
        return table
    }()

    // MARK: - Loading Indicator
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    // MARK: - Pull to Refresh
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
        bindViewModel()
        viewModel.loadNews()
        viewModel.startAutoRefresh()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.stopAutoRefresh()
    }

    // MARK: - Alerts
    private func showAddedToReadingListAlert() {
        let alert = UIAlertController(title: "Saved",
                                      message: "Added to Reading List",
                                      preferredStyle: .alert)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            alert.dismiss(animated: true)
        }
    }

    private func showRemovedFromReadingListAlert() {
        let alert = UIAlertController(title: "Removed",
                                      message: "Removed from Reading List",
                                      preferredStyle: .alert)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            alert.dismiss(animated: true)
        }
    }
}

// MARK: - UI Setup
private extension NewsListViewController {
    
    func setupUI() {
        title = Constants.screenTitle
        view.backgroundColor = .systemBackground

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        
        tableView.refreshControl = refreshControl
        
        NSLayoutConstraint.activate([
            // TableView
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Activity Indicator
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

// MARK: - Bind ViewModel
private extension NewsListViewController {
    
    func bindViewModel() {
        viewModel.onStateChanged = { [weak self] state in
            guard let self else { return }

            switch state {

            case .idle:
                break

            case .loading:
                self.setLoading(true)

            case .success:
                self.setLoading(false)
                self.endRefreshingIfNeeded()
                self.reloadTablePreservingScroll()

            case .updatedRows(let rows):
                self.tableView.reloadRows(at: rows, with: .automatic)

            case .error(let msg):
                self.setLoading(false)
                self.endRefreshingIfNeeded()
                self.showAlert(title: "Error", message: msg, buttonTitle: "OK")
            }
        }
    }

    func setLoading(_ isLoading: Bool) {
        if isLoading && !refreshControl.isRefreshing {
            activityIndicator.startAnimating()
            tableView.isUserInteractionEnabled = false
        } else {
            activityIndicator.stopAnimating()
            tableView.isUserInteractionEnabled = true
        }
    }

    func endRefreshingIfNeeded() {
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
    }

    /// Scroll pozisyonunu kaybetmeden reload eder
    private func reloadTablePreservingScroll() {
        let oldOffset = tableView.contentOffset

        UIView.performWithoutAnimation {
            tableView.reloadData()
            tableView.layoutIfNeeded()
        }

        tableView.setContentOffset(oldOffset, animated: false)
    }

    @objc func didPullToRefresh() {
        viewModel.loadNews()
    }
}

// MARK: - TableView
extension NewsListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: Constants.cellIdentifier,
            for: indexPath
        ) as? NewsCell else { return UITableViewCell() }

        let vm = viewModel.articleViewModel(at: indexPath.row)
        cell.configure(with: vm)
        cell.delegate = self

        return cell
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let article = viewModel.article(at: indexPath.row)
        let vm = NewsDetailViewModel(article: article)
        navigationController?.pushViewController(
            NewsDetailViewController(viewModel: vm),
            animated: true
        )
    }
}

// MARK: - Search
extension NewsListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.search(searchController.searchBar.text)
    }
}

// MARK: - Reading List
extension NewsListViewController: NewsCellDelegate {

    func didTapReadingListButton(on cell: NewsCell) {
        guard let index = tableView.indexPath(for: cell)?.row else { return }

        Task {
            let added = await viewModel.toggleReadingListStatus(at: index)

            if added {
                showAddedToReadingListAlert()
            } else {
                showRemovedFromReadingListAlert()
            }
        }
    }
}

// MARK: - Constants
private extension NewsListViewController {
    enum Constants {
        static let rowHeight: CGFloat = 130
        static let cellIdentifier = "NewsCell"
        static let screenTitle = "Startup Heroes News"
    }
}
