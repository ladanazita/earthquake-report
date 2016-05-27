//
//  ViewController.swift
//  Earthquakes
//
//  Created by Ladan  on 5/26/16.
//  Copyright © 2016 LadanAzita. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    let urlString :String = "http://earthquake-report.com/feeds/recent-eq?json"
    
    // we need a reference to the managed object content, which is in the appdelegate. this is one way, but you can also pass reference in the appviewcontroller
    lazy var privateMoc: NSManagedObjectContext? = {
        
        guard let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate else {return nil}
        return appDelegate.managedObjectContext
        
    }()
    
    lazy var mainMoc: NSManagedObjectContext = {
        let moc = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        if let pMoc = self.privateMoc {
            moc.parentContext = pMoc
        }
        return moc
    }()
    
    let cellId: String = "com.ladanazita.cell"
    
    var quakeList: [Quake] = [Quake]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // to dynamically generate the table view cell to change with text size
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // after adding UITableViewDataSource and UITableViewDelegate
        let nib = UINib(nibName: "CustomTableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: cellId)
        
        fetchData()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quakeList.count
    }
    
    lazy var dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.FullStyle
        formatter.timeStyle = NSDateFormatterStyle.FullStyle
        return formatter
    }()
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as! CustomTableViewCell
        
        if let title = quakeList[indexPath.row].title {
            cell.titleLabel.text = title
        }
        
        if let magnitude = quakeList[indexPath.row].magnitude {
            cell.magnitudeLabel.text = magnitude.stringValue
        }
        
        if let date = quakeList[indexPath.row].date {
            cell.dateLabel.text = dateFormatter.stringFromDate(date)
            
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc = MapViewController()
        let quake = quakeList[indexPath.row]
        let quakeLocation = quake.quakeLocation
        vc.quakeLocation = quakeLocation
        
        showViewController(vc, sender: nil)
    }
    
    // now we need to create a fetch request
    func fetchData(){
        // again saying hey run this on main queue
        self.mainMoc.performBlock {
            let fetchRequest = NSFetchRequest()
            let entity = NSEntityDescription.entityForName("Quake", inManagedObjectContext: self.mainMoc)
            fetchRequest.entity = entity
            
            let sortDescriptor = NSSortDescriptor(key: "magnitude", ascending: false)
            fetchRequest.sortDescriptors = [ sortDescriptor ]
            
            do {
                let results = try self.mainMoc.executeFetchRequest(fetchRequest) as! [Quake]
                self.quakeList = results
                self.tableView.reloadData()
                
            } catch let error as NSError {
                NSLog("\(error)", "\(error.localizedDescription)")
            }
        }
    }
    
    func deleteData() {
        guard let privateMoc = self.privateMoc else { return }
        
        privateMoc.performBlockAndWait {
            let fetchRequest = NSFetchRequest()
            let entity = NSEntityDescription.entityForName("Quake", inManagedObjectContext: privateMoc)
            fetchRequest.entity = entity
            
            do {
                let results = try privateMoc.executeFetchRequest(fetchRequest) as! [Quake]
                
                results.forEach({ (element: Quake) in
                    privateMoc.deleteObject(element)
                })
                
                try privateMoc.save()
                
            } catch let error as NSError {
                NSLog("\(error), \(error.localizedDescription)")
            }
        }
    }
    
    @IBAction
    func updateData(){
        
        deleteData()
        
        // at the top because NSURL is failable
        guard let url = NSURL(string: urlString) else {return}
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        
        // create task                                                // response from server
        let dataTask = session.dataTaskWithURL(url) { (data: NSData?, response: NSURLResponse?, error: NSError?) in
            
            if error == nil {
                
                guard let newData = data else {
                    return
                }
                
                // because of throw, we need to catch
                do {
                    
                    guard let jsonArray = try NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.MutableLeaves) as? [AnyObject] else { return }
                    
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssvvv"
                    dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
                    
                    // check outside loop so it doesn't continue to run on itself. mainmoc is an uwrapped version of mainMoc, a local version
                    guard let privateMoc = self.privateMoc else { return }
                    // we need to explicitly state that this block be run on main queue with performBlock
                    privateMoc.performBlock({
                        jsonArray.forEach({ (element: AnyObject) in
                            
                            guard let dict = element as? [NSString : NSString] else { return }
                            
                            // need to add to moc. this creates the quake by inserting this object into the managed object context within this loop
                            let quake = NSEntityDescription.insertNewObjectForEntityForName("Quake", inManagedObjectContext: privateMoc) as! Quake
                            // these are the things added to the moc
                            guard let title = dict["title"] else { return }
                            quake.title = (title as String)
                            
                            guard let magnitude = dict["magnitude"] else { return }
                            // floatValue comes from the NSString class,  why we defined magnitude as NSString. this will covert a string to a float
                            quake.magnitude = magnitude.floatValue
                            
                            guard let date_time = dict["date_time"] else { return }
                            quake.date = dateFormatter.dateFromString(date_time as String)
                            
                            // adding to quakeLocation moc
                            let quakeLocation = NSEntityDescription.insertNewObjectForEntityForName("QuakeLocation", inManagedObjectContext: privateMoc) as! QuakeLocation
                            
                            guard let location = dict["location"] else { return }
                            quakeLocation.location = location as String
                            
                            guard let longitude = dict["longitude"] else { return }
                            quakeLocation.longitude = longitude.doubleValue
                            
                            guard let latitude = dict["latitude"] else { return }
                            quakeLocation.latitude = latitude.doubleValue
                            
                            guard let depth = dict["depth"] else { return }
                            quakeLocation.depth = depth.floatValue
                            
                            // adding to quakeweb moc
                            let quakeWeb = NSEntityDescription.insertNewObjectForEntityForName("QuakeWeb", inManagedObjectContext: privateMoc) as! QuakeWeb
                            
                            guard let link = dict["link"] else { return }
                            quakeWeb.link = link as String
                            
                            // we need to establish the relationship
                            quake.quakeLocation = quakeLocation
                            quakeLocation.quakeWeb = quakeWeb
                            
                            
                        })
                        do {
                            // loop ends and now we add this to the storage
                            try privateMoc.save()
                            self.fetchData()
                            dispatch_async(dispatch_get_main_queue(), {
                                self.tableView.reloadData()
                            })
                        } catch let error as NSError {
                            NSLog("\(error), \(error.localizedDescription)")
                        }
                        
                    })
                    
                    
                    
                } catch let jsonError as NSError {
                    
                    NSLog("\(jsonError), \(jsonError.localizedDescription)")
                    
                }
            } else {
                // localizedDescription is the message
                NSLog("\(error!), \(error?.localizedDescription)")
            }
        }
        // automatically stops session when its created so we need to tell the task to resume
        dataTask.resume()
        
    }
    
    
}

