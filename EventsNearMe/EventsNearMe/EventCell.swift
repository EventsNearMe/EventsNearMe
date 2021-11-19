//
//  EventCell.swift
//  EventsNearMe
//
//  Created by Sarah Zheng on 11/13/21.
//

import UIKit

class EventCell: UITableViewCell {

    @IBOutlet weak var posterView: UIImageView!
    @IBOutlet weak var secondPosterView: UIImageView!
    @IBOutlet weak var eventLabel: UILabel!
    @IBOutlet weak var datetimeLabel: UILabel!
    @IBOutlet weak var favButton: UIButton!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    
    
    @IBAction func favoriteEvent(_ sender: Any) {
        
    }
    
    var favorited: Bool = false
    
    func setFavorite(_ isFavorited: Bool) {
        favorited = isFavorited
        if(favorited) {
            favButton.setImage(UIImage(named: "favor-icon-red"), for: UIControl.State.normal)
        }else {
            favButton.setImage(UIImage(named: "favor-icon"), for: UIControl.State.normal)
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
