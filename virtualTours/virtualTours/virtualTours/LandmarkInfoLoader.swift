//
//  LoadLandmarks.swift
//  virtualTours
//
//  Created by Hunter Harloff on 3/24/21.
//

import CoreLocation
import Foundation

struct LandmarkInfoLoader {
    
    let apiURL = "https://pusio2l3ad.execute-api.us-east-2.amazonaws.com/landmark?"
    
    func loadLandmarks(id: String, handler: @escaping (NSDictionary?, NSError?) -> Void) {
        
        print("loading landmark info")
        
        let uri = apiURL + "id=\(id)"
        
        let url = URL(string: uri)!
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let dataTask = session.dataTask(with: url) { data, response, error in
            if let error = error {
                print(error)
            } else if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    print(data!)
                    do {
                        let responseObject = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                        guard let responseDict = responseObject as? NSDictionary else {
                            return
                        }
                        
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
    
    
