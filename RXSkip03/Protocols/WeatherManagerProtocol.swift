//
//  WeatherManagerProtocol.swift
//  RXSkip03
//
//  Created by Скіп Юлія Ярославівна on 16.02.2026.
//

import Foundation
import RxSwift

protocol WeatherManagerProtocol {
    func getWeatherForCityWith(lat: Double, lon: Double) -> Single<ForecastResponse>
    func dayForecasts(from response: ForecastResponse) -> [DayForecast]
}
