//
//  ViewController.swift
//  Testing3dModelInGoogleMaps
//
//  Created by Hilal Al Hakkani on 1/8/20.
//  Copyright © 2020 Hilal. All rights reserved.
//
import UIKit
import GoogleMaps
import CoreLocation
import SceneKit

let CAR_COUNT_LIMIT = 60



 class ViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate, SCNSceneRendererDelegate {
    @IBOutlet weak var mapView: GMSMapView!
    var locationManager = CLLocationManager()
    var markers: [HHCarMarker] = []

    @IBOutlet weak var counter: UILabel!
 
    @IBAction func removeCar(_ sender: Any) {
        removeMarker()
    }

    @IBAction func addCar(_ sender: Any) {
        createMarker()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
        setupLocationManager()
    }

    func setupLocationManager() {
        self.locationManager = CLLocationManager()
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .automotiveNavigation;
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }

    func createMarker(location: CLLocationCoordinate2D? = nil) {
        guard markers.count < CAR_COUNT_LIMIT else {
            print("The limit has been exceeded.")
            return
        }
        let marker = HHCarMarker.init(car: .teslaModelX)
        marker.map = mapView
        if let location = location {
            marker.position = location
        }
        markers.append(marker)
        counter.text = "\(markers.count)"
    }

    func removeMarker() {
        guard !markers.isEmpty else {
            return
        }
        let marker = markers.removeLast()
        marker.map = nil
        counter.text = "\(markers.count)"
    }

    func setupMap() {
        mapView.delegate = self
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = false
        mapView.settings.rotateGestures = false
        mapView.settings.tiltGestures = false
        mapView.animate(toZoom:  16)
        createMarker()
        self.mapView.animate(toViewingAngle: 20)
        if let styleURL = Bundle.main.url(forResource: "mapStyle", withExtension: "json") {
            mapView.mapStyle = try! GMSMapStyle(contentsOfFileURL: styleURL)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last?.coordinate

        for (i, marker) in markers.enumerated() {
            let offset = 0.001 * Double(i)
            marker.position = .init(latitude: location!.latitude + offset, longitude: location!.longitude)
        }
        self.mapView.animate(toLocation: location!)
    }

    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        let scale = (position.zoom/20)
        for marker in markers {
            marker.scale = scale > 1 ? 1: scale
            print(marker.scale)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        for marker in markers {
            marker.heading = newHeading.trueHeading
        }
    }
}
