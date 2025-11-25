//
//  LocationService.swift
//  MaxNotes
//
//  Created by Max zam on 25/11/2025.
//

import CoreLocation
import Observation

protocol LocationServiceProtocol {
    func requestLocation() async throws -> CLLocation
}

@Observable
final class LocationService: LocationServiceProtocol {
    private let manager: CLLocationManager
    
    init(manager: CLLocationManager = CLLocationManager()) {
        self.manager = manager
    }
    
    func requestLocation() async throws -> CLLocation {
        
        if manager.authorizationStatus == .denied || manager.authorizationStatus == .restricted {
            throw LocationServiceError.denied
        }
        
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
        
        do {
            for try await update in CLLocationUpdate.liveUpdates() {
                
                if manager.authorizationStatus == .denied {
                    throw LocationServiceError.denied
                }
                if let location = update.location {
                    return location
                }
            }
        } catch is CancellationError {
            throw LocationServiceError.cancelled
        } catch {
            throw error
        }
        
        throw LocationServiceError.timeout
    }
}

enum LocationServiceError: LocalizedError {
    case denied
    case timeout
    case cancelled
    
    var errorDescription: String? {
        switch self {
        case .denied:
            return "Location permission is denied. Enable it in Settings."
        case .timeout:
            return "Location request timed out."
        case .cancelled:
            return "Location request was cancelled."
        }
    }
}

extension CLLocation {
    var asNoteLocation: NoteLocation {
        NoteLocation(coordinate: coordinate)
    }
}
