//
//  MovieListViewModel.swift
//  MovieDB
//
//  Created by Maar Babu on 1/25/20.
//  Copyright © 2020 Maar Babu. All rights reserved.
//

import RxSwift
import RxCocoa

protocol MovieListViewModelType {
    
    var inputs: MovieListViewModelInputs { get }
    var outputs: MovieListViewModelOutputs { get }
    
}

protocol MovieListViewModelInputs {
    func loadMovies(refresh: Bool)
}

protocol MovieListViewModelOutputs: ErrorViewModelProtocol {
    var moviesDidLoad: Observable<Void> { get }
    func numberOfItems() -> Int
    func itemAt(index: IndexPath) -> Movie
}

class MovieListViewModel {
    
    let onError: BehaviorRelay<Network.Status> = .init(value: .error)
    let _moviesDidLoad: PublishRelay<Void> = PublishRelay<Void>()
    let moviesDidLoad: Observable<Void>
    private var movies: [Movie] = []
    private var page = 1
    private var loading = false
    private var pageNumber: Int = .zero
    
    init()
    {
        self.moviesDidLoad = self._moviesDidLoad.asObservable()
    }
    
}

// MARK: - MovieListViewModelInputs
extension MovieListViewModel: MovieListViewModelInputs {
    func loadMovies(refresh: Bool){
        if !loading && (page == 1 || page < pageNumber){
            loading = true
            page = refresh ? 1 : (page + 1)
            Movies.load(page: page, success: { [weak self]  movies in
                let page = movies?.page
                let res = movies?.results ?? []
                if page == 1{
                    self?.pageNumber = movies?.totalResults ?? .zero
                    self?.movies.removeAll()
                }
                res.forEach({
                    self?.movies.append($0)
                })
                self?.loading = false
                self?._moviesDidLoad.accept(())
            }, fail: self.standardFailBlock)
        }
    }
}

// MARK: - MovieListViewModelOutputs
extension MovieListViewModel: MovieListViewModelOutputs {
    func numberOfItems() -> Int{
        return movies.count
    }
    
    func itemAt(index: IndexPath) -> Movie{
        return movies[index.row]
    }
    
}

// MARK: - MovieListViewModelType
extension MovieListViewModel: MovieListViewModelType {
    
    var inputs: MovieListViewModelInputs { get { return self } }
    var outputs: MovieListViewModelOutputs { get { return self } }
    
}