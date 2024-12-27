import SwiftUI
import MapKit

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

struct LocationPickerView: View {
    @State private var searchQuery: String = ""
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // Default location (San Francisco)
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var selectedLocation: LocationAnnotation?
    @State private var isSaved: Bool = false

    var body: some View {
        VStack {
            // Search Bar
            TextField("Search for a location", text: $searchQuery, onCommit: performSearch)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            // Map View
            Map(
                coordinateRegion: $region,
                interactionModes: [.all],
                showsUserLocation: true,
                annotationItems: selectedLocation.map { [$0] } ?? []
            ) { location in
                MapPin(coordinate: location.coordinate, tint: .blue)
            }
            .onChange(of: region.center) { newCenter in
                // Update selected location to map center
                selectedLocation = LocationAnnotation(id: UUID(), coordinate: newCenter)
            }
            .cornerRadius(10)
            .padding()

            // Save Button
            Button(action: saveLocation) {
                Text("Save Location")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedLocation == nil ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(selectedLocation == nil)
            .padding()

            if isSaved {
                Text("Location saved!").foregroundColor(.green).padding()
            }
        }
        .padding()
    }

    // Perform search using MapKit
    func performSearch() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchQuery
        let search = MKLocalSearch(request: request)

        search.start { response, error in
            if let result = response?.mapItems.first {
                region.center = result.placemark.coordinate
            }
        }
    }

    // Save selected location to UserDefaults
    func saveLocation() {
        if let location = selectedLocation {
            let locationData = ["latitude": location.coordinate.latitude, "longitude": location.coordinate.longitude]
            UserDefaults.standard.set(locationData, forKey: "userLocation")
            isSaved = true
        }
    }
}

// Custom struct to make CLLocationCoordinate2D identifiable
struct LocationAnnotation: Identifiable {
    let id: UUID
    let coordinate: CLLocationCoordinate2D
}

struct LocationPickerView_Previews: PreviewProvider {
    static var previews: some View {
        LocationPickerView()
    }
}
