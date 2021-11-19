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
    @IBAction func getTicket(_ sender: Any) {
        
        guard let url = URL(string: event["url"] as! String) else {
             return
         }
        if UIApplication.shared.canOpenURL(url) {
             UIApplication.shared.open(url, options: [:], completionHandler: nil)
         }
    }
    let myRefreshControl = UIRefreshControl()
    @IBOutlet weak var tableView: UITableView!
    var event: [String:Any]!
    let eventObj = PFObject(className: "Events")
    
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
        myRefreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        self.tableView.refreshControl = myRefreshControl
        
        eventObj["user"] = PFUser.current()!
        eventObj["event"] = event
        eventObj["eventName"] = (event["name"] as! String)
        eventObj.saveInBackground {(success, error) in
            if success {
                self.dismiss(animated: true, completion: nil)
                print("Event saved!")
            } else {
                print("Error saving the event!")
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let query = PFQuery(className: "Events")
        query.includeKey("Comments")
        query.limit = 20
        
//        query.findObjectsInBackground{(eventObj, error) in
//            if eventObj != nil {
//                self.tableView.reloadData()
//            } else {
//                print("Failed to retrieve")
//            }
//        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let comment = PFObject(className: "Comments")
        comment["text"] = "This is a random comment"
        comment["event"] = eventObj
        comment["eventName"] = (event["name"] as! String)
        comment["user"] = PFUser.current()!

        eventObj.add(comment, forKey: "Comments")
        eventObj.saveInBackground { (success, error) in
            if success {
                print("Comment saved")
            } else {
                print("Error saving comment")
            }
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
        
        let comments = (eventObj["Comments"] as? [PFObject]) ?? []
        let currComment = comments[0]
        cell.commentLabel.text = currComment["text"] as? String
        let user = comment["user"] as! PFUser
        cell.userNameLabel.text = user.username
       
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return 1
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    @objc func onRefresh() {
        refresh()
    }
    
    func run(after wait: TimeInterval, closure: @escaping () -> Void) {
        let queue = DispatchQueue.main
        queue.asyncAfter(deadline: DispatchTime.now() + wait, execute: closure)
    }
    
    func refresh() {
        run(after: 2) {
           self.myRefreshControl.endRefreshing()
        }
    }
}
