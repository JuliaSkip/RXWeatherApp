//
//  GeocodingAPIManager.swift
//  RXSkip03
//
//  Created by Скіп Юлія Ярославівна on 09.02.2026.
//
import Foundation
import RxSwift

class GeocodingAPIManager: GeocodingManagerProtocol {
    
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }

    public func getCoordinates(for cityName: String) -> Single<GeocodingResult> {
        let urlString = "\(Constants.BASE_URL)/geo/1.0/direct?q=\(cityName)&limit=1&appid=\(Constants.API_KEY)"
        
        return Single<GeocodingResult>.create { single in
            
            guard let url = URL(string: urlString) else {
                single(.failure(URLError(.badURL)))
                return Disposables.create()
            }
            
            let task = self.session.dataTask(with: url){ data, _ , error in
                
                if let error = error {
                    single(.failure(error))
                    return
                }
                
                guard let data = data else {
                    single(.failure(NSError(domain: "Bad responce", code: 0)))
                    return
                }
                
                do {
                    let results = try JSONDecoder().decode([GeocodingResult].self, from: data)
                    
                    guard let city = results.first else {
                        single(.failure(NSError(domain: "Error decoding json", code: 0)))
                        return
                    }
                    
                    single(.success(city))
                    
                } catch {
                    single(.failure(error))
                }
                
            }
            
            task.resume()
            
            return Disposables.create{ task.cancel() }
        }
    }
}
