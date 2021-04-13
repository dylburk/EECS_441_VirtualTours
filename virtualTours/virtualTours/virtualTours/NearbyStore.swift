import Foundation
import CoreLocation

struct NearbyStore {
    static let urlSession = URLSession(configuration: .default)
    private let serverUrl = "https://xy62cwh158.execute-api.us-east-2.amazonaws.com/nearbySMS"
    let phoneNumberKey = "phoneNumber"
    let sendNotifKey = "sendNotif"
    func getNearby(currentLocation: CLLocation,
                   refresh: @escaping () -> (),
                   completion: @escaping () -> ()) {
        let lat = String(format: "%.6f", currentLocation.coordinate.latitude)
        let long = String(format: "%.6f", currentLocation.coordinate.longitude)
        print(lat)
        var modifiedUrl = serverUrl
        let defaults = UserDefaults.standard
        
        let sendNotifs = defaults.bool(forKey: sendNotifKey)
        if (!sendNotifs) {
            print("user disabled notifications")
            return
        }
        
        if let phoneNumberValue = defaults.string(forKey: phoneNumberKey) {
            modifiedUrl = serverUrl + "?phone=" + phoneNumberValue
            modifiedUrl = modifiedUrl + "&lat=" + lat + "&long=" + long
            print(modifiedUrl)
        } else {
            return
        }
        
        
        
        guard let apiUrl = URL(string: modifiedUrl) else {
            print("nearbySMS: Bad URL")
            return
        }
        
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            defer { completion() }
            guard let _ = data, error == nil else {
                print("getChatts: NETWORKING ERROR")
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("nearbySMS: HTTP STATUS: \(httpStatus.statusCode)")
                return
            }
            
            
        }
        task.resume()
    }

}
