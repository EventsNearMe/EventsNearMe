//
//  EventsAPICaller.swift
//  EventsNearMe
//
//  Created by Weiwei Shi on 11/9/21.
//

import Foundation

class EventsAPICaller{
    static let client = EventsAPICaller ()
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
}
