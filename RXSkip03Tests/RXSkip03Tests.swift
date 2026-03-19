//
//  RXSkip03Tests.swift
//  RXSkip03Tests
//
//  Created by Скіп Юлія Ярославівна on 16.02.2026.
//

import XCTest
import RxTest
import RxSwift
import RxRelay
import RxBlocking
import RxCocoa
@testable import RXSkip03

final class RXSkip03Tests: XCTestCase {
    
    private var weatherVM: WeatherViewModel!
    private var bag: DisposeBag!
    private var scheduler: TestScheduler!
    private var geocodingManager: GeocodingAPIManager!
    private var weatherManager: WeatherAPIManager!
    private var mockGeocodingManager: MockGeocodingManager!
    private var mockWeatherManager: MockWeatherManager!
    
    private let testLat = 49.553516
    private let testLon = 25.594767
    
    private var isSchedulerStarted: Bool = false
    
    override func setUp(){
        super.setUp()
        self.scheduler = TestScheduler(initialClock: 0)
        self.bag = DisposeBag()
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        
        self.geocodingManager = GeocodingAPIManager(session: session)
        self.weatherManager = WeatherAPIManager(session: session)
        
        self.mockGeocodingManager = MockGeocodingManager()
        self.mockWeatherManager = MockWeatherManager()
        self.weatherVM = WeatherViewModel(
            geocodingManager: mockGeocodingManager,
            weatherManager: mockWeatherManager,
            scheduler: scheduler
        )
    }
    
    override func tearDown() {
        if isSchedulerStarted {
            scheduler.scheduleAt(1000) { [weak self] in
                guard let self else { return }
                self.resetVars()
            }
        } else {
            self.resetVars()
        }
        super.tearDown()
    }
    
    func resetVars(){
        self.bag = nil
        self.weatherVM = nil
        self.geocodingManager = nil
        self.weatherManager = nil
        MockURLProtocol.stubData = nil
        MockURLProtocol.stubError = nil
        self.mockWeatherManager = nil
        self.mockGeocodingManager = nil
    }
    
    /**
     Case: Successful retrieval of city coordinates via Geocoding API
     
     Preconditions:
     - MockURLProtocol returns valid JSON (Constants.GeocodingMockResponce)
     
     Expected behavior:
     - The Single completes successfully
     - The response is correctly decoded into the model
     - The returned name, lat, lon, and country match the mock data
     */
    func testGetCoordinatesSuccess() throws {
        MockURLProtocol.stubData = Constants.GeocodingMockResponce.data(using: .utf8)
        
        let result = try geocodingManager
            .getCoordinates(for: "Ternopil")
            .toBlocking()
            .single()
        
        XCTAssertEqual(result.name, "Ternopil")
        XCTAssertEqual(result.lat, testLat)
        XCTAssertEqual(result.lon, testLon)
        XCTAssertEqual(result.country, "UA")
    }
    
    /**
     Case: Verify that the geocoding manager properly emits an error when a network request fails
     
     Preconditions:
     - A network error is simulated by setting MockURLProtocol.stubError to URLError(.notConnectedToInternet)
     
     Expected behavior:
     - The request should not succeed; onSuccess should never be called
     - The request should fail, emitting an error through the onFailure callback
     */
    func testGetCoordinatesNetworkError() {
        MockURLProtocol.stubError = URLError(.notConnectedToInternet)
        
        geocodingManager.getCoordinates(for: "Ternopil")
            .subscribe(
                onSuccess: { _ in
                    XCTFail("Expected failure")
                },
                onFailure: { error in
                    XCTAssertNotNil(error)
                    XCTAssertEqual(error as? URLError, URLError(.notConnectedToInternet))
                }
            )
            .disposed(by: bag)
    }
    
    /**
     Case: Successful retrieval of city coordinates via Geocoding API
     
     Preconditions:
     - MockURLProtocol returns valid JSON (Constants.WeatherMockResponce)
     
     Expected behavior:
     - The Single completes successfully
     - The response is correctly decoded into the model
     - The returned list count is equal to mock data list count
     - The returned name, country, temp, icon, wind speed match the mock data
     */
    func testGetWeatherSuccess() throws {
        MockURLProtocol.stubData = Constants.WeatherMockResponce.data(using: .utf8)
        
        weatherManager.getWeatherForCityWith(lat: testLat, lon: testLon)
            .subscribe(
                onSuccess: { response in
                    XCTAssertEqual(response.list.count, 2)
                    XCTAssertEqual(response.city.name, "Ternopil")
                    XCTAssertEqual(response.city.country, "UA")
                    XCTAssertEqual(response.list.first?.main.temp, -5.9)
                    XCTAssertEqual(response.list.first?.weather.first?.icon, "04d")
                    XCTAssertEqual(response.list.first?.wind.speed, 2.11)
                },
                onFailure: { error in
                    XCTAssertNotNil(error)
                    XCTAssertEqual(error as? URLError, URLError(.notConnectedToInternet))
                }
            )
            .disposed(by: bag)
    }
    
    /**
     Case: Verify that the weather manager properly emits an error when a network request fails
     
     Preconditions:
     - A network error is simulated by setting MockURLProtocol.stubError to URLError(.notConnectedToInternet)
     
     Expected behavior:
     - The request should not succeed; onSuccess should never be called
     - The request should fail, emitting an error through the onFailure callback
     */
    func testGetWeatherNetworkError() {
        MockURLProtocol.stubError = URLError(.notConnectedToInternet)
        
        weatherManager.getWeatherForCityWith(lat: testLat, lon: testLon)
            .subscribe(
                onSuccess: { _ in
                    XCTFail("Expected failure")
                },
                onFailure: { error in
                    XCTAssertNotNil(error)
                    XCTAssertEqual(error as? URLError, URLError(.notConnectedToInternet))
                }
            )
            .disposed(by: bag)
    }
    
    /**
     Case: Aggregation of multiple forecast entries within the same calendar day.
     
     Preconditions:
     - All forecast items belong to the same day
     - Entries include morning (09:00), midday (12:00, 15:00), and evening (21:00) timestamps
     - Mock response contains valid weather metadata
     
     Expected behavior:
     - dayForecasts(from:) groups all entries into a single daily forecast
     - result.count equals 1
     - dayTemp corresponds to the 12:00 value (10°C)
     - nightTemp corresponds to the 21:00 value (-2°C)
     - City, country, wind speed, and icon match the mock data
     */
    func testDailyForecastForOneDay() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? TimeZone.current
        let baseDate = Date()
        
        guard let h9 = calendar.date(bySettingHour: 9,  minute: 0, second: 0, of: baseDate),
              let h12 = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: baseDate),
              let h15 = calendar.date(bySettingHour: 15, minute: 0, second: 0, of: baseDate),
              let h21 = calendar.date(bySettingHour: 21, minute: 0, second: 0, of: baseDate)
        else {return}
        
        let items = [
            mockWeatherManager.makeMockForecastItem(date: h9,  temp: 5),
            mockWeatherManager.makeMockForecastItem(date: h12, temp: 10),
            mockWeatherManager.makeMockForecastItem(date: h15, temp: 9),
            mockWeatherManager.makeMockForecastItem(date: h21, temp: -2)
        ]
        let response = mockWeatherManager.makeMockForecastResponse(items: items)
        
        
        let result = weatherManager.dayForecasts(from: response)
        let forecast = result.first

        
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(forecast?.dayTemp, 10)
        XCTAssertEqual(forecast?.nightTemp, -2)
        XCTAssertEqual(forecast?.city, "Ternopil")
        XCTAssertEqual(forecast?.country, "UA")
        XCTAssertEqual(forecast?.windSpeed, 3.0)
        XCTAssertEqual(forecast?.icon, "04d")
    }
    
    /**
     Case: Daily forecast aggregation across multiple calendar days
     
     Preconditions:
     - Two forecast entries are created: one for current date at 12:00 and one for nex day at 12:00
     - Both entries contain valid weather metadata (city, country, wind speed, icon)
     - No explicit night entries are provided for either day
     
     Expected behavior:
     - dayForecasts(from:) groups items by calendar day
     - The result contains two separate daily forecasts (result.count == 2)
     - For each day, since only one entry exists (at 12:00), both dayTemp and nightTemp
       fall back to the same value
     - City, country, wind speed, and icon match the mock data
     */
    func testDailyForecastsForMultipleDays() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? TimeZone.current
        let baseDate = Date()
        
        guard let nextDate = calendar.date(byAdding: .day, value: 1, to: baseDate),
              let baseDateTime = calendar.date(bySettingHour: 12,  minute: 0, second: 0, of: baseDate),
              let nextDateTime = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: nextDate)
        else { return }
        
        let items = [
            mockWeatherManager.makeMockForecastItem(date: baseDateTime, temp: 10),
            mockWeatherManager.makeMockForecastItem(date: nextDateTime, temp: 15)
        ]
        
        let response = mockWeatherManager.makeMockForecastResponse(items: items)
        
        let result = weatherManager.dayForecasts(from: response)
        let forecast = result.first
        
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(forecast?.dayTemp, 10)
        XCTAssertEqual(forecast?.nightTemp, 10)
        XCTAssertEqual(forecast?.city, "Ternopil")
        XCTAssertEqual(forecast?.country, "UA")
        XCTAssertEqual(forecast?.windSpeed, 3.0)
        XCTAssertEqual(forecast?.icon, "04d")
    }
    
    /**
     Case: Placeholder visibility reacts correctly to user input changes
     
     Preconditions:
     - A hot observable simulates user typing and clearing the text field
       at specific virtual times (including empty strings)
     - The sequence includes transitions:
         "" → "T" → "" → "Ternopil" → ""
     
     Expected behavior:
     - Placeholder is visible (isPlaceholderHidden == false) when input is empty
     - Placeholder is hidden (isPlaceholderHidden == true) when input is non-empty
     - Emission order strictly follows input events
     
     Verified sequence:
         ""          → false
         "T"         → true
         ""          → false
         "Ternopil"  → true
         ""          → false
     */
    func testPlaceholderVisibility() {
        let observable = scheduler.createHotObservable([
            .next(10, ""),
            .next(20, "T"),
            .next(30, ""),
            .next(40, "Ternopil"),
            .next(50, ""),
        ])
        
        let observer = scheduler.createObserver(Bool.self)
        
        scheduler.scheduleAt(0) { [weak self] in
            guard let self else { return }
            
            observable
                .bind(to: self.weatherVM.cityText)
                .disposed(by: self.bag)
            
            self.weatherVM.isPlaceholderHidden
                .subscribe(observer)
                .disposed(by: bag)
        }
        
        scheduler.start()
        
        let results = observer.events.map {
            $0.value.element!
        }
        
        XCTAssertEqual(results, [ false, true, false, true, false ])
    }
    
    
    /**
     Case: Number of events emitted by sections during incremental typing
     
     Preconditions:
     - Simulated user input through a hot observable: typing "T" → "Te" → ... → "Ternopil"
     - Each character typed emits a new cityText value
     
     Expected behavior:
     - Sections are recomputed for every input change
     - Total emitted sections = 9 (including initial empty state)
     */
    func testSectionsEventsNumberForIncrementalTyping() {
        let observable = scheduler.createHotObservable([
            .next(10, "T"),
            .next(20, "Te"),
            .next(30, "Ter"),
            .next(40, "Tern"),
            .next(50, "Terno"),
            .next(60, "Ternop"),
            .next(70, "Ternopi"),
            .next(80, "Ternopil")
        ])
        
        let sectionObserver = scheduler.createObserver([WeatherSection].self)
        
        scheduler.scheduleAt(0) { [weak self] in
            guard let self else { return }
            
            observable
                .bind(to: self.weatherVM.cityText)
                .disposed(by: self.bag)
            
            self.weatherVM.sections
                .subscribe(sectionObserver)
                .disposed(by: bag)
        }
        
        scheduler.start()
        
        let sectionResults = sectionObserver.events.map {
            $0.value.element!
        }
        
        XCTAssertEqual(sectionResults.count, 9)
    }
    
    
    /**
     Case: Number of events emitted by placeholder visibility during incremental typing
     
     Preconditions:
     - Simulated user input through a hot observable: typing "T" → "Te" → ... → "Tern"
     - Each character typed emits a new cityText value
     
     Expected behavior:
     - Placeholder visibility emits only when the state actually changes
     - Initially hidden (false) when empty → visible (true) when non-empty
     - Only two state transitions occur in this scenario
     */
    func testPlaceholderEventsNumberForIncrementalTyping() {
        let observable = scheduler.createHotObservable([
            .next(10, "T"),
            .next(20, "Te"),
            .next(30, "Ter"),
            .next(40, "Tern"),
        ])
        
        let placeholderObserver = scheduler.createObserver(Bool.self)
        
        scheduler.scheduleAt(0) { [weak self] in
            guard let self else { return }
            
            observable
                .bind(to: self.weatherVM.cityText)
                .disposed(by: self.bag)
            
            self.weatherVM.isPlaceholderHidden
                .subscribe(placeholderObserver)
                .disposed(by: bag)
        }
        
        scheduler.start()
        
        let placeholderResults = placeholderObserver.events.map {
            $0.value.element!
        }
        
        XCTAssertEqual(placeholderResults.count, 2)
    }
    
    
    /**
     Case: Weather sections behaviour when city text is pasted and cleared
     
     Expected behavior:
     - When a city name is pasted("Ternopil"), weather sections are populated
     - When the city text becomes empty, sections are cleared
     */
    func testSectionsItemsClearing() {
        let observable = scheduler.createHotObservable([
            .next(10, "Ternopil"),
            .next(20, ""),
        ])
        
        let observer = scheduler.createObserver([WeatherSection].self)
        
        scheduler.scheduleAt(0) { [weak self] in
            guard let self else { return }
            
            observable
                .bind(to: self.weatherVM.cityText)
                .disposed(by: self.bag)
            
            self.weatherVM.sections
                .subscribe(observer)
                .disposed(by: bag)
        }
        
        scheduler.start()
        
        let elements = observer.events.compactMap { $0.value.element }
        
        guard let lastElement = elements.last,
              let preLastElement = elements.dropLast().last
        else { return XCTFail() }
        
        XCTAssertTrue(lastElement.isEmpty)
        XCTAssertFalse(preLastElement.isEmpty)
    }
    
    /**
     Case: Verify that weather sections are populated correctly when a valid city is entered
     
     Preconditions:
     - Simulated user input through a hot observable. Emits "Ternopil" at virtual time 10
     
     Expected behavior:
     - Section header matches the expected string: "Прогноз погоди для Ternopil, UA"
     - The first item in the section has the following expected properties:
         - city: "Ternopil"
         - country: "UA"
         - nightTemp: 5
         - dayTemp: 10
         - icon: "04d"
         - windSpeed: 3
         - rainVolume: 3
     */
    func testSectionsContent() {
        let observable = scheduler.createHotObservable([
            .next(10, "Ternopil"),
        ])
        
        let observer = scheduler.createObserver([WeatherSection].self)
        
        scheduler.scheduleAt(0) { [weak self] in
            guard let self else { return }
            
            observable
                .bind(to: self.weatherVM.cityText)
                .disposed(by: self.bag)
            
            self.weatherVM.sections
                .subscribe(observer)
                .disposed(by: bag)
        }
        
        scheduler.start()
        
        let elements = observer.events.compactMap { $0.value.element }
        guard let lastElements = elements.last,
              let lastElement = lastElements.first,
              let lastElementFirstItem = lastElement.items.first
        else { return XCTFail() }
        
        XCTAssertEqual(lastElement.header, "Прогноз погоди для Ternopil, UA")
        XCTAssertEqual(lastElementFirstItem.city, "Ternopil")
        XCTAssertEqual(lastElementFirstItem.country, "UA")
        XCTAssertEqual(lastElementFirstItem.nightTemp, 5)
        XCTAssertEqual(lastElementFirstItem.dayTemp, 10)
        XCTAssertEqual(lastElementFirstItem.icon, "04d")
        XCTAssertEqual(lastElementFirstItem.windSpeed, 3)
        XCTAssertEqual(lastElementFirstItem.rainVolume, 3)
    }
    
    /**
     Case: Verify interaction between weather sections and placeholder visibility
     
     Preconditions:
     - Simulated user input through a hot observable
     - Emits "Ternopil" at virtual time 10
     - Emits "" (empty string) at virtual time 20
     
     Expected behavior:
     - If sections are empty, placeholder is visible
     - If sections contain data, placeholder is hidden
     */
    func testSectionsAndPlaceholderInteraction() {
        let observable = scheduler.createHotObservable([
            .next(10, "Ternopil"),
            .next(20, ""),
        ])
        
        let sectionObserver = scheduler.createObserver([WeatherSection].self)
        let placeholderObserver = scheduler.createObserver(Bool.self)
        
        scheduler.scheduleAt(0) { [weak self] in
            guard let self else { return }
            
            observable
                .bind(to: self.weatherVM.cityText)
                .disposed(by: self.bag)
            
            self.weatherVM.sections
                .subscribe(sectionObserver)
                .disposed(by: self.bag)
            
            self.weatherVM.isPlaceholderHidden
                .subscribe(placeholderObserver)
                .disposed(by: self.bag)
        }
        
        scheduler.start()
        
        for placeholderEvent in placeholderObserver.events {
            guard let isHidden = placeholderEvent.value.element else { continue }
            
            let matchingSections = sectionObserver.events
                .filter { $0.time <= placeholderEvent.time }
                .last?
                .value.element ?? []
            
            if isHidden == false { XCTAssertTrue(matchingSections.isEmpty)}
        }
    }
}
