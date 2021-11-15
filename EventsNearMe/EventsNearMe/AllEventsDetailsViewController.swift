//
//  AllEventsDetailsViewController.swift
//  EventsNearMe
//
//  Created by Weiwei Shi on 11/12/21.
//

import UIKit
import Parse
import MessageInputBar

class AllEventsDetailsViewController: UIViewController, MessageInputBarDelegate {

    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var lineUpImage1: UIImageView!
    @IBOutlet weak var lineUpImage2: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var venueLabel: UILabel!
    @IBAction func getTiket(_ sender: Any) {
        //update link here
        guard let url = URL(string: "https://www.google.com") else {
             return
         }
        if UIApplication.shared.canOpenURL(url) {
             UIApplication.shared.open(url, options: [:], completionHandler: nil)
         }
    }
    
    var event: [String:Any]!
    let commentBar = MessageInputBar()
    var showsCommentBar = false
    
    var events = [PFObject]()
    var selectedEvent: PFObject!
    
    @IBAction func commentButtom(_ sender: Any) {
        print("Click here to display comments")
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        eventNameLabel.text = event["name"] as? String
        eventNameLabel.sizeToFit()
        
        
        
        commentBar.inputTextView.placeholder = "Leave a comment..."
        commentBar.delegate = self
//        let center = NotificationCenter.default
//        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
//        setupToolbar()
        
    }
    
    override var inputAccessoryView: UIView? {
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        // Create the comment
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
        comment["text"] = "commentBar.inputTextView.text"

        selectedEvent = event
        comment["event"] = selectedEvent
        comment["author"] = PFUser.current()!

        event.add(comment, forKey: "Comments")

        event.saveInBackground { (success, error) in
            if success {
                print("Comment saved")
            } else {
                print("Error saving comment")
            }
        }
        
        // Clear and dismiss the input bar
        commentBar.inputTextView.text = nil

        showsCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }
    
//    @objc func keyboardWillBeHidden(note: Notification) {
//        commentBar.inputTextView.text = nil
//        showsCommentBar = false
//        becomeFirstResponder()
//    }

//    func setupToolbar() {
//        let bar = UIToolbar()
//        let doneBotton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissKeyboard))
//        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
//        bar.items = [flexSpace, flexSpace, doneBotton]
//        bar.sizeToFit()
//        commentField.inputAccessoryView = bar
//        commentField.inputAccessoryView = bar
//    }
//
//    @objc func dismissKeyboard() {
//        view.endEditing(true)
//    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
