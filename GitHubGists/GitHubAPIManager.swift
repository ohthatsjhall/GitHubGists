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
  var alamofireManager: Alamofire.Manager
  
  init() {
    let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
    alamofireManager = Alamofire.Manager(configuration: configuration)
  }
  
  func printPublicGists() -> () {
    
    Alamofire.request(GistRouter.GetPublic()).responseString { (response) -> Void in
    
      if let receivedString = response.result.value {
        print(receivedString)
      }
    }
  }

 
  func getPublicGists(completionHandler: (Result<[Gist], NSError>) -> Void) {
    
    Alamofire.request(GistRouter.GetPublic()).responseArray { (response: Response<[Gist], NSError>) -> Void in
  
      completionHandler(response.result)
  
    }
  }
  
  func imageForURLString(imageURLString: String, completionHandler: (UIImage?, NSError?) -> Void) {
    
    alamofireManager.request(.GET, imageURLString).response { (request, response, data, error) -> Void in
      
      if data == nil {
        completionHandler(nil, nil)
      }
      
      let image = UIImage(data: data!)
      completionHandler(image, nil)
      
    }
    
    
  }
  
}