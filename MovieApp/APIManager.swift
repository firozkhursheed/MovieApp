//
//  APIManager.swift
//  MovieApp
//
//  Created by Firoz Khursheed on 11/12/17.
//  Copyright © 2017 Firoz Khursheed. All rights reserved.
//

import Foundation

class APIManager {
  static let theMovieDBBaseUri = "https://api.themoviedb.org"
  static let apiPrefix = "/3"
  static let theMovieDBApiUri = "\(theMovieDBBaseUri)\(apiPrefix)"
  
  static let apiKey = ""  // Update this with your own api_key
  
  static func getMovieUrl() -> String {
    return theMovieDBApiUri + "/discover/movie"
  }
}
