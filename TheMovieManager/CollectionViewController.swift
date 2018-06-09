//
//  ListsTableViewController.swift
//  TheMovieManager
//
//  Created by Jarrod Parkes on 2/26/15.
//  Copyright (c) 2015 Jarrod Parkes. All rights reserved.
//

import UIKit

// MARK: - WatchlistViewController: UIViewController

class CollectionViewController: UIViewController{
    
    // MARK: Properties
    
    var movies: [TMDBMovie] = [TMDBMovie]()
    
    fileprivate let itemsPerRow: CGFloat = 2
    fileprivate let sectionInsets = UIEdgeInsets(top: 1.0, left: 1.0, bottom: 1.0, right: 1.0)
    
    // MARK: Outlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var estimateWidth = 160.0
    var cellMarginSize = 1.0
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create and set the logout button
        parent!.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(logout))
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentMode = .scaleToFill
        self.setupGridView()
    }
    
    func setupGridView() {
        let flow = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        flow.minimumInteritemSpacing = CGFloat(self.cellMarginSize)
        flow.minimumLineSpacing = CGFloat(self.cellMarginSize)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        TMDBClient.sharedInstance().getWatchlistMovies { (movies, error) in
            if let movies = movies {
                self.movies = movies
                performUIUpdatesOnMain {
                    self.collectionView.reloadData()
                }
            } else {
                print(error ?? "empty error")
            }
        }
    }
    
    // MARK: Logout
    
    func logout() {
        dismiss(animated: true, completion: nil)
    }
    
}

extension CollectionViewController: UICollectionViewDataSource,UICollectionViewDelegate {
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return self.movies.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
            
            let movie = self.movies[(indexPath as NSIndexPath).row]
            
            // Set the name and image
            cell.movieImageView!.image = UIImage(named: "Film")
            cell.movieImageView!.contentMode = UIViewContentMode.scaleAspectFit
            cell.backgroundColor = .black
            
            if let posterPath = movie.posterPath {
                let _ = TMDBClient.sharedInstance().taskForGETImage(TMDBClient.PosterSizes.RowPoster, filePath: posterPath, completionHandlerForImage: { (imageData, error) in
                    if let image = UIImage(data: imageData!) {
                        performUIUpdatesOnMain {
                            cell.movieImageView!.image = image
                        }
                    } else {
                        print(error ?? "empty error")
                    }
                })
            }
            return cell
        }
}

extension CollectionViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.calculateWith()
        return CGSize(width: width, height: width*1.3)
    }
    
    func calculateWith() -> CGFloat {
        let estimatedWidth = CGFloat(estimateWidth)
        let cellCount = floor(CGFloat(self.view.frame.size.width / estimatedWidth))
        //Righ And Left Margin
        let margin = CGFloat(cellMarginSize * 2)
        //Margin Beetween Cells
        let marginBetweenCells = CGFloat(cellMarginSize) * (cellCount - 1)
        let width = (self.view.frame.size.width - marginBetweenCells - margin) / cellCount
        
        return width
    }
}

