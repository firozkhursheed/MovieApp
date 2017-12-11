//
//  Preferences.swift
//  MovieApp
//
//  Created by Firoz Khursheed on 10/12/17.
//  Copyright © 2017 Firoz Khursheed. All rights reserved.
//

import Foundation

class Preferences {
  static let sharedInstance = Preferences()
  
  var userDefaults: UserDefaults {
    return UserDefaults.standard
  }
  
  var nextMoviePage: String? {
    get {
      return userDefaults.string(forKey: "nextMoviePage")
    }
    set {
      userDefaults.setValue(newValue, forKey: "nextMoviePage")
      userDefaults.synchronize()
    }
  }}
