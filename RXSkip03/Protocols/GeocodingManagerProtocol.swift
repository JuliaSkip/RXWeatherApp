//
//  GeocodingManagerProtocol.swift
//  RXSkip03
//
//  Created by Скіп Юлія Ярославівна on 16.02.2026.
//

import Foundation
import RxSwift

protocol GeocodingManagerProtocol {
    func getCoordinates(for cityName: String) -> Single<GeocodingResult>
}
