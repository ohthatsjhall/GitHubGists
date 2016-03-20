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
  
  
  func getGists(urlRequest: URLRequestConvertible, completionHandler: (Result<[Gist], NSError>, String?) -> Void) {
      alamofireManager.request(GistRouter.GetPublic()).validate()
        .responseArray { (response: Response<[Gist], NSError>) -> Void in
          
        guard response.result.error == nil,
          let gists = response.result.value else {
            print("error getting public gists:\(response.result.error)")
            completionHandler(response.result, nil)
            return
        }
          
        let next = self.getNextPageFromHeaders(response.response)
        completionHandler(.Success(gists), next)
    }
  }
  
 
  func getPublicGists(pageToLoad: String?, completionHandler: (Result<[Gist], NSError>, String?) -> Void) {
    
    if let urlString = pageToLoad {
      getGists(GistRouter.GetAtPath(urlString), completionHandler: completionHandler)
    } else {
      getGists(GistRouter.GetPublic(), completionHandler: completionHandler)
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
  
  private func getNextPageFromHeaders(response: NSHTTPURLResponse?) -> String? {
    
    if let linkHeader = response?.allHeaderFields["Link"] as? String {
      /* looks like:
      <https://api.github.com/user/20267/gists?page=2>; rel="next", <https://api.github.com/\
      user/20267/gists?page=6>; rel="last"
      */
      // so spilt on ",", then on ";"
      let components = linkHeader.characters.split {$0 == ","}.map { String($0) }
      // now we have 2 lines like
      // <https://spi.github.com/user/20267/gists?page=2>; rel="next"'
      // so let's get the URL out of there
      
      for item in components {
        // see if it's "next"
        let rangeOfNext = item.rangeOfString("rel=\"next\"", options: [])
        if rangeOfNext != nil {
          // found the component with the next URL
          let rangeOfPaddedURL = item.rangeOfString("<(.*)>;", options: .RegularExpressionSearch)
          if let range = rangeOfPaddedURL {
            let nextURL = item.substringWithRange(range)
            // strip off the < and >;
            let startIndex = nextURL.startIndex.advancedBy(1)
            let endIndex = nextURL.endIndex.advancedBy(-2)
            let urlRange = startIndex..<endIndex
            return nextURL.substringWithRange(urlRange)
          }
        }
      }
    }
    return nil
  }
 
  
  
  
  
  
  
  
  
  
  
  // END
}