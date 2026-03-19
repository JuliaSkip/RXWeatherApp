//
//  GeocodingModel.swift
//  RXSkip03
//
//  Created by Скіп Юлія Ярославівна on 09.02.2026.
//
nonisolated
struct GeocodingResult: Codable {
    let name: String
    let lat: Double
    let lon: Double
    let country: String    
}
