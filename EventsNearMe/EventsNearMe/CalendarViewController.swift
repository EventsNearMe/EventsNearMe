//
//  CalendarViewController.swift
//  EventsNearMe
//
//  Created by Weiwei Shi on 11/17/21.
//

import UIKit

class buttonWithID: UIButton{
    var event: [String:Any]?
}

class CalendarViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var collectionView: UICollectionView!
    var events = [[String:Any]]()
    var eventsDate = [String:[[String:Any]]]()
    let calendar = Calendar(identifier: .gregorian)
    let selectedDate: Date = Date()
    
    private lazy var days = generateDaysInMonth(for: selectedDate)
    private var numberOfWeeksInBaseDate: Int {
        calendar.range(of: .weekOfMonth, in: .month, for: selectedDate)?.count ?? 0
    }
    
    private lazy var dateFormatter: DateFormatter = {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "d"
      return dateFormatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        collectionView.dataSource = self
        collectionView.delegate = self
        setCollectionViewLayout()
        getInitialEvents(StateCode: "NY")
        //idEventsByDate()
    }

    func getInitialEvents(StateCode: String){
        EventsAPICaller.client.getEventsByStateCode(StateCode: StateCode){(events) in
            guard let events = events else{
                return
            }
            self.events = events
            self.idEventsByDate()
            self.collectionView.reloadData()
        }
    }
    
    func idEventsByDate(){
        print("events.count\(self.events.count)")
        for event in events{
            let dates = event["dates"] as! [String:Any]
            let start = dates["start"] as! [String:Any]
            let date = start["localDate"] as! String
            
            if self.eventsDate[date] == nil {
                self.eventsDate[date] = [[String:Any]]()
            }
            self.eventsDate[date]?.append(event as [String : Any])
        }
    }
    func setCollectionViewLayout(){
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let width = (view.frame.size.width - layout.minimumInteritemSpacing * 6)/7
        layout.itemSize = CGSize(width: width, height: view.frame.size.height / CGFloat(numberOfWeeksInBaseDate+1))
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return days.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarViewCell", for: indexPath) as! CalendarViewCell
        let day = days[indexPath.row]
        cell.dateLabel.text = day.number
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let date = dateFormatter.string(from: day.date)
        //print(date)
        var y = 20.0
        //print(self.eventsDate[date]?.count)
        self.eventsDate[date]?.forEach{
            let eventName = $0["name"] as! String
            let button = buttonWithID(frame: CGRect(x: 0, y: y, width: cell.readableContentGuide.layoutFrame.width, height: 35.0))
            y += 35.0
            button.setTitle(eventName, for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.setTitleColor(.red, for: .selected)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 9.0)
            button.titleLabel?.numberOfLines = 3
            
            button.event = $0
            button.addTarget(self, action: #selector(self.buttonClicked(_:)), for: .touchUpInside)
            cell.addSubview(button)
        }
       
        
        return cell
    }
    @objc func buttonClicked(_ sender: buttonWithID){
        //print(sender.eventID)
       self.performSegue(withIdentifier: "showCalendarDetail", sender: sender)
    }
    
    override func prepare(for seque: UIStoryboardSegue, sender: Any?){
        let button = sender as! buttonWithID
        let calendarDetailViewController = seque.destination as! CalendarEventsDetailsViewController
        calendarDetailViewController.event = button.event!
    }

}
private extension CalendarViewController {
    func monthMetadata(for baseDate: Date) throws -> MonthMetadata{
        guard
            let numberOfDaysInMonth = calendar.range(of: .day, in: .month, for: baseDate)?.count,
            let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: baseDate))
        else{
            throw CalendarDataError.metadataGeneration
        }
        
        let firstDayWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        
        return MonthMetadata(
            numberOfDays: numberOfDaysInMonth,
            firstDay: firstDayOfMonth,
            firstDayWeekday: firstDayWeekday)
    }
    enum CalendarDataError: Error{
        case metadataGeneration
    }
    
    // 1
    func generateDaysInMonth(for baseDate: Date) -> [Day] {
      // 2
      guard let metadata = try? monthMetadata(for: baseDate) else {
        fatalError("An error occurred when generating the metadata for \(baseDate)")
      }

      let numberOfDaysInMonth = metadata.numberOfDays
      let offsetInInitialRow = metadata.firstDayWeekday
      let firstDayOfMonth = metadata.firstDay

      // 3
      var days: [Day] = (1..<(numberOfDaysInMonth + offsetInInitialRow))
        .map { day in
          // 4
          let isWithinDisplayedMonth = day >= offsetInInitialRow
          // 5
          let dayOffset =
            isWithinDisplayedMonth ?
            day - offsetInInitialRow :
            -(offsetInInitialRow - day)
          
          // 6
          return generateDay(
            offsetBy: dayOffset,
            for: firstDayOfMonth,
            isWithinDisplayedMonth: isWithinDisplayedMonth)
        }
      days += generateStartOfNextMonth(using: firstDayOfMonth)
      return days
    }

    // 7
    func generateDay(
      offsetBy dayOffset: Int,
      for baseDate: Date,
      isWithinDisplayedMonth: Bool
    ) -> Day {
      let date = calendar.date(
        byAdding: .day,
        value: dayOffset,
        to: baseDate)
        ?? baseDate

      return Day(
        date: date,
        number: dateFormatter.string(from: date),
        isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
        isWithinDisplayedMonth: isWithinDisplayedMonth
      )
    }

    // 1
    func generateStartOfNextMonth(
      using firstDayOfDisplayedMonth: Date
    ) -> [Day] {
      // 2
      guard
        let lastDayInMonth = calendar.date(
          byAdding: DateComponents(month: 1, day: -1),
          to: firstDayOfDisplayedMonth)
        else {
          return []
      }

      // 3
      let additionalDays = 7 - calendar.component(.weekday, from: lastDayInMonth)
      guard additionalDays > 0 else {
        return []
      }
      
      // 4
      let days: [Day] = (1...additionalDays)
        .map {
          generateDay(
          offsetBy: $0,
          for: lastDayInMonth,
          isWithinDisplayedMonth: false)
        }

      return days
    }

}

