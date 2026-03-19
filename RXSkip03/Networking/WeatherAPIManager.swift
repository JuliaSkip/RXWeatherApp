//
//  WeatherAPI.swift
//  RXSkip03
//
//  Created by Скіп Юлія Ярославівна on 09.02.2026.
//
import Foundation
import RxSwift

class WeatherAPIManager : WeatherManagerProtocol {
    
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func getWeatherForCityWith(lat: Double, lon: Double) -> Single<ForecastResponse> {
        let urlString = "\(Constants.BASE_URL)/data/2.5/forecast?lat=\(lat)&lon=\(lon)&units=metric&lang=uk&appid=\(Constants.API_KEY)"
 

        return Single<ForecastResponse>.create { single in
            
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
                    let result = try JSONDecoder().decode(ForecastResponse.self, from: data)
                    single(.success(result))

                } catch {
                    single(.failure(error))
                }
                
            }
            
            task.resume()
            
            return Disposables.create{ task.cancel() }
        }
    }
    
    
    func dayForecasts(from response: ForecastResponse) -> [DayForecast] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0).self ?? TimeZone.current

        let grouped = Dictionary(grouping: response.list) {
            calendar.startOfDay(for: $0.date)
        }

        return grouped.sorted(by: { $0.key < $1.key }).map { (_, items) in
            
            let targetDayHour = 12
            let dayItem = items.min(by: {
                abs(calendar.component(.hour, from: $0.date) - targetDayHour)
                <
                abs(calendar.component(.hour, from: $1.date) - targetDayHour)
            })
            
            let targetNightHour = 21
            let nightItem = items.min(by: {
                abs(calendar.component(.hour, from: $0.date) - targetNightHour)
                <
                abs(calendar.component(.hour, from: $1.date) - targetNightHour)
            })

            return DayForecast(
                date: dayItem?.date,
                dayTemp: dayItem?.main.temp,
                nightTemp: nightItem?.main.temp,
                windSpeed: dayItem?.wind.speed,
                rainVolume: dayItem?.rain?.threeHours,
                icon: dayItem?.weather.first?.icon,
                city: response.city.name,
                country: response.city.country
            )
        }
    }
}
