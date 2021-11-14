//
//  AllEventsDetailsViewController.swift
//  EventsNearMe
//
//  Created by Weiwei Shi on 11/12/21.
//

import UIKit

class AllEventsDetailsViewController: UIViewController {

    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var eventImage: UIImageView!
    
    var event: [String:Any]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        eventNameLabel.text = event["name"] as? String
        eventNameLabel.sizeToFit()
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
