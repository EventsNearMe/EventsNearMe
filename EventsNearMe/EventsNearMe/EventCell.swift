//
//  EventCell.swift
//  EventsNearMe
//
//  Created by Sarah Zheng on 11/13/21.
//

import UIKit
import Parse
import Alamofire
import SwiftUI

class EventCell: UITableViewCell{
    
    
    
    var favorited: Bool?
    var event: PFObject!
    
    @IBOutlet weak var posterView: UIImageView!
    @IBOutlet weak var secondPosterView: UIImageView!
    @IBOutlet weak var eventLabel: UILabel!
    @IBOutlet weak var datetimeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var FavButton: UIButton!
    
    var detectFav : (() -> Void)? = nil
   // var getFavBool : (() -> Bool)? = nil
    
    @IBAction func favoriteEvent(_ sender: UIButton) {
//        if let getFavBoolAction = self.detectFav {
//            favorited = getFavBoolAction()
//        }
        flipFavoriteState()
        if let favoriteAction = self.detectFav {
            favoriteAction()
        }
        
        
    }
    
    public func flipFavoriteState() {
        favorited = !favorited!
        
        animate()
    }

    let unfavoriteImage = UIImage(named: "favor-icon")
    let favoriteImage = UIImage(named: "favor-icon-red")
    
    private func animate() {
        UIView.animate(withDuration: 0.1, animations: {
//            var newImage = UIImage()
//            if self.favorited! {
//                newImage = self.favoriteImage!
//            }else {
//                newImage = self.unfavoriteImage!
//            }
            let newImage = self.favorited! ? self.favoriteImage : self.unfavoriteImage
            self.FavButton.transform = self.transform.scaledBy(x: 0.8, y: 0.8)
            self.FavButton.setImage(newImage, for: .normal)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1, animations: {
                self.FavButton.transform = CGAffineTransform.identity
            })
        })
    }
    
    
    
    
    
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
