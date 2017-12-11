//
//  Movie+CoreDataProperties.swift
//  MovieApp
//
//  Created by Firoz Khursheed on 10/12/17.
//  Copyright © 2017 Firoz Khursheed. All rights reserved.
//
//

import Foundation

extension Movie {
  
  @nonobjc public class func fetchRequest() -> NSFetchRequest<Movie> {
    return NSFetchRequest<Movie>(entityName: "Movie")
  }
  
  @NSManaged public var adult: Bool
  @NSManaged public var backdropPath: String?
  @NSManaged public var originalLanguage: String?
  @NSManaged public var originalTitle: String?
  @NSManaged public var overview: String?
  @NSManaged public var popularity: Int32
  @NSManaged public var posterPath: String?
  @NSManaged public var recordID: Int32
  @NSManaged public var releaseDate: String?
  @NSManaged public var title: String?
  @NSManaged public var video: Bool
  @NSManaged public var voteAverage: Int32
  @NSManaged public var voteCount: Int32
  
  var posterUrl: URL? {
    let imagePath = (posterPath ?? backdropPath) ?? ""
    return URL(string: "https://image.tmdb.org/t/p/w500" + imagePath)
  }
}
