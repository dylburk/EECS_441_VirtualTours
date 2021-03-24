import Foundation

struct NearbyStore {
    private let serverUrl = "https://xy62cwh158.execute-api.us-east-2.amazonaws.com/nearbySMS"
    let phoneNumberKey = "phoneNumber"
    func getNearby(refresh: @escaping () -> (),
                   completion: @escaping () -> ()) {

        var modifiedUrl = serverUrl
        let defaults = UserDefaults.standard
        if let phoneNumberValue = defaults.string(forKey: phoneNumberKey) {
                    modifiedUrl = serverUrl + "?phone=" + phoneNumberValue
                    modifiedUrl = modifiedUrl + "&lat=42.279343&long=-83.740889"
                    print(modifiedUrl)
        } else {
            return
        }
        
        guard let apiUrl = URL(string: modifiedUrl) else {
            print("getChatts: Bad URL")
            return
        }
        
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            defer { completion() }
            guard let data = data, error == nil else {
                print("getChatts: NETWORKING ERROR")
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("getChatts: HTTP STATUS: \(httpStatus.statusCode)")
                return
            }
            
            
        }
        task.resume()
    }

}
