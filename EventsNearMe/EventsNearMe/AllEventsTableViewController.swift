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
    var eventsDate = [String:[PFObject]]()
    let myRefreshControl = UIRefreshControl()
    var oneImageCells = [IndexPath]()
                                                                                                           
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
            query.findObjectsInBackground{(events:[PFObject]?, error: Error?) in
                if events != nil{
                    self.events.removeAll()
                    self.events = events!
                    self.tableView.reloadData()
                    self.tableView.refreshControl?.endRefreshing()
                
                    
                    
                }
                else{
                    print("unable to load events from bac4App")
                    //return
                    
                }
                
                

            }
        //
        }
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell") as! EventCell
//
        let event = events[indexPath.row]
        cell.eventLabel.text = event["Name"] as? String
        cell.datetimeLabel.text = event["Date"] as? String
        cell.locationLabel.text = event["venueName"] as? String
        //sortEvent()
        
        let imgOneUrl = URL(string: event["posterOneURL"] as! String)
        cell.posterView.af.setImage(withURL: imgOneUrl!)
        var constraint = NSLayoutConstraint()
        
        if event["category"] as! String == "Sports" {
//            let imgOneUrl = URL(string: event["posterOneURL"] as! String)
//            cell.posterView.af.setImage(withURL: imgOneUrl!)
            let imgTwoUrl = URL(string: event["posterTwoURL"] as! String)
            cell.secondPosterView.af.setImage(withURL: imgTwoUrl!)
            constraint = NSLayoutConstraint(item: cell.posterView!, attribute: NSLayoutConstraint.Attribute.right, relatedBy: NSLayoutConstraint.Relation.equal, toItem: cell.secondPosterView, attribute: NSLayoutConstraint.Attribute.left, multiplier: 1, constant: 0)
            cell.posterView.isHidden = false
            cell.secondPosterView.isHidden = false
        }else {
            
            constraint = NSLayoutConstraint(item: cell.posterView!, attribute: NSLayoutConstraint.Attribute.right, relatedBy: NSLayoutConstraint.Relation.equal, toItem: cell.secondPosterView, attribute: NSLayoutConstraint.Attribute.right, multiplier: 1, constant: 0)
            cell.secondPosterView.isHidden = true;
            cell.posterView.translatesAutoresizingMaskIntoConstraints = false

            
        }
        constraint.isActive = true
        

        
        
        

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
