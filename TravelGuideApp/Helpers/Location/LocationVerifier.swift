import Foundation
import CoreLocation
import Combine

public enum AppEnvironment {
    public static var isTest: Bool = false
    public static var manualLocation: CLLocationCoordinate2D? = nil
}

public final class LocationVerifier: NSObject, ObservableObject {
    @Published private(set) public var currentLocation: CLLocation? = nil
    
    private let manager: CLLocationManager = .init()
    private var cancellables = Set<AnyCancellable>()
    
    public override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    

    public func start() {
        guard !AppEnvironment.isTest else { return }
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        default:
            break
        }
    }
    
    public func stop() {
        guard !AppEnvironment.isTest else { return }
        manager.stopUpdatingLocation()
    }
    
    func isWithin(_ meters: Double = 1000, of place: HistoricPlace) -> Bool {
        let coordinate: CLLocationCoordinate2D?
        if AppEnvironment.isTest {
            coordinate = AppEnvironment.manualLocation
        } else {
            coordinate = currentLocation?.coordinate
        }
        guard let userCoord = coordinate else { return false }
        
        let userLoc  = CLLocation(latitude: userCoord.latitude, longitude: userCoord.longitude)
        let placeLoc = CLLocation(latitude: place.latitude, longitude: place.longitude)
        return userLoc.distance(from: placeLoc) <= meters
    }
}

extension LocationVerifier: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
    }
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        default:
            break
        }
    }
}
