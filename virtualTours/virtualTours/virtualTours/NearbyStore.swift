
import Foundation

struct NearbyStore {
    private let serverUrl = "https://xy62cwh158.execute-api.us-east-2.amazonaws.com/nearbySMS"

    func getNearby(refresh: @escaping () -> (),
                   completion: @escaping () -> ()) {
        guard let apiUrl = URL(string: serverUrl) else {
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
