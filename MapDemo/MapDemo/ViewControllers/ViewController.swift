//
//  ViewController.swift
//  MapDemo
//
//  Created by Milan on 07/10/22.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var btnCurrentLocation: UIButton!
    @IBOutlet weak var btnStartTrip: UIButton!
    
    // MARK: - Properties
    var startLocation: CLLocationCoordinate2D?
    var endLocation: CLLocationCoordinate2D?
    var startTime: Date?
    var endTime: Date?
    var currentRoute: MKRoute?
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.resetMapAnnotations()
        requestLocationServiceAccess()
    }
    
    // MARK: - Functions
    private func setupUI() {
        title = "Trip Tracking"
        btnStartTrip.layer.cornerRadius = btnStartTrip.frame.height / 2
        btnCurrentLocation.layer.cornerRadius = btnCurrentLocation.frame.height / 2
        createRightMenu()
        mapView.showsUserLocation = true
        mapView.delegate = self
    }
    
    private func createRightMenu() {
        let button = UIButton(type: .custom)
        if #available(iOS 13.0, *) {
            button.setImage(UIImage(named: "ic_menu")?.withRenderingMode(.alwaysTemplate).withTintColor(UIColor.label), for: .normal)
        } else {
            button.setImage(UIImage(named: "ic_menu"), for: .normal)
        }
        button.addTarget(self, action: #selector(menuClick), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 20).isActive = true
        button.heightAnchor.constraint(equalToConstant: 20).isActive = true
        let barButton = UIBarButtonItem(customView: button)
        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.tintColor = .label
        }
        navigationItem.rightBarButtonItem = barButton
    }
    
    @objc func menuClick() {
        guard let viewTripVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TripListVC") as? TripListVC else { return }
        self.navigationController?.pushViewController(viewTripVC, animated: true)
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
                self.getCurrentLocation()
            }
        }
    }
    
    private func getCurrentLocation() {
        LocationManager.shared.getPromiseCurrentLocation { letlong in
            guard let position = letlong else { return }
            let viewRegion = MKCoordinateRegion(center: .init(latitude: position.latitude, longitude: position.longitude), latitudinalMeters: 100, longitudinalMeters: 100)
            self.mapView.setRegion(viewRegion, animated: true)
        }
    }
    
    private func showMarker(position: CLLocationCoordinate2D?) {
        guard let position = position else { return }
        let point = MKPointAnnotation()
        point.coordinate =  .init(latitude: position.latitude, longitude: position.longitude)
        self.mapView.addAnnotation(point)
        let viewRegion = MKCoordinateRegion(center: .init(latitude: position.latitude, longitude: position.longitude), latitudinalMeters: 100, longitudinalMeters: 100)
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
            self.currentRoute = route
            self.mapView.addOverlay(route.polyline)
        }
    }
    
    private func distanceConverter(distance: CLLocationDistance) -> String {
        let lengthFormatter = LengthFormatter()
        lengthFormatter.numberFormatter.maximumFractionDigits = 2
        return lengthFormatter.string(fromValue: distance / 1000, unit: .kilometer)
        //        if NSLocale.current.usesMetricSystem {
        //            return lengthFormatter.string(fromValue: distance / 1000, unit: .kilometer)
        //        } else {
        //            return lengthFormatter.string(fromValue: distance / 1609.34, unit: .mile)
        //        }
    }
    
    private func resetMapAnnotations() {
        currentRoute = nil
        for poll in self.mapView.overlays {
            self.mapView.removeOverlay(poll)
        }
        self.mapView.annotations.forEach {
            if !($0 is MKUserLocation) {
                self.mapView.removeAnnotation($0)
            }
        }
    }
    
    private func showEndTripPopup() {
        let str = "Started: \(startTime?.formateDate() ?? "")\nEnded: \(endTime?.formateDate() ?? "")"
        let alert = UIAlertController(title: "Trip Completed Successfully", message: str, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
            print("Cancel")
            self.resetMapAnnotations()
            alert.dismiss(animated: true, completion: nil)
        })
        alert.addAction(UIAlertAction(title: "View Trip", style: .default) { (action:UIAlertAction!) in
            guard let viewTripVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewTripVC") as? ViewTripVC else { return }
            viewTripVC.startLocation = self.startLocation
            viewTripVC.endLocation = self.endLocation
            self.navigationController?.pushViewController(viewTripVC, animated: true)
            print("View Trip")
        })
        
        self.present(alert, animated: true)
    }
    
    private func saveTrip() {
        guard let startLocation = startLocation else { return }
        guard let endLocation = endLocation else { return }
        
        let data = Trip(context: PersistentStorage.shared.context)
        data.id = UUID()
        data.startTime = startTime?.formateDate() ?? ""
        data.endTime = endTime?.formateDate() ?? ""
        
        data.kms = self.distanceConverter(distance: currentRoute?.distance ?? .init())
        data.startLet = startLocation.latitude
        data.startLong = startLocation.longitude
        data.endLet = endLocation.latitude
        data.endLong = endLocation.longitude
        PersistentStorage.shared.saveContext()
    }
    
    // MARK: - IBAction
    @IBAction func onBtnShowCurrentLocation(_ sender: UIButton) {
        getCurrentLocation()
    }
    
    @IBAction func onBtnStartTrip(_ sender: UIButton) {
        sender.isSelected.toggle()
        LocationManager.shared.getPromiseCurrentLocation { [self] letlong in
            if sender.isSelected {
                self.resetMapAnnotations()
                self.startLocation = letlong
                self.startTime = Date()
                self.showMarker(position: letlong)
            } else {
                self.endLocation = letlong
                self.endTime = Date()
                self.showMarker(position: letlong)
                self.getDirections(startLocation: self.startLocation, endLocation: self.endLocation)
                self.saveTrip()
                self.showEndTripPopup()
            }
        }
    }
}

// MARK: - MKMapViewDelegate
extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 5.0
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        getCurrentLocation()
        getDirections(startLocation: self.startLocation, endLocation: userLocation.location?.coordinate)
    }
    
    //    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    //        guard !(annotation is MKUserLocation) else {
    //            return nil
    //        }
    //        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "custom")
    //
    //        if annotationView == nil {
    //            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "custom")
    //            annotationView?.canShowCallout = true
    //        } else {
    //            annotationView?.annotation = annotation
    //        }
    //
    //        annotationView?.image = UIImage(named: "location")
    //
    //        return annotationView
    //    }
}
