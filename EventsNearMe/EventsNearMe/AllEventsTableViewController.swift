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
    
    var events = [[String:Any]]()
                                                                                                           
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        getEventsByPostalCode(postalCode: 11217, radius: 100)

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell") as! EventCell
        
        let event = events[indexPath.row]
        let dates = event["dates"] as! [String: Any]
        let start = dates["start"] as! [String: Any]
        let localDate = start["localDate"] as! String
        let embedded = event["_embedded"] as! [String: Any]
        let venues = embedded["venues"] as! [[String:Any]]
        let venues2 = venues[0]
        let city = venues2["city"] as! [String: Any]
        let cityName = city["name"] as! String
        let state = venues2["state"] as! [String: Any]
        let stateCode = state["stateCode"] as! String
        let name = event["name"] as! String
        cell.eventLabel.text = name
        cell.datetimeLabel.text = localDate
        cell.locationLabel.text = cityName
        cell.stateLabel.text = stateCode
        
        let attractions = embedded["attractions"] as! [[String: Any]]
        let attractions2 = attractions[0]
        let attractions3 = attractions.last
        let images = attractions2["images"] as! [[String: Any]]
        
        let images2 = images[8]
        
        let url = images2["url"] as! String
        
        let posterUrl = URL(string: url)
        
        cell.posterView.af.setImage(withURL: posterUrl!)
        
        let imagesSecond = attractions3!["images"] as! [[String: Any]]
        let images3 = imagesSecond[8]
        let url2 = images3["url"] as! String
        let posterUrl2 = URL(string: url2)
        cell.secondPosterView.af.setImage(withURL: posterUrl2!)
        
        
        

        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func getEventsByPostalCode(postalCode: Int, radius: Int){
        EventsAPICaller.client.getEventsByPostalCode(postalCode: postalCode, radius: radius){(events) in
            guard let events = events else{
                return
            }
            self.events = events;
            self.tableView.reloadData()
        }
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
