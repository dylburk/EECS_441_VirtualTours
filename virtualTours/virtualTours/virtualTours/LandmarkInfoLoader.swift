//
//  LoadLandmarks.swift
//  virtualTours
//
//  Created by Hunter Harloff on 3/24/21.
//

import CoreLocation
import Foundation


class LandmarkInfoLoader{
    
    static var cache = [String:LandmarkInfo]()
    
    let apiURL = "https://pusio2l3ad.execute-api.us-east-2.amazonaws.com/landmark?"
    
    func loadLandmark(id: String, handler: @escaping (LandmarkInfo?, NSError?) -> Void) {
        
        print("loading landmark info")
        
        print(LandmarkInfoLoader.cache)
        
        if let cachedObject = LandmarkInfoLoader.cache[id] {
            handler(cachedObject, nil)
            return
        }
        
        let uri = apiURL + "id=\(id)"
        
        let url = URL(string: uri)!
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let dataTask = session.dataTask(with: url) { data, response, error in
            print("FINISHED")
            if let error = error {
                print(error)
            } else if let httpResponse = response as? HTTPURLResponse {
                print(data!)
                print(httpResponse.statusCode)
                if httpResponse.statusCode == 200 {
                    do {
                        let responseObject = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                        guard let responseDict = responseObject as? NSDictionary else {
                            handler(nil, NSError())
                            return
                        }
                        
                        guard let result = responseDict.object(forKey: "landmark") as? NSDictionary  else {
                            handler(nil, NSError())
                            return
                        }
                        
                        print(result)
                        
                        let name = result.object(forKey: "name") as! String
                        let types = result.object(forKey: "types") as! [String]
                        let description = "This is a description"
                        let address = result.object(forKey: "address") as! String
                        let website = result.object(forKey: "website") as! String
                        let rating = result.object(forKey: "rating") as! Double
                        let map = result.object(forKey: "map") as! String
                        let phone = result.object(forKey: "phone") as! String
                        
                        guard let hours = result.object(forKey: "hours") as? NSDictionary  else {
                            handler(nil, NSError())
                            return
                        }
                        
                        let open = hours.object(forKey: "open_now") as! Bool
                        
                        let landmarkInfo = LandmarkInfo(id: id, name: name, types: types, description: description,
                                                        address: address, website: website, rating: rating, phone: phone, map: map, open: open)
                        
                        LandmarkInfoLoader.cache[id] = landmarkInfo
                        print("handler called")
                        handler(landmarkInfo, nil)

                    } catch let error as NSError {
                        print("error called")
                        handler(nil, error)
                    }
                }
            }
        }

        dataTask.resume()
    }
    
}
    
    
