//
//  AllEventsTableViewController.swift
//  EventsNearMe
//
//  Created by Weiwei Shi on 11/12/21.
//

import UIKit
import Parse
import AlamofireImage

class AllEventsTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
 
    @IBOutlet weak var tableView: UITableView!
    @IBAction func onLogout(_ sender: Any) {
    
        PFUser.logOut()
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginNavController = main.instantiateViewController(identifier: "LoginNavigationController")

        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginNavController)
    }
    
    var events = [PFObject]()
    let myRefreshControl = UIRefreshControl()
    var numEvents: Int!
    var favorites = [PFObject:[PFObject]]()
    
                                                                                                           
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        
        tableView.refreshControl = myRefreshControl
        tableView.refreshControl?.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        
        getInitialEvents(StateCode: "NY")

    }
    
    @objc func didPullToRefresh() {
        //refetch the data
        getInitialEvents(StateCode: "NY")
    }
    
    func getInitialEvents(StateCode: String){
        EventsAPICaller.client.getEventsByStateCode(StateCode: StateCode){(events) in
            guard let events = events else{
                return
            }
            let query = PFQuery(className: "Event")
            let today = Date()
            let nyToday = Calendar.current.date(byAdding: .hour, value: -5, to: today)!
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-dd"
            let date = dateFormatter.string(from: nyToday)
            query.whereKey("Date", greaterThanOrEqualTo: date)
            query.order(byAscending: "Date")
            query.findObjectsInBackground{(events,error) in
                if events != nil{
                    self.events.removeAll()
                    self.events = events!
                    self.findFave()
                }
                else{
                    print("unable to load events from bac4App")
                    
                }
            }
        }
    }
    func findFave(){
        let query = PFQuery(className: "Favorited")
        query.whereKey("author", equalTo: PFUser.current()!)
        query.findObjectsInBackground{(favorites, error) in
            if favorites != nil{
                for favorite in favorites! {
                    self.favorites[favorite["event"] as! PFObject] = [PFObject]()
                    self.favorites[favorite["event"] as! PFObject]?.append(favorite as PFObject)
                }
                self.tableView.reloadData()
                print("favor table reloaded")
                //print(self.favorites)
                for fav in self.favorites{
                    print("favor \(fav.key)")
                }
                self.tableView.refreshControl?.endRefreshing()
            }else{
                print("error while getting favorites")
            }
        }
    }

    
    
    
    

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell") as! EventCell
        
        let event = events[indexPath.row]
        
        cell.eventLabel.text = event["Name"] as? String
        cell.datetimeLabel.text = event["Date"] as? String
        cell.locationLabel.text = event["venueName"] as? String
        
        let imgOneUrl = URL(string: event["posterOneURL"] as! String)
        cell.posterView.af.setImage(withURL: imgOneUrl!)
        cell.posterView.translatesAutoresizingMaskIntoConstraints = false
        
        
        if event["category"] as! String != "Sports" {
            cell.secondPosterView.isHidden = true;
            cell.onePoster()
            
        }else {
            cell.secondPosterView.isHidden = false
            let imgTwoUrl = URL(string: event["posterTwoURL"] as! String)
            cell.secondPosterView.af.setImage(withURL: imgTwoUrl!)
            cell.twoPoster()
        }
        //print(self.favorites)
        print("favor :\(self.favorites[event])")
        var count:Int!
        count = self.favorites[event]?.count
        //print("favor \(self.favorites[event].key)")
        if  count != nil{
            cell.eventLabel.text = String(count)
            cell.favorited = true
            cell.event = self.favorites[event]?[0]
            cell.FavButton.setImage(cell.favoriteImage, for: .normal)
            
        }
        else{
            cell.event = nil
            cell.FavButton.setImage(cell.unfavoriteImage, for: .normal)
            cell.favorited = false
        }
             
        cell.detectFav = {
            
            if cell.favorited == true {
                let favorite = PFObject(className: "Favorited")
                favorite["event"] = event
                favorite["favorited"] = cell.favorited
                favorite["author"] = PFUser.current()
            
                event.add(favorite, forKey: "favorite")
                event.saveInBackground { success, error in
                    if success{
                        cell.FavButton.setImage(cell.favoriteImage, for: .normal)
                        print("favorite saved")
                    }else{
                        print("error saving favorite")
                    }
                }
                            
                }else {
     
                }
                
           // let query = PFQuery(className: "Favorited")
//            query.whereKey("event", equalTo: event)
//            query.whereKey("author", equalTo: PFUser.current()!)
//            query.findObjectsInBackground {(favorites, error) in
//                if favorites != nil {
//                    cell.favorited = true
//                    cell.FavButton.setImage(cell.favoriteImage, for: .normal)
//                }else {
//                    cell.favorited = false
//                    cell.FavButton.setImage(cell.unfavoriteImage, for: .normal)
//                }
//            }
        }
       
        
        
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    
    
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        print("Loading")
        // Find the selected event
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)!
        let event = events[indexPath.row]
        
        // Pass the selected event to the details view controller
        let detailsViewController = segue.destination as! AllEventsDetailsViewController
        detailsViewController.event = event
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

}

