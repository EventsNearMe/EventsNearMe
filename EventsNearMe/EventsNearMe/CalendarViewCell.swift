//
//  CalendarViewCell.swift
//  EventsNearMe
//
//  Created by Weiwei Shi on 11/17/21.
//

import UIKit

class buttonWithID: UIButton{
    var event: [String:Any]!
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
//        eventOneButton.setTitle("", for: .normal)
//        eventTwoButton.setTitle("", for: .normal)
        contentView.addSubview(eventOneButton)
        contentView.addSubview(eventTwoButton)
    }
    
//    override func prepareForReuse() {
//        for subview in contentView.subviews{
//            if subview is buttonWithID{
//                print("in cell sub view")
//                subview.removeFromSuperview()
//            }
//        }
//        setupViews()
//    }
    
//    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
//        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)
//        layoutAttributes.frame.size = contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
//        return layoutAttributes
//    }
//    private lazy var eventButton: buttonWithID = {
//        let button = buttonWithID()
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.titleLabel?.textAlignment = .left
//        button.titleLabel.font = UIFont.systemFont(ofSize: 7.0)
//        button.titleLabel?.numberOfLines = 3
//        return button
//    }
//    print(self.eventsDate[date]?.count)
//    self.eventsDate[date]?.forEach{
//    print($0)
//    let eventName = $0["name"] as! String
//    let button = buttonWithID(frame: CGRect(x: 0, y: y, width: cell.readableContentGuide.layoutFrame.width, height: 35.0))
//    y += 35.0
//    button.setTitle(eventName, for: .normal)
//    button.setTitleColor(.black, for: .normal)
//    button.setTitleColor(.red, for: .selected)
//    button.titleLabel?.font = UIFont.systemFont(ofSize: 9.0)
//    button.titleLabel?.numberOfLines = 3
//
//    button.event = $0
//    button.addTarget(self, action: #selector(self.buttonClicked(_:)), for: .touchUpInside)
//    cell.addSubview(button)
    
}
