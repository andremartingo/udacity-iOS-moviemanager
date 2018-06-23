//
//  MoviePickerTableView.swift
//  TheMovieManager
//
//  Created by Jarrod Parkes on 2/11/15.
//  Copyright (c) 2015 Jarrod Parkes. All rights reserved.
//

import UIKit

// MARK: - MoviePickerViewControllerDelegate

protocol MoviePickerViewControllerDelegate {
    func moviePicker(_ moviePicker: MoviePickerViewController, didPickMovie movie: TMDBMovie?)
}

// MARK: - MoviePickerViewController: UIViewController

class MoviePickerViewController: UIViewController {
    
    // MARK: Properties
    
    let store: MovieStoreProtocol = MovieStore()
    
    // the data for the table
    var movies = [TMDBMovie]()
    
    // the delegate will typically be a view controller, waiting for the Movie Picker to return an movie
    var delegate: MoviePickerViewControllerDelegate?

    
    // MARK: Outlets
    
    @IBOutlet weak var movieTableView: UITableView!
    @IBOutlet weak var movieSearchBar: UISearchBar!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        parent!.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(logout))
        
        // configure tap recognizer
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(_:)))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.delegate = self
        view.addGestureRecognizer(tapRecognizer)
    }
    
    // MARK: Dismissals
    
    func handleSingleTap(_ recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    private func cancel() {
        delegate?.moviePicker(self, didPickMovie: nil)
        logout()
    }
    
    func logout() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - MoviePickerViewController: UIGestureRecognizerDelegate

extension MoviePickerViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return movieSearchBar.isFirstResponder
    }
}

enum MovieError: Error {
    case network
    case parsing
}

enum Result<Value, Error: Swift.Error> {
    case success(Value)
    case failure(Error)
}

protocol MovieStoreProtocol {
    
    var client: TMDBClient { get }
    
    func fetch(criteria: String, completion: @escaping (Result<[TMDBMovie], MovieError>) -> Void)
}

final class MovieStore: MovieStoreProtocol {
    
    let client: TMDBClient
    
    // the most recent data download task. We keep a reference to it so that it can be canceled every time the search text changes
    private var task: URLSessionDataTask?
    
    init(client: TMDBClient = .sharedInstance()) {
        self.client = client
    }
    
    func fetch(criteria: String, completion: @escaping (Result<[TMDBMovie], MovieError>) -> Void) {
        task?.cancel()
        task = client.getMoviesForSearchString(criteria) { movies, error in
            
            if let movies = movies {
                completion(.success(movies))
            } else if error != nil {
                completion(.failure(MovieError.network))
            } else {
                assertionFailure("Unexpected scenario.")
            }
        }
    }
}

// MARK: - MoviePickerViewController: UISearchBarDelegate

extension MoviePickerViewController: UISearchBarDelegate {

    // each time the search text changes we want to cancel any current download and start a new one
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        guard searchText.isEmpty == false else {
            movies = [TMDBMovie]()
            movieTableView?.reloadData()
            return
        }

        store.fetch(criteria: searchText) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let movies):
                strongSelf.movies = movies
            case .failure:
                break
            }
            
            performUIUpdatesOnMain {
                strongSelf.movieTableView!.reloadData()
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - MoviePickerViewController: UITableViewDelegate, UITableViewDataSource

extension MoviePickerViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let CellReuseId = "MovieSearchCell"
        let movie = movies[(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseId) as UITableViewCell!
        
        if let releaseYear = movie.releaseYear {
            cell?.textLabel!.text = "\(movie.title) (\(releaseYear))"
        } else {
            cell?.textLabel!.text = "\(movie.title)"
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {        
        let movie = movies[(indexPath as NSIndexPath).row]
        let controller = storyboard!.instantiateViewController(withIdentifier: "MovieDetailViewController") as! MovieDetailViewController
        controller.movie = movie
        navigationController!.pushViewController(controller, animated: true)
    }
}
