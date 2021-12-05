//
//  CalendarDetailCommentCell.swift
//  EventsNearMe
//
//  Created by Weiwei Shi on 11/19/21.
//

import UIKit

class CalendarDetailCommentCell: UITableViewCell {
    @IBOutlet weak var authorLabel: UILabel!
    
    @IBOutlet weak var commentLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
