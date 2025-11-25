//
//  MockLocationService.swift
//  MaxNotes
//
//  Created by Max zam on 25/11/2025.
//
import CoreLocation

final class MockLocationService: LocationServiceProtocol {
    var lastLocation: CLLocation?
    var authorizationStatus: CLAuthorizationStatus = .authorizedWhenInUse
    var errorMessage: String?
    var nextLocation: CLLocation?

    init(nextLocation: CLLocation? = CLLocation(latitude: 51.5, longitude: -0.12)) {
        self.nextLocation = nextLocation
    }

    func requestLocation() async throws -> CLLocation {
        if let loc = nextLocation { lastLocation = loc; return loc }
        throw LocationServiceError.timeout
    }
}
