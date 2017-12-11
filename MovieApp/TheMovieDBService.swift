//
//  TheMovieDBService.swift
//  MovieApp
//
//  Created by Firoz Khursheed on 10/12/17.
//  Copyright © 2017 Firoz Khursheed. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class TheMovieDBService {
  static func fetchData(fromSavedUrl url: String, parameters: [String: String]? = nil, callback: ((JSON?, Error?) -> Void)?) {
    Alamofire.request(url, parameters: parameters).validate().responseJSON { response in
      if let error = response.error {
        callback?(nil, error)
      } else {
        let json = JSON(response.result.value as Any)
        callback?(json, nil)
      }
    }
  }
}
