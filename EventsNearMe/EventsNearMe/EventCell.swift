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
    var onePosterConstraint2 = NSLayoutConstraint()
    var onePosterConstraint3 = NSLayoutConstraint()
    var onePosterConstraint4 = NSLayoutConstraint()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        onePosterConstraint = NSLayoutConstraint(item: self.posterView!, attribute: .width, relatedBy: .equal, toItem: self.secondPosterView, attribute: .width, multiplier: 2, constant: 164)
        onePosterConstraint2 = NSLayoutConstraint(item: self.posterView!, attribute: .trailing, relatedBy: .equal, toItem: self.eventLabel, attribute: .leading, multiplier: 1, constant: -8)
        onePosterConstraint3 = NSLayoutConstraint(item: self.eventLabel!, attribute: .leading, relatedBy: .equal, toItem: self.datetimeLabel, attribute: .leading, multiplier: 1, constant: 0)
        onePosterConstraint4 = NSLayoutConstraint(item: self.eventLabel!, attribute: .leading, relatedBy: .equal, toItem: self.locationLabel, attribute: .leading, multiplier: 1, constant: 0)
        twoPosterConstraint = NSLayoutConstraint(item: self.posterView!, attribute: .trailing, relatedBy: .equal, toItem: self.secondPosterView, attribute: .leading, multiplier: 1, constant: 0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func onePoster() {
        twoPosterConstraint.isActive = false
        onePosterConstraint.isActive = true
        onePosterConstraint2.isActive = true
        onePosterConstraint3.isActive = true
        onePosterConstraint4.isActive = true
    }
    
    func twoPoster() {
        onePosterConstraint.isActive = false
        twoPosterConstraint.isActive = true
        onePosterConstraint2.isActive = false
        onePosterConstraint3.isActive = false
        onePosterConstraint4.isActive = false
    }

}
