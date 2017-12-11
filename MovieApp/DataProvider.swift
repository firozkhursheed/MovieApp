//
//  DataProvider.swift
//  MovieApp
//
//  Created by Firoz Khursheed on 10/12/17.
//  Copyright © 2017 Firoz Khursheed. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import MagicalRecord

class DataProvider {

  static let sharedInstance = DataProvider()

  // MARK: - Public Methods
  func refreshMovies(errorClosure: ((_ error: Error?) -> Void)?) {
    Preferences.sharedInstance.nextMoviePage = nil
    Movie.mr_truncateAll()
    NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()

    fetchNextMovies { (error) in
      errorClosure?(error)
    }
  }
  
  func fetchNextMovies(errorClosure: ((_ error: Error?) -> Void)?) {
    func callback(_json: JSON?, _error: Error?) -> Void {
      errorClosure?(_error)
      if let json = _json {
        if let currentPage = json["page"].int,
          let totalPages = json["total_pages"].int {
          if currentPage < totalPages {
            Preferences.sharedInstance.nextMoviePage = String(currentPage + 1)
          }
        }
        
        if let movieArray = json["results"].array {
          storeFetched(movies: movieArray)
        }
      }
    }
    
    var parameter = ["api_key": APIManager.apiKey,
                     "sort_by": "popularity.desc",
                     "include_adult": "false",
                     "page": "1"]
    
    if let nextPage = Preferences.sharedInstance.nextMoviePage {
      parameter["page"] = nextPage
    }
    
    TheMovieDBService.fetchData(fromSavedUrl: APIManager.getMovieUrl(), parameters: parameter, callback: callback)
  }
  
  // MARK: - Private Methods
  private func storeFetched(movies: [JSON]) {
    for json in movies {
      // To prevent dublicate data
      let recordID = json["id"].intValue
      let movie = Movie.mr_findFirst(byAttribute: "recordID", withValue: recordID)
      if movie != nil {
        continue
      }
      
      // else, we create the Movie
      MagicalRecord.save({ (localContext) in
        let newMovie = Movie.mr_createEntity(in: localContext)!
        newMovie.adult = json["adult"].boolValue
        newMovie.backdropPath = json["backdrop_path"].stringValue
        newMovie.originalLanguage = json["original_language"].stringValue
        newMovie.originalTitle = json["original_title"].stringValue
        newMovie.overview = json["overview"].stringValue
        newMovie.popularity = json["popularity"].int32Value
        newMovie.posterPath = json["poster_path"].stringValue
        newMovie.recordID = json["id"].int32Value
        newMovie.releaseDate = json["release_date"].stringValue
        newMovie.title = json["title"].stringValue
        newMovie.video = json["video"].boolValue
        newMovie.voteAverage = json["voteAverage"].int32Value
        newMovie.voteCount = json["voteCount"].int32Value
      }, completion: { (contextDidSave, error) in
        if error != nil {
          print("Error \(String(describing: error))")
        }
      })
    }
  }
}
