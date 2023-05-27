//
//  ViewController.swift
//  MTest
//
//  Created by Sachin George on 27/05/23.
//

import UIKit
import Combine

class HomeViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    let viewModel = HomeViewModel()
    var homeDataSource: HomeData?
    
    let refreshControl = UIRefreshControl()
    
    private var binding = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Setting up refresh control
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        
        collectionView.delegate = self
        collectionView.dataSource = self
        registerNibs()
        
        collectionView.collectionViewLayout = createCompositionalLayout()
        
        setupBinding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activityIndicator.startAnimating()
        viewModel.fetchHomeData()
    }
    
    @objc func didPullToRefresh(_ sender: Any) {
        self.refreshControl.endRefreshing()
        activityIndicator.startAnimating()
        viewModel.fetchHomeData()
    }
    
    // Setting up the listener for api call
    func setupBinding() {
        viewModel.homeDataSubject.sink { completion in
            switch completion {
            case .failure(_):
                print("Error")
            case .finished:
                print("Finished")
            }
        } receiveValue: { result in
            switch result {
            case .success(let homeData):
                print("Loaded")
                self.homeDataSource = homeData
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.collectionView.reloadData()
                }
            case .failure(let error):
                print("Error occured: \(error)")
                self.activityIndicator.stopAnimating()
                self.presentAlert(withTitle: "Error", message: error.localizedDescription)
            }
        }.store(in: &binding)
    }
    
    // The collectionview cells are designed in separate xib files. So these nibs should be registered with the collectionview
    func registerNibs() {
        collectionView.register(UINib(nibName: "CategoryCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "CategoryCollectionViewCell")
        collectionView.register(UINib(nibName: "ProductCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "ProductCollectionViewCell")
        collectionView.register(UINib(nibName: "BannerCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "BannerCollectionViewCell")
    }
    
    // Method for dynamic design of the collectionview
    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, collectioLayoutEnvironment in
            guard let self = self else { return nil }
            let section = self.homeDataSource?.homeData[sectionIndex].type
            switch section {
                
            case "category":
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
                
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .absolute(100), heightDimension: .absolute(120)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.interGroupSpacing = 4
                return section
                
            case "banners":
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.3)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                
                return section
                
            case "products":
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(0.5)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.interGroupSpacing = 8
                section.contentInsets = .init(top: 8, leading: 4, bottom: 0, trailing: 0)
                
                return section
            default:
                return nil
            }
             
        }
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return homeDataSource?.homeData[section].values.count ?? 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return homeDataSource?.homeData.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = homeDataSource?.homeData[indexPath.section]
        switch section?.type {
            
            
        case "category":
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath) as! CategoryCollectionViewCell
            
            cell.categoryTitle.text = section?.values[indexPath.item].name
            cell.configureCell(with: section?.values[indexPath.item].imageUrl ?? "")
            return cell
            
            
        case "products":
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCollectionViewCell", for: indexPath) as! ProductCollectionViewCell
            
            cell.configureCell(with: (section?.values[indexPath.item])!)
            return cell
            
            
        case "banners":
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BannerCollectionViewCell", for: indexPath) as! BannerCollectionViewCell
            
            cell.configureCell(with: section?.values[indexPath.item].bannerUrl ?? "")
            return cell
            
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath) as! CategoryCollectionViewCell
            return cell
        }
    }
}
