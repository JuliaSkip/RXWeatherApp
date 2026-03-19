//
//  WeatherViewModel.swift
//  RXSkip03
//
//  Created by Скіп Юлія Ярославівна on 09.02.2026.
//
import Foundation
import RxSwift
import RxDataSources
import RxCocoa
import UIKit

final class WeatherViewModel {
    
    private let geocodingManager: GeocodingManagerProtocol
    private let weatherManager: WeatherManagerProtocol
    private let scheduler: SchedulerType

    let cityText = BehaviorRelay<String>(value: "")

    private let _sections = BehaviorRelay<[WeatherSection]>(value: [])
    private(set) lazy var sections = _sections
        .distinctUntilChanged()
        .asObservable()

    private let _isPlaceholderHidden = BehaviorRelay<Bool>(value: false)
    private(set) lazy var isPlaceholderHidden = _isPlaceholderHidden
        .distinctUntilChanged()
        .asObservable()

    private let bag = DisposeBag()

    init(
        geocodingManager: GeocodingManagerProtocol = GeocodingAPIManager(),
        weatherManager: WeatherManagerProtocol = WeatherAPIManager(),
        scheduler: SchedulerType = MainScheduler.instance
    ) {
        self.geocodingManager = geocodingManager
        self.weatherManager = weatherManager
        self.scheduler = scheduler
        bind()
    }

    private func bind() {
        cityText
            .debounce(.milliseconds(500), scheduler: self.scheduler)
            .distinctUntilChanged()
            .flatMapLatest { [weak self] city -> Observable<[WeatherSection]> in
                guard !city.isEmpty, let self else { return .just([]) }
                return self.fetchForecast(for: city)
            }
            .bind(onNext: { [weak self] sections in
                guard let self else { return }
                self._sections.accept(sections)
                self._isPlaceholderHidden.accept(!sections.isEmpty)
            })
            .disposed(by: bag)
    }

    private func fetchForecast(for city: String) -> Observable<[WeatherSection]> {
        geocodingManager
            .getCoordinates(for: city)
            .flatMap { location in
                self.weatherManager.getWeatherForCityWith(lat: location.lat, lon: location.lon)
            }
            .map { forecast in
                let days = self.weatherManager.dayForecasts(from: forecast)
                return [
                    WeatherSection(
                        header: "Прогноз погоди для \(days.first?.city ?? city), \(days.first?.country ?? "")",
                        items: days
                    )
                ]
            }
            .asObservable()
            .catchAndReturn([])
    }
}
