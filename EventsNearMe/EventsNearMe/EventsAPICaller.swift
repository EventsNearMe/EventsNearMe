//
//  EventsAPICaller.swift
//  EventsNearMe
//
//  Created by Weiwei Shi on 11/9/21.
//

import Foundation
import Parse

class EventsAPICaller{
    static let client = EventsAPICaller ()
    var events = [PFObject]()
    func getEventsByPostalCode(postalCode: Int, radius: Int, completion: @escaping ([[String:Any]]?) -> Void){
        let p = String(postalCode)
        let r = String(radius)
        let url = URL(string: "https://app.ticketmaster.com/discovery/v2/events?apikey=3UJFG9ApE8TRi0TlE17F5jAQZL9q6OYS&postalCode="+p+"&radius="+r+"&unit=miles")!
        print(url)
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10)
        
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request){ (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
            }else if let data = data {
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                
                let embedded = dataDictionary["_embedded"] as! [String: Any]
                let events = embedded["events"] as! [[String:Any]]

                return completion(events)
            }
        }
        task.resume()
    }
    func getEventsByStateCode(StateCode: String, completion: @escaping ([[String:Any]]?) -> Void){
        let url = URL(string: "https://app.ticketmaster.com/discovery/v2/events?apikey=3UJFG9ApE8TRi0TlE17F5jAQZL9q6OYS&stateCode=\(StateCode)")!
       // print(url)
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10)
        
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request){ (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
            }else if let data = data {
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                
                let embedded = dataDictionary["_embedded"] as! [String: Any]
                let events = embedded["events"] as! [[String:Any]]
                self.loadEventsToDB(Events: events)
                return completion(events)
            }
        }
        task.resume()
    }
    
    private func loadEventsToDB(Events: [[String:Any]]){
        if(!Events.isEmpty){
            //get all events currently inside back4App database
            var dbEvents = [PFObject]()
            let query = PFQuery(className: "Event")
            query.includeKey("eventId")
            query.findObjectsInBackground{(events, error) in
                if events != nil{
                    dbEvents = events!
                    //convert events from query into an Array
                    var eventArr = [String]()
                    print("dbEvents.size = \(dbEvents.count)")
                    for event in dbEvents{
                        eventArr.append(event["eventId"] as! String)
                    }
                    //for each event from API request, do nothing if it already exists in DB,
                    //add to DB if not
                    for event in Events{
                        let eventId = event["id"] as! String
                        if eventArr.contains(eventId){
                            //print("event already exist")
                        }
                        else {
                            let pfEvent = PFObject(className: "Event")
                            pfEvent["eventId"] = event["id"] as! String
                            pfEvent["Name"] = event["name"] as! String
                            pfEvent["getTicket"] = event["url"] as! String
                            
                            let dates = event["dates"] as! [String:Any]
                            let start = dates["start"] as! [String:Any]
                            let localDate = start["localDate"] as! String
                            pfEvent["Date"] = localDate
                            
                            let localTime = start["localTime"] as! String
                            pfEvent["Time"] = localTime
                            
//                            let dateTime = String(localDate+" "+localTime)
//                            let dateFormatter = DateFormatter()
//                            dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
//                            let dbDate = dateFormatter.date(from: dateTime)
//                            pfEvent["dbDate"] = dbDate
//                            print(dateTime)
//                            print(dbDate)
                            
                            
                            let embedded = event["_embedded"] as! [String:Any]
                            let venueInfo = embedded["venues"] as! [[String:Any]]
                            let venueName = venueInfo[0]["name"] as! String
                            pfEvent["venueName"] = venueName
                            
                            let venueCity = venueInfo[0]["city"] as! [String:String]
                            let venueState = venueInfo[0]["state"] as! [String:String]
                            let venueAddress = venueInfo[0]["address"] as! [String:String]
                            let venueLocation = "\(String(venueAddress["line1"] ?? "")) \(venueCity["name"] ?? ""),\(venueState["stateCode"] ?? "") \(venueInfo[0]["postalCode"] as! String)"
                            pfEvent["venueAddress"] = venueLocation
                            
                            let attractions = embedded["attractions"] as! [[String: Any]]
                            let attractions2 = attractions[0]
                            let images = attractions2["images"] as! [[String: Any]]
                            let images2 = images[8]
                            pfEvent["posterOneURL"] = images2["url"] as! String

                            let attractions3 = attractions.last
                            let imagesSecond = attractions3!["images"] as! [[String: Any]]
                            let images3 = imagesSecond[8]
                            pfEvent["posterTwoURL"] = images3["url"] as! String
                            
                            let category = event["classifications"] as! [[String: Any]]
                            let segment = category[0]["segment"] as! [String: Any]
                            pfEvent["category"] = segment["name"] as! String
                            
                            let genre = category[0]["genre"] as! [String: Any]
                            pfEvent["genre"] = genre["name"] as! String
                            let subGenre = category[0]["subGenre"] as! [String:Any]
                            pfEvent["subGenre"] = subGenre["name"] as! String
                            pfEvent.saveInBackground{(success, error) in
                                if success {
                                    print("\(event["name"]as! String) \(localDate) saved!")
                                }
                                else{
                                    print("error saving event!")
                                }
                                
                            }
                            
                        }
                    }
                }
                else{
                    print("error \(String(describing: error?.localizedDescription))")
                }
            }
        }
    }
}
