//
//  LoadLandmarks.swift
//  virtualTours
//
//  Created by Ved Ameresh on 3/12/21.
//

import CoreLocation
import Foundation

struct LandmarkLoader {
    
    let apiURL = "https://po4sn5eftg.execute-api.us-east-2.amazonaws.com/nearby?"
    
    func loadLandmarks(location: CLLocation, radius: Int = 20, handler: @escaping (NSDictionary?, NSError?) -> Void) {
        
        
        let lat = location.coordinate.latitude
        let long = location.coordinate.longitude
        
        let uri = apiURL + "longitude=\(long)&latitude=\(lat)"
        
        
        let url = URL(string: uri)!
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let dataTask = session.dataTask(with: url) { data, response, error in
            if let error = error {
                print(error)
            } else if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    //print(data!)
                    do {
                        let responseObject = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                        guard let responseDict = responseObject as? NSDictionary else {
                            return
                        }
                        
                        //print("RESPONSE:")
                        //(responseDict)
                    
                        handler(responseDict, nil)

                    } catch let error as NSError {
                        handler(nil, error)
                    }
                }
            }
        }

        dataTask.resume()
    }

}
    
    
