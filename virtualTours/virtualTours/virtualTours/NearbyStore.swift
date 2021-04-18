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
            if let error = error {
                print(error)
            } else if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    print(data!)
                    return
                } else {
                    print("nearbySMS: HTTP STATUS: \(httpResponse.statusCode)")
                    return
                }
            }
        }
        task.resume()
    }
}
