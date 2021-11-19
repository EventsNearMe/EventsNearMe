//
//  AllEventsDetailsViewController.swift
//  EventsNearMe
//
//  Created by Weiwei Shi on 11/12/21.
//

import UIKit
import Parse
import MessageInputBar
import Alamofire

class AllEventsDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var lineUpImage1: UIImageView!
    @IBOutlet weak var lineUpImage2: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var venueLabel: UILabel!
    @IBAction func getTiket(_ sender: Any) {
        
        guard let url = URL(string: event["url"] as! String) else {
             return
         }
        if UIApplication.shared.canOpenURL(url) {
             UIApplication.shared.open(url, options: [:], completionHandler: nil)
         }
    }
    
    @IBOutlet weak var tableView: UITableView!
    var event: [String:Any]!
    var selectedEvent: PFObject!
    
    @IBAction func commentBotton(_ sender: Any) {
        print("click here to display comments")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        eventNameLabel.text = (event["name"] as! String)
        eventNameLabel.sizeToFit()
        
        tableView.delegate = self
        tableView.dataSource = self

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let comments = selectedEvent["Comments"] as? [PFObject]
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
    
//        let comment = comments![indexPath.row]
//        cell.commentLabel.text = comment["text"] as? String
//        let user = comment["user"] as! PFUser
//        cell.userNameLabel.text = user.username
    
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return comments.count
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let event = PFObject(className: "Events")
       
        event["user"] = PFUser.current()!
        event.saveInBackground {(success, error) in
            if success {
                self.dismiss(animated: true, completion: nil)
                print("Event saved!")
            } else {
                print("Error saving the event!")
            }
        }
        
        let comment = PFObject(className: "Comments")
        comment["text"] = "This is a random comment"
        comment["event"] = event
        comment["user"] = PFUser.current()!

        event.add(comment, forKey: "Comments")

        event.saveInBackground { (success, error) in
            if success {
                print("Comment saved")
            } else {
                print("Error saving comment")
            }
        }
        
//        selectedEvent = event
    }
}
