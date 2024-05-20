import Foundation

class APIManager {
    
    // MARK: - Method
    func createRequest(url: String, cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy) -> URLRequest? {
        guard let url = URL(string: url) else { return nil }
        var request = URLRequest(url: url, cachePolicy: cachePolicy)
        request.httpMethod = "GET"
        
        return request
    }
    
    func operateRequest<T: Decodable>(request: URLRequest?, type: T.Type) async -> T? {
        guard let request = request else { return nil }
        guard let (data, response) = try? await URLSession.shared.data(for: request) else { return nil }
        
        do {
            switch (response as! HTTPURLResponse).statusCode {
            case 200:
                debugPrint("OK")
            case 304:
                debugPrint("Not modified")
            case 422:
                debugPrint("Validation failed, or the endpoint has been spammed.")
            case 503:
                debugPrint("Service unavailable")
            default:
                break
            }
            let decodedData = try JSONDecoder().decode(type, from: data)
            return decodedData
        } catch {
            print("Error: \(error.localizedDescription)")
            return nil
        }
    }
    
    func operateRequest(request: URLRequest?) async -> Data? {
        guard let request = request else { return nil }
        guard let (data, _) = try? await URLSession.shared.data(for: request) else { return nil }
        return data
    }
}
