//
//  WeatherModel.swift
//  RXSkip03
//
//  Created by Скіп Юлія Ярославівна on 09.02.2026.
//
import Foundation

struct DayForecast: Equatable {
    let date: Date?
    let dayTemp: Double?
    let nightTemp: Double?
    let windSpeed: Double?
    let rainVolume: Double?
    let icon: String?
    let city: String?
    let country: String?
}

nonisolated
struct ForecastResponse: Codable {
    let cod: String
    let message: Int
    let cnt: Int
    let list: [ForecastItem]
    let city: City
}

struct ForecastItem: Codable {
    let dt: TimeInterval
    let main: MainWeather
    let weather: [Weather]
    let clouds: Clouds
    let wind: Wind
    let visibility: Int?
    let pop: Double?
    let rain: Rain?
    let snow: Snow?
    let sys: Sys
    let dtTxt: String

    enum CodingKeys: String, CodingKey {
        case dt
        case main
        case weather
        case clouds
        case wind
        case visibility
        case pop
        case rain
        case snow
        case sys
        case dtTxt = "dt_txt"
    }
}

extension ForecastItem {
    var date: Date {
        Date(timeIntervalSince1970: TimeInterval(dt))
    }
}

struct MainWeather: Codable {
    let temp: Double
    let feelsLike: Double
    let tempMin: Double
    let tempMax: Double
    let pressure: Int
    let seaLevel: Int?
    let grndLevel: Int?
    let humidity: Int
    let tempKf: Double?

    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure
        case seaLevel = "sea_level"
        case grndLevel = "grnd_level"
        case humidity
        case tempKf = "temp_kf"
    }
}

struct Weather: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct Clouds: Codable {
    let all: Int
}

struct Wind: Codable {
    let speed: Double
    let deg: Int
    let gust: Double?
}

struct Rain: Codable {
    let threeHours: Double?

    enum CodingKeys: String, CodingKey {
        case threeHours = "3h"
    }
}

struct Snow: Codable {
    let threeHours: Double?

    enum CodingKeys: String, CodingKey {
        case threeHours = "3h"
    }
}

struct Sys: Codable {
    let pod: String
}

struct City: Codable {
    let id: Int
    let name: String
    let coord: Coordinate
    let country: String
    let population: Int?
    let timezone: Int
    let sunrise: TimeInterval
    let sunset: TimeInterval
}

struct Coordinate: Codable {
    let lat: Double
    let lon: Double
}

