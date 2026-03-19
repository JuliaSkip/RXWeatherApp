//
//  WeatherSection.swift
//  RXSkip03
//
//  Created by Скіп Юлія Ярославівна on 09.02.2026.
//
import RxDataSources

struct WeatherSection: Equatable {
    var header: String
    var items: [Item]
}

extension WeatherSection: SectionModelType {
    typealias Item = DayForecast

    init(original: WeatherSection, items: [Item]) {
        self = original
        self.items = items
        self.header = original.header
    }
}
