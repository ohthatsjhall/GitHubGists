//
//  GitHubAPIManager.swift
//  GitHubGists
//
//  Created by Justin Hall on 3/15/16.
//  Copyright © 2016 Justin Hall. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class GitHubAPIManager {
  
  static let sharedInstance = GitHubAPIManager()
  
  func printPublicGists() -> () {
    
    Alamofire.request(GistRouter.GetPublic()).responseString { (response) -> Void in
    
      if let receivedString = response.result.value {
      print("called")
        print(receivedString)
      }
    
    }
    
  }

}