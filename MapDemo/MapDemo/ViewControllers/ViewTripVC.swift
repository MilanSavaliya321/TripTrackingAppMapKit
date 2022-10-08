//
//  ViewTripVC.swift
//  MapDemo
//
//  Created by Milan on 08/10/22.
//

import UIKit
import MapKit

class ViewTripVC: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Properties
    var startLocation: CLLocationCoordinate2D?
    var endLocation: CLLocationCoordinate2D?
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestLocationServiceAccess()
    }
    
    // MARK: - Functions
    private func setupUI() {
        title = "Trip Details"
        mapView.showsUserLocation = false
        mapView.delegate = self
    }
    
    private func requestLocationServiceAccess() {
        LocationManager.shared.requestLocationServiceIfNeed(force: false) { (haspermission) in
            if !haspermission {
                DispatchQueue.main.async {
                    Utils.showAlertForAppSettings(title: "Need to access Location service", message: "Turn on Location services on your device.", allowCancel: true) { (completed) in
                    }
                    return
                }
            } else {
                print("granted")
                self.showMarker(position: self.startLocation)
                self.showMarker(position: self.endLocation)
                self.getDirections(startLocation: self.startLocation, endLocation: self.endLocation)
            }
        }
    }
    
    private func showMarker(position: CLLocationCoordinate2D?) {
        guard let position = position else { return }
        let point = MKPointAnnotation()
        point.coordinate =  .init(latitude: position.latitude, longitude: position.longitude)
        self.mapView.addAnnotation(point)
        
        let viewRegion = MKCoordinateRegion(center: .init(latitude: position.latitude, longitude: position.longitude), latitudinalMeters: 700, longitudinalMeters: 700)
        self.mapView.setRegion(viewRegion, animated: true)
    }
    
    private func getDirections(startLocation: CLLocationCoordinate2D? , endLocation: CLLocationCoordinate2D?) {
        
        guard let startLocation = startLocation else { return }
        guard let endLocation = endLocation else { return }
        
        let request = MKDirections.Request()
        let sourcePlaceMark = MKPlacemark(coordinate: startLocation)
        request.source = MKMapItem(placemark: sourcePlaceMark)
        let destPlaceMark = MKPlacemark(coordinate: endLocation)
        request.destination = MKMapItem(placemark: destPlaceMark)
        request.transportType = [.automobile, .walking]
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            guard let response = response else {
                print("Error: \(error?.localizedDescription ?? "No error specified").")
                return
            }
            let route = response.routes[0]
            //            self.currentRoute = route
            self.mapView.addOverlay(route.polyline)
        }
    }
    
}

// MARK: - MKMapViewDelegate
extension ViewTripVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 5.0
        return renderer
    }
}
