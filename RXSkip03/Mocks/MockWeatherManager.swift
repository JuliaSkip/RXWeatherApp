//
//  MockWeatherProtocol.swift
//  RXSkip03
//
//  Created by Скіп Юлія Ярославівна on 17.02.2026.
//

import RxSwift
import Foundation

nonisolated
final class MockWeatherManager: WeatherManagerProtocol {
    func getWeatherForCityWith(lat: Double = 49.5535, lon: Double = 25.5948) -> Single<ForecastResponse> {
        let items = [
            makeMockForecastItem(date: Date(),  temp: 5),
        ]
        
        let response = makeMockForecastResponse(items: items)
        
        return .just(response)
    }
    
    func dayForecasts(from response: ForecastResponse) -> [DayForecast] {
        return [
            DayForecast(
                date: Date(),
                dayTemp: 10,
                nightTemp: 5,
                windSpeed: 3,
                rainVolume: 3,
                icon: "04d",
                city: "Ternopil",
                country: "UA"
            )
        ]
    }
    
    func makeMockForecastItem(date: Date, temp: Double) -> ForecastItem {
        ForecastItem(
            dt: date.timeIntervalSince1970,
            main: MainWeather(
                temp: temp,
                feelsLike: temp,
                tempMin: temp,
                tempMax: temp,
                pressure: 1000,
                seaLevel: nil,
                grndLevel: nil,
                humidity: 80,
                tempKf: nil
            ),
            weather: [
                Weather(id: 804, main: "Clouds", description: "хмарно", icon: "04d")
            ],
            clouds: Clouds(all: 90),
            wind: Wind(speed: 3.0, deg: 100, gust: nil),
            visibility: 10_000,
            pop: 0,
            rain: Rain(threeHours: 1.2),
            snow: nil,
            sys: Sys(pod: "d"),
            dtTxt: ""
        )
    }
    
    func makeMockForecastResponse(items: [ForecastItem]) -> ForecastResponse {
        ForecastResponse(
            cod: "200",
            message: 0,
            cnt: items.count,
            list: items,
            city: City(
                id: 691650,
                name: "Ternopil",
                coord: Coordinate(lat: 49.5535, lon: 25.5948),
                country: "UA",
                population: 235676,
                timezone: 7200,
                sunrise: 1771219568,
                sunset: 1771256254
            )
        )
    }
    
}
