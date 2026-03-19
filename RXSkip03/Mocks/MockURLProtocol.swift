//
//  MockURLProtocol.swift
//  RXSkip03
//
//  Created by Скіп Юлія Ярославівна on 16.02.2026.
//

import Foundation

final class MockURLProtocol: URLProtocol {
    
    static var stubData: Data?
    static var stubError: Error?
    
    override class func canInit(with request: URLRequest) -> Bool {
        true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }
    
    override func startLoading() {
        if let error = MockURLProtocol.stubError {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }
        
        if let data = MockURLProtocol.stubData {
            client?.urlProtocol(self, didLoad: data)
        }
        
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
}
