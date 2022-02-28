import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import RxSwiftExt

class HomeViewController: UIViewController {
    // MARK: - Private
    private let viewModel: HomeViewModel
    private let disposeBag = DisposeBag()
    private let refreshControl: UIRefreshControl = {
        return UIRefreshControl()
    }()
    
    private lazy var toolBar: UIToolbar = {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = .black
        toolBar.sizeToFit()
        
        return toolBar
    }()
        
    
    lazy var indicatorView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        return indicator
    }()
    
    lazy var searchBar: UISearchBar = {
        let search = UISearchBar()
        search.searchBarStyle = UISearchBar.Style.default
        search.placeholder = "Please enter keyword"
        search.returnKeyType = .done
        search.inputAccessoryView = toolBar
        
        return search
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.refreshControl = refreshControl
        tableView.register(SearchResultCell.self, forCellReuseIdentifier: String(describing: SearchResultCell.self))
        
        return tableView
    }()
    
    lazy var noResultLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "End"
        label.textColor = .white
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    init(viewModel: HomeViewModel = HomeViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupToolbar()
        bindViewModel()
    }
    
    func bindViewModel() {
        let dataSource = RxTableViewSectionedReloadDataSource<Section>(
            configureCell: { dataSource, tableView, indexPath, item in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SearchResultCell.self), for: indexPath) as? SearchResultCell else {
                    return UITableViewCell()
                }
                
                cell.nameLabel.text = item.name
                
                if let url = URL(string: item.avatarURL) {
                    cell.accountImageView.setImage(url: url)
                }
                
                return cell
            })
        
        viewModel.result.asObservable()
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        searchBar.rx.searchButtonClicked
            .withLatestFrom(searchBar.rx.text)
            .compactMap { $0 }
            .bind(to: viewModel.searchText)
            .disposed(by: disposeBag)
        
        searchBar.rx.searchButtonClicked
            .subscribe(onNext: { [weak self] in
                self?.searchBar.resignFirstResponder()
            })
            .disposed(by: disposeBag)
        
        searchBar.rx.text
            .observe(on: MainScheduler.asyncInstance)
            .filter { $0 == "" }
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel.result.onNext([])
                self?.searchBar.resignFirstResponder()
            })
            .disposed(by: disposeBag)
        
        refreshControl.rx.controlEvent(.valueChanged)
            .withLatestFrom(searchBar.rx.text)
            .compactMap { $0 }
            .bind(to: viewModel.searchText)
            .disposed(by: disposeBag)
        
        viewModel.isFreshing
            .bind(to: refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)
        
        tableView.rx.reachedBottom(offset: 40)
            .withLatestFrom(searchBar.rx.text)
            .compactMap { $0 }
            .bind(to: viewModel.triggerNextPage)
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .bind(to: indicatorView.rx.isAnimating)
            .disposed(by: disposeBag)
        
        viewModel.searchRepositoriesFailure.asObservable()
            .subscribe(onNext:{ [weak self] error in
                let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                self?.present(alertController, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        viewModel.searchRepositoriesNoResult.asObservable().debug("🦄")
            .subscribe(onNext: { [weak self] isNoResult in
                if isNoResult {
                    self?.noResultLabel.isHidden = false
                } else {
                    self?.noResultLabel.isHidden = true
                }
            })
            .disposed(by: disposeBag)
    }
    
    func setupToolbar() {
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: nil)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: nil)
        
        doneButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.searchBar.resignFirstResponder()
            })
            .disposed(by: disposeBag)
        
        cancelButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.searchBar.resignFirstResponder()
            })
            .disposed(by: disposeBag)
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
    }
}

extension HomeViewController {
    func setupUI() {
        view.backgroundColor = .white
        
        navigationItem.titleView = searchBar
        view.addSubview(tableView)
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        footerView.addSubview(indicatorView)
        footerView.addSubview(noResultLabel)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            indicatorView.centerXAnchor.constraint(equalTo: footerView.centerXAnchor),
            noResultLabel.centerXAnchor.constraint(equalTo: footerView.centerXAnchor),
            noResultLabel.centerYAnchor.constraint(equalTo: footerView.centerYAnchor)
        ])
        
        tableView.tableFooterView = footerView
    }
}
