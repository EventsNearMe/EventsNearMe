//
//  CalendarEventsDetailsViewController.swift
//  EventsNearMe
//
//  Created by Weiwei Shi on 11/12/21.
//

import UIKit
import Parse
import MessageInputBar
import Alamofire

class CalendarEventsDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate {
    
    @IBAction func favButtonClicked(_ sender: Any) {
        favoritedEvent = !favoritedEvent
        if favoritedEvent{
            numFavorited += 1
            favButton.setImage(favoriteImage, for: .normal)
            favButton.setTitle(String(numFavorited), for: .normal)
            EventsAPICaller.client.favoriteEvent(event: event)
        }
        else{
            numFavorited -= 1
            favButton.setImage(unfavoriteImage, for: .normal)
            favButton.setTitle(String(numFavorited), for: .normal)
            EventsAPICaller.client.unfavoriteEvent(event: event)
        }
    }
    @IBOutlet weak var favButton: UIButton!
    @IBOutlet weak var lineUpImage2: UIImageView!
    @IBOutlet weak var lineUpImage1: UIImageView!
    
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var venueLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var commentsTableView: UITableView!
    @IBAction func getTicket(_ sender: Any) {
        guard let url = URL(string: event["getTicket"] as! String) else {
                     return
                 }
                if UIApplication.shared.canOpenURL(url) {
                     UIApplication.shared.open(url, options: [:], completionHandler: nil)
                 }
    }
    var favoritedEvent = false
    let unfavoriteImage = UIImage(named: "favor-icon")
    let favoriteImage = UIImage(named: "favor-icon-red")
    var numFavorited = 0
    var event: PFObject!
    var comments = [PFObject]()
    var numComments: Int!
    let commentBar = MessageInputBar()
    var showsCommentBar = false
    let myRefreshControl = UIRefreshControl()
    
    override var inputAccessoryView: UIView? {
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool {
        return showsCommentBar
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if event["favorite"] != nil{
            for fav in event["favorite"] as! [PFObject]{
                let author = fav["author"] as! PFUser
                if author.username == PFUser.current()?.username{
                    favoritedEvent = true
                    favButton.setImage(favoriteImage, for: .normal)
                    favButton.titleLabel?.text = "5"
                    break
                }
            }
            numFavorited = (event["favorite"] as! [PFObject]).count
        }
        favButton.setTitle(String(numFavorited), for: .normal)
 
        let imgOneUrl = URL(string: event["posterOneURL"] as! String)
        lineUpImage1.af.setImage(withURL: imgOneUrl!)

        if event["category"] as! String != "Sports"{
            lineUpImage2.isHidden = true
            lineUpImage1.translatesAutoresizingMaskIntoConstraints = false
            view.addConstraint(NSLayoutConstraint(item: lineUpImage1!, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -20))
            
        }else{
            let imgTwoUrl = URL(string: event["posterTwoURL"] as! String)
            lineUpImage2.af.setImage(withURL: imgTwoUrl!)
        }
        
        
        eventNameLabel.text = event["Name"] as? String
        eventNameLabel.numberOfLines = 0
        genreLabel.text = event["genre"] as? String
        dateLabel.text = event["Date"] as? String
        
        timeLabel.text = event["Time"] as? String
        venueLabel.text = event["venueName"] as? String
        
        commentsTableView.delegate = self
        commentsTableView.dataSource = self
        
        getEventComments()
        
        myRefreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
                self.commentsTableView.refreshControl = myRefreshControl
        commentBar.inputTextView.placeholder = "Add a comment..."
                commentBar.delegate = self
                commentsTableView.keyboardDismissMode = .interactive
                
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
                self.commentsTableView.reloadData()
            }
            else{
                print("error \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count + 1
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = commentsTableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            cell.textLabel?.text = String("Click here to add a comment...")
            return cell
        }else{
            let cell = commentsTableView.dequeueReusableCell(withIdentifier: "CalendarDetailCommentCell")as! CalendarDetailCommentCell
                               
           let commentText = comments[indexPath.row-1]["text"] as? String
           cell.commentLabel.text = commentText
           let author = comments[indexPath.row-1]["author"] as! PFUser
           cell.authorLabel.text = author["username"] as? String
           //cell.textLabel?.text = String("\(author.username): \(commentText)")
           //print(comments[indexPath.row]["text"])
            return cell
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0{
            showsCommentBar = true
            becomeFirstResponder()
            commentBar.inputTextView.becomeFirstResponder()
            self.view.frame.origin.y -= 110
        }
        
    }
    @objc func onRefresh() {
        getEventComments()
        refresh()
        commentsTableView.reloadData()
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
                self.getEventComments()
                self.commentsTableView.reloadData()
            }
            else{
                print("error saving comment")
            }
        }

                
        // Clear and dismiss the input bar
        commentBar.inputTextView.text = nil
        
        showsCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }
    
    @objc func keyboardWillBeHidden(note: Notification) {
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        self.view.frame.origin.y = 0
        becomeFirstResponder()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
