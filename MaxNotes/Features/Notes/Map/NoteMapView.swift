//
//  NoteMapView.swift
//  MaxNotes
//
//  Created by Max zam on 25/11/2025.
//

import CoreLocation
import MapKit
import Observation
import SwiftUI

struct NoteMapView: View {
    @State private var viewModel: MapViewModel
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var hasCenteredOnUser = false
    
    private let onSelect: (Note) -> Void
    
    init(
        viewModel: MapViewModel,
        onSelect: @escaping (Note) -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onSelect = onSelect
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                Map(position: $cameraPosition) {
                    if viewModel.userLocation != nil {
                        UserAnnotation()
                    }
                    
                    ForEach(viewModel.notes) { note in
                        if let location = note.location {
                            Annotation(note.title, coordinate: location.coordinate) {
                                Button {
                                    onSelect(note)
                                } label: {
                                    VStack(spacing: 4) {
                                        Image(systemName: "note.text")
                                            .foregroundStyle(.white)
                                            .padding(8)
                                            .background(Color.blue, in: Circle())
                                        Text(note.title)
                                            .font(.footnote.weight(.semibold))
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 4)
                                            .background(.thinMaterial, in: Capsule())
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .ignoresSafeArea(edges: .bottom)
                .mapControls {
                    MapUserLocationButton()
                }
                .onChange(of: viewModel.userLocation) { _, newLocation in
                    guard let newLocation, hasCenteredOnUser == false else { return }
                    hasCenteredOnUser = true
                    cameraPosition = .region(.init(center: newLocation.coordinate, span: .init(latitudeDelta: 0.02, longitudeDelta: 0.02)))
                }
                
                statusOverlay
            }
            .navigationTitle("Map")
        }
        .task {
            async let _ = viewModel.loadUserLocation()
            await viewModel.observeNotes()
        }
    }
}

private extension NoteMapView {
    
    @ViewBuilder
    var statusOverlay: some View {
        if let error = viewModel.errorMessage {
            statusBadge(text: error, icon: "exclamationmark.triangle.fill", tint: .red)
        } else if let locationError = viewModel.locationError {
            statusBadge(text: locationError, icon: "location.slash", tint: .orange)
        } else if viewModel.isLoading && viewModel.notes.isEmpty {
            statusBadge(text: "Loading your notes…", icon: "hourglass")
        } else if viewModel.notes.isEmpty {
            statusBadge(text: "No notes to display on the map yet.", icon: "map")
        }
    }
    
    func statusBadge(text: String, icon: String, tint: Color = .secondary) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(tint)
            Text(text)
                .foregroundStyle(.primary)
        }
        .font(.footnote.weight(.medium))
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .padding(.top, 12)
        .padding(.leading, 16)
        .shadow(color: .black.opacity(0.15), radius: 8, y: 6)
        .animation(.spring(), value: text)
    }
}

#Preview {
    NoteMapView(
        viewModel: MapViewModel(noteRepo: MockNoteRepository(), locationService: MockLocationService()),
        onSelect: { _ in }
    )
}
