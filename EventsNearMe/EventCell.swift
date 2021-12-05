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
    @IBOutlet weak var locationLabel: UILabel!
    
    
   // var favorited: Bool = false
    
//    func setFavorite(_ isFavorited: Bool) {
//        favorited = isFavorited
//        if(favorited) {
//            favButton.setImage(UIImage(named: "favor-icon-red"), for: UIControl.State.normal)
//        }else {
//            favButton.setImage(UIImage(named: "favor-icon"), for: UIControl.State.normal)
//        }
//
//    }
    var twoPosterConstraint = NSLayoutConstraint()
    var onePosterConstraint = NSLayoutConstraint()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        onePosterConstraint = NSLayoutConstraint(item: self.posterView!, attribute: .trailing, relatedBy: .equal, toItem: self.secondPosterView, attribute: .trailing, multiplier: 1, constant: 1)
        twoPosterConstraint = NSLayoutConstraint(item: self.posterView!, attribute: .trailing, relatedBy: .equal, toItem: self.secondPosterView, attribute: .leading, multiplier: 1, constant: 0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func onePoster() {
        twoPosterConstraint.isActive = false
        onePosterConstraint.isActive = true
    }
    
    func twoPoster() {
        onePosterConstraint.isActive = false
        twoPosterConstraint.isActive = true
    }

}
