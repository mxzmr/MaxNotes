//
//  NoteLocation.swift
//  MaxNotes
//
//  Created by Max zam on 25/11/2025.
//

import CoreLocation

struct NoteLocation: Codable, Equatable {
    let latitude: Double
    let longitude: Double
    
    init(coordinate: CLLocationCoordinate2D) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
