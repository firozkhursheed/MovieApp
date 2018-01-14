//
//  API.swift
//  MovieApp
//
//  Created by Firoz Khursheed on 11/12/17.
//  Copyright © 2017 Firoz Khursheed. All rights reserved.
//

import Foundation

/// Namespaces in Swift
enum API {
  static let theMovieDBBaseUri = "https://api.themoviedb.org"
  static let apiPrefix = "/3"
  static let theMovieDBApiUri = "\(theMovieDBBaseUri)\(apiPrefix)"
  
  static let theMovieDBApiKey = ""  // Update this with your own TheMovieDB api_key
  
  static let movieUrl = theMovieDBApiUri + "/discover/movie"
}
