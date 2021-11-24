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

class AllEventsDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate {

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
    let commentBar = MessageInputBar()
    var showsCommentBar = false
    let myRefreshControl = UIRefreshControl()
    @IBOutlet weak var tableView: UITableView!
    var event: PFObject!
    var comments = [PFObject]()
    var numComments: Int!
    
    @IBAction func commentBotton(_ sender: Any) {
        print("click here to display comments")
    }
    
    override var inputAccessoryView: UIView? {
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool {
        return showsCommentBar
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        eventNameLabel.text = event["Name"] as? String
        eventNameLabel.numberOfLines = 0
        timeLabel.text = event["Date"] as? String
        venueLabel.text = event["venueName"] as? String
        
        getEventComments()

        tableView.delegate = self
        tableView.dataSource = self
        myRefreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        self.tableView.refreshControl = myRefreshControl
        
        commentBar.inputTextView.placeholder = "Add a comment..."
        commentBar.delegate = self
        tableView.keyboardDismissMode = .interactive
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func getEventComments(){
        numComments = 7
        let query = PFQuery(className: "Comment")
        query.whereKey("event", equalTo: self.event!)
        query.order(byDescending: "updatedAt")
        query.includeKeys(["author"])
        query.limit = numComments
        
        query.findObjectsInBackground{(comments, error) in
            if comments != nil {
                self.comments = comments!
                self.tableView.reloadData()
            }
            else{
                print("error \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
           
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell")as! CommentCell
            let commentText = comments[indexPath.row-1]["text"] as? String
            cell.commentLabel.text = commentText

            return cell
        }
       
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count + 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showsCommentBar = true
        becomeFirstResponder()
        commentBar.inputTextView.becomeFirstResponder()
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
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        let comment = PFObject(className: "Comment")
        comment["text"] = commentBar.inputTextView.text
        comment["event"] = event
        comment["author"] = PFUser.current()!
        
        event.add(comment, forKey: "comments")
        event.saveInBackground{(success, error) in
            if success{
                print("comment saved")
            }
            else{
                print("error saving comment")
            }
        }
        getEventComments()
        
        tableView.reloadData()
                
        // Clear and dismiss the input bar
        commentBar.inputTextView.text = nil
        
        showsCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }
    
    @objc func keyboardWillBeHidden(note: Notification) {
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
    }
}
