//
//  MasterViewController.swift
//  GitHubGists
//
//  Created by Justin Hall on 3/15/16.
//  Copyright © 2016 Justin Hall. All rights reserved.
//

import UIKit
import PINRemoteImage

class MasterViewController: UITableViewController {

  var imageCache = [String : UIImage?]()
  var detailViewController: DetailViewController? = nil
  var gists = [Gist]()
  var nextPageURLString: String?
  var isLoading = false

  //MARK: - View Controller Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem()

    let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
    self.navigationItem.rightBarButtonItem = addButton
    if let split = self.splitViewController {
        let controllers = split.viewControllers
        self.detailViewController = (controllers[controllers.count - 1] as! UINavigationController).topViewController as? DetailViewController
    }
  }

  override func viewWillAppear(animated: Bool) {
    self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
    super.viewWillAppear(animated)
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    loadGists(nil)
  }
  
  // MARK: - Instance Methods
  
  func loadGists(urlToLoad: String?) {
    self.isLoading = true
    GitHubAPIManager.sharedInstance.getPublicGists(urlToLoad) { (result, nextPage) -> Void in
      
      self.isLoading = false
      self.nextPageURLString = nextPage
      
      guard result.error == nil else {
        print(result.error)
        return
      }
      
      if let fetchedGists = result.value {
        if self.nextPageURLString != nil {
          self.gists += fetchedGists
        } else {
          self.gists = fetchedGists
        }
      }
      
      self.tableView.reloadData()
    }
  }

  func insertNewObject(sender: AnyObject) {
    let alert = UIAlertController(title: "Not yet Implemented", message: "Can't create new gists yet, will implement soon", preferredStyle: .Alert)
    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
    self.presentViewController(alert, animated: true, completion: nil)
  }

  // MARK: - Segues

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showDetail" {
      if let indexPath = self.tableView.indexPathForSelectedRow {
          let gist = gists[indexPath.row] as Gist
        if let detailViewController = (segue.destinationViewController as! UINavigationController).topViewController as? DetailViewController {
          detailViewController.detailItem = gist
          detailViewController.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
          detailViewController.navigationItem.leftItemsSupplementBackButton = true
        }
      }
    }
  }

  // MARK: - Table View

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return gists.count
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

    let gist = gists[indexPath.row]
    cell.textLabel?.text = gist.description
    cell.detailTextLabel?.text = gist.ownerLogin
    
    if let urlString = gist.ownerAvatarURL, url = NSURL(string: urlString) {
    
      cell.imageView?.pin_setImageFromURL(url, placeholderImage: UIImage(named: "brackdaddies.png"))
      
    } else {
      cell.imageView?.image = nil
    }
    
    // See if we need to load more gists
    let rowsToLoadFromBottom = 5
    let rowsLoaded = gists.count
    if let nextPage = nextPageURLString {
      if (!isLoading && (indexPath.row >= (rowsLoaded - rowsToLoadFromBottom))) {
        self.loadGists(nextPage)
      }
    }
    
    return cell
  }

  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return false
  }

  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
        gists.removeAtIndex(indexPath.row)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
  }


}

