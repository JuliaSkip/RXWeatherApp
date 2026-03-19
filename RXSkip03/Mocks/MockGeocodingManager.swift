//
//  MockGeocodingProtocol.swift
//  RXSkip03
//
//  Created by Скіп Юлія Ярославівна on 17.02.2026.
//

import RxSwift

nonisolated
final class MockGeocodingManager: GeocodingManagerProtocol {
    
    func getCoordinates(for cityName: String) -> Single<GeocodingResult> {
        return .just(GeocodingResult(name: "Ternopil", lat: 49.5535, lon: 25.5948, country: "UA"))
    }
}
