//
//  CalendarViewController.swift
//  EventsNearMe
//
//  Created by Weiwei Shi on 11/17/21.
//

import UIKit
import Parse

class CalendarViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var weekdayStackView: UIStackView!
    @IBOutlet weak var collectionView: UICollectionView!

    @IBAction func onPrevMonth(_ sender: Any) {
        self.selectedDate = self.calendar.date(byAdding: .month, value: -1, to: self.selectedDate) ?? self.selectedDate
        days = generateDaysInMonth(for: selectedDate)
        setCollectionViewLayout()
        collectionView.reloadData()
    }
    @IBAction func onNextMonth(_ sender: Any) {
        self.selectedDate = self.calendar.date(byAdding: .month, value: 1, to: self.selectedDate) ?? self.selectedDate
        days = generateDaysInMonth(for: selectedDate)
        setCollectionViewLayout()
        collectionView.reloadData()
    }
    var events = [PFObject]()
    var eventsDate = [String:[PFObject]]()
    let calendar = Calendar(identifier: .gregorian)
    var selectedDate: Date = Date()
    
    private lazy var monthFormatter: DateFormatter = {
      let dateFormatter = DateFormatter()
      dateFormatter.calendar = Calendar(identifier: .gregorian)
      dateFormatter.locale = Locale.autoupdatingCurrent
      dateFormatter.setLocalizedDateFormatFromTemplate("MMMM y")
      return dateFormatter
    }()
    
    private lazy var days = generateDaysInMonth(for: selectedDate)
    
    private lazy var dateFormatter: DateFormatter = {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "d"
      return dateFormatter
    }()

    @IBAction func onLogout(_ sender: Any) {
        PFUser.logOut()
        let main = UIStoryboard(name: "Main", bundle: nil)
                let loginNavController = main.instantiateViewController(identifier: "LoginNavigationController")

                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginNavController)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setDayOfWeek()
        collectionView.dataSource = self
        collectionView.delegate = self
        setCollectionViewLayout()
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        getInitialEvents(StateCode: "NY")
    }

    func getInitialEvents(StateCode: String){
        EventsAPICaller.client.getEventsByStateCode(StateCode: StateCode){(events) in
            guard let events = events else{
                return
            }
            
            let query = PFQuery(className: "Event")
            let today = Date()
            let nyToday = Calendar.current.date(byAdding: .hour, value: -5, to: today)!
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-dd"
            let date = dateFormatter.string(from: nyToday)
            query.whereKey("Date", greaterThanOrEqualTo: date);
            query.includeKeys(["favorite", "favorite.author"])
            query.findObjectsInBackground{(events, error) in
                if events != nil{
                    self.events = events!
                    self.idEventsByDate()
                    self.collectionView.reloadData()
                    print(self.events)
                }
                else{
                    print("unable to load events from bac4App")
                }
            }
        }
    }
    
    func idEventsByDate(){
        self.eventsDate.removeAll()
        for event in events{
            let date = event["Date"] as! String
            
            if self.eventsDate[date] == nil {
                self.eventsDate[date] = [PFObject]()
            }
            self.eventsDate[date]?.append(event as PFObject)
        }
    }
    
    func setDayOfWeek(){
        weekdayStackView.distribution = .fillEqually
        for dayNumber in 1...7 {
          let dayLabel = UILabel()
          dayLabel.font = .systemFont(ofSize: 12, weight: .bold)
          dayLabel.textColor = .secondaryLabel
          dayLabel.textAlignment = .center
          dayLabel.text = dayOfWeekLetter(for: dayNumber)
          dayLabel.isAccessibilityElement = false
          weekdayStackView.addArrangedSubview(dayLabel)
        }
    }
    func setCollectionViewLayout(){
        var numberOfWeeksInBaseDate: Int {
            calendar.range(of: .weekOfMonth, in: .month, for: selectedDate)?.count ?? 0
        }
        print(numberOfWeeksInBaseDate)
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let width = (view.frame.size.width - layout.minimumInteritemSpacing * 6)/7
        layout.itemSize = CGSize(width: width, height: collectionView.frame.size.height / CGFloat(numberOfWeeksInBaseDate))
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        monthLabel.text = monthFormatter.string(from: selectedDate)
        return days.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarViewCell", for: indexPath) as! CalendarViewCell
        let day = days[indexPath.row]
        cell.dateLabel.text = day.number
        if day.isWithinDisplayedMonth{
            cell.dateLabel.textColor = .black
        }else{
            cell.dateLabel.textColor = .gray
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let date = dateFormatter.string(from: day.date)
        if(self.eventsDate[date] != nil){
            let count = self.eventsDate[date]!.count
            if  count > 0 {
                cell.eventOneButton.isHidden = false
                cell.eventOneButton.frame = CGRect(x: 0, y: 30, width: cell.readableContentGuide.layoutFrame.width+6, height: 32)
                let eventName = self.eventsDate[date]?[0]["Name"] as! String
                cell.eventOneButton.setTitle(eventName, for: .normal)
                cell.eventOneButton.titleLabel?.font = UIFont.systemFont(ofSize: 9.0)
                cell.eventOneButton.setTitleColor(.white, for: .normal)
                cell.eventOneButton.titleLabel?.numberOfLines = 3
                cell.eventOneButton.contentHorizontalAlignment = .center
                //print(self.eventsDate[date]![0])
                cell.eventOneButton.event = self.eventsDate[date]![0]
                //print("did print\(cell.eventOneButton.event)")
                cell.eventOneButton.addTarget(self, action: #selector(self.buttonClicked(_:)), for: .touchUpInside)
            }
            if count > 1{
                cell.eventTwoButton.isHidden = false
                let eventName = self.eventsDate[date]?[1]["Name"] as! String
                cell.eventTwoButton.frame = CGRect(x: 0, y: 65, width: cell.readableContentGuide.layoutFrame.width+6, height: 32)
                cell.eventTwoButton.setTitle(eventName, for: .normal)
                cell.eventTwoButton.titleLabel?.font = UIFont.systemFont(ofSize: 9.0)
                cell.eventTwoButton.setTitleColor(.white, for: .normal)
                cell.eventTwoButton.titleLabel?.numberOfLines = 3
                cell.eventOneButton.contentHorizontalAlignment = .center
                cell.eventTwoButton.event = self.eventsDate[date]![1]
                cell.eventTwoButton.addTarget(self, action: #selector(self.buttonClicked(_:)), for: .touchUpInside)
            }
        
         
            if count > 2 {
                cell.etcButton.isHidden = false
                cell.etcButton.frame = CGRect(x: 0, y: 100, width: cell.readableContentGuide.layoutFrame.width+6, height: 20)
                cell.etcButton.setTitle("...", for: .normal)
                cell.etcButton.titleLabel?.font = UIFont.systemFont(ofSize: 20.0)
                cell.etcButton.setTitleColor(.white, for: .normal)
                var menuItems: [UIAction] {
                    var menu = [UIAction]()
                    for event in eventsDate[date]! {
                        let action = UIAction(title: event["Name"] as! String) { (action) in
                            cell.etcButton.event = event
                            self.buttonClicked(cell.etcButton)
                        }
                        menu.append(action)
                    }
                    return menu
                }
                var demoMenu: UIMenu {
                    return UIMenu(title: "", image: nil, identifier: nil, options: [], children: menuItems)
                }
                cell.etcButton.menu = demoMenu
                cell.etcButton.showsMenuAsPrimaryAction = true
            }
        }
        return cell
    }
    @objc func buttonClicked(_ sender: buttonWithID){
       self.performSegue(withIdentifier: "showCalendarDetail", sender: sender)
    }

    override func prepare(for seque: UIStoryboardSegue, sender: Any?){
        let button = sender as! buttonWithID
        let calendarDetailViewController = seque.destination as! CalendarEventsDetailsViewController
        calendarDetailViewController.event = button.event
        //print(button.event["Name"])
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
//        for day in days {
//            print(day.date)
//            print(day.isWithinDisplayedMonth)
//        }
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

    private func dayOfWeekLetter(for dayNumber: Int) -> String {
      switch dayNumber {
      case 1:
        return "SUN"
      case 2:
        return "MON"
      case 3:
        return "TUE"
      case 4:
        return "WED"
      case 5:
        return "THU"
      case 6:
        return "FRI"
      case 7:
        return "SAT"
      default:
        return ""
      }
    }

}

