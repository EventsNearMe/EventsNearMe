//
//  CalendarEventsDetailsViewController.swift
//  EventsNearMe
//
//  Created by Weiwei Shi on 11/12/21.
//

import UIKit

class CalendarEventsDetailsViewController: UIViewController {
    var event: [String: Any]!
    @IBOutlet weak var testLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        let dates = event["dates"] as! [String:Any]
        let start = dates["start"] as! [String:Any]
        
        testLabel.text = start["localDate"] as! String
        print(event)
        // Do any additional setup after loading the view.
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
