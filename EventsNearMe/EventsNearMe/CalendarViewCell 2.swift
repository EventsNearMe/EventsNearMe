//
//  CalendarViewCell.swift
//  EventsNearMe
//
//  Created by Weiwei Shi on 11/17/21.
//

import UIKit
import Parse

class buttonWithID: UIButton{
    var event:PFObject!
}

class CalendarViewCell: UICollectionViewCell {
    @IBOutlet weak var dateLabel: UILabel!

    var eventOneButton = buttonWithID()
    
    var eventTwoButton = buttonWithID()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    func setupViews(){
        contentView.addSubview(eventOneButton)
        contentView.addSubview(eventTwoButton)
        eventOneButton.isHidden = true
        eventTwoButton.isHidden = true
    }
    
    override func prepareForReuse() {
        eventOneButton.isHidden = true
        eventTwoButton.isHidden = true
    }
    
}
