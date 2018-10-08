//
//  ViewController.swift
//  testMap
//
//  Created by Sergio Veliz on 10/4/18.
//  Copyright © 2018 Sergio Veliz. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation
import Alamofire
import ObjectMapper

class MapsVC: UIViewController {
    
    var containerView = UIView()
    var tableViewContainer = UIView()
    
    var cell : UITableViewCell!
    let cellReuseIdentifier = "cell"
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 16.0
    
    let defaultLocation = CLLocation(latitude: 59.939009, longitude: 29.530315)
    var sendLocation = [CLLocation]()
    
    var placeResult = PlaceResult()
    let radius = 2000
    
    var isTapped = false
    
    let currentPlaceBtn: UIButton = {
        let currentPlaceBtn = UIButton()
        currentPlaceBtn.frame = CGRect(x: 45, y: 45, width: 45, height: 45)
        currentPlaceBtn.backgroundColor = .red
        currentPlaceBtn.layer.cornerRadius = currentPlaceBtn.frame.height / 2
        currentPlaceBtn.clipsToBounds = true
        currentPlaceBtn.tag = 1
        currentPlaceBtn.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return currentPlaceBtn
    }()
    
    let listOfRestaraunt: UIButton = {
        let listOfRestaraunt = UIButton()
        listOfRestaraunt.frame = CGRect(x: 45, y: 45, width: 45, height: 45)
        listOfRestaraunt.backgroundColor = .green
        listOfRestaraunt.layer.cornerRadius = listOfRestaraunt.frame.height / 2
        listOfRestaraunt.clipsToBounds = true
        listOfRestaraunt.tag = 2
        listOfRestaraunt.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return listOfRestaraunt
    }()
    
    lazy var horizontalStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.listOfRestaraunt, self.currentPlaceBtn])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 20.0
        return stackView
    }()
    
    var tableView : UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        let camera = GMSCameraPosition.camera(withLatitude: defaultLocation.coordinate.latitude,
                                              longitude: defaultLocation.coordinate.longitude,
                                              zoom: zoomLevel)
        //        mapView = GMSMapView.map(withFrame: containerView.bounds, camera: camera)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        
        if isLocationPermissionGranted() {
            
            self.containerView = mapView
            mapView.isMyLocationEnabled = true
        } else {
            print("error permmision")
            locationManager.requestAlwaysAuthorization()
        }
        
        mapView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        fullSizeMapScreen()
        handleConstraints()
        
        if !isTapped {
            print("fullsize")
            fullSizeMapScreen()
            handleConstraints()
            isTapped = true
        } else {
            print("halfsize")
            halfSizeMapScreen()
            visibleTableView()
            handleConstraints()
            isTapped = false
        }
        
    }
    
    func handleConstraints() {
        
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(horizontalStackView)
        
        //        let stackView = ["stackView": view, "verticalStackView": horizontalStackView]
        //        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:[stackView]-(<=50)-[verticalStackView(110)]", options: .alignAllBottom, metrics: nil, views: stackView as [String : Any])
        //        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[stackView]-(<=50)-[verticalStackView(45)]", options: .alignAllRight, metrics: nil, views: stackView as [String : Any])
        //        view.addConstraints(horizontalConstraints)
        //        view.addConstraints(verticalConstraints)
        
        NSLayoutConstraint(item: horizontalStackView,
                           attribute: .rightMargin,
                           relatedBy: .equal,
                           toItem:  containerView,
                           attribute: .rightMargin,
                           multiplier: 1.0,
                           constant: 0).isActive = true
        
        NSLayoutConstraint(item: horizontalStackView,
                           attribute: .bottomMargin,
                           relatedBy: .equal,
                           toItem: containerView,
                           attribute: .bottomMargin,
                           multiplier: 1.0,
                           constant: -20.0).isActive = true
        
        NSLayoutConstraint(item: horizontalStackView,
                           attribute: .width,
                           relatedBy: .equal,
                           toItem: nil,
                           attribute: .notAnAttribute,
                           multiplier: 1.0,
                           constant: 110.0).isActive = true
        
        NSLayoutConstraint(item: horizontalStackView,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: nil,
                           attribute: .notAnAttribute,
                           multiplier: 1.0,
                           constant: 45.0).isActive = true
    }
    
    
    func halfSizeMapScreen() {
        let camera = GMSCameraPosition.camera(withLatitude: defaultLocation.coordinate.latitude,
                                              longitude: defaultLocation.coordinate.longitude,
                                              zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        self.containerView = mapView
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .gray
        view.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            containerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            containerView.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: 0),
            ])
    }
    
    func fullSizeMapScreen() {
        
        let camera = GMSCameraPosition.camera(withLatitude: defaultLocation.coordinate.latitude,
                                              longitude: defaultLocation.coordinate.longitude,
                                              zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        self.containerView = mapView
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .gray
        view.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            containerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            ])
    }
    
    func visibleTableView() {
        tableViewContainer.addSubview(tableView)
        
        tableView.leftAnchor.constraint(equalTo: tableViewContainer.leftAnchor, constant: 0).isActive = true
        tableView.topAnchor.constraint(equalTo: tableViewContainer.topAnchor, constant: 0).isActive = true
        tableView.rightAnchor.constraint(equalTo: tableViewContainer.rightAnchor, constant: 0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: tableViewContainer.bottomAnchor, constant: 0).isActive = true
        
        tableView.dataSource = self
        tableView.delegate = self
        
        
        tableViewContainer.translatesAutoresizingMaskIntoConstraints = false
        //                containerView.backgroundColor = .green
        view.addSubview(tableViewContainer)
        NSLayoutConstraint.activate([
            tableViewContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            tableViewContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            tableViewContainer.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 0),
            tableViewContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            ])
        view.addSubview(tableViewContainer)
    }
    
    @objc func buttonTapped(sender: UIButton) {
        let btnSendTag: UIButton = sender
        if btnSendTag.tag == 1 {
            print("current place")
            
            mapView.isMyLocationEnabled = true
            let position = CLLocationCoordinate2D(latitude: currentLocation?.coordinate.latitude ?? defaultLocation.coordinate.latitude, longitude: currentLocation?.coordinate.longitude ?? defaultLocation.coordinate.longitude)
            mapView.animate(toLocation: position)
            
        }
        if btnSendTag.tag == 2 {
            print("list of restaraunt")
            if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                mapView?.isMyLocationEnabled = true
            }
            self.viewWillAppear(true)
            getListOfRestaurant()
        }
    }
    
    func isLocationPermissionGranted() -> Bool {
        guard CLLocationManager.locationServicesEnabled() else { return false }
        return [.authorizedAlways, .authorizedWhenInUse].contains(CLLocationManager.authorizationStatus())
    }
    
    //MARK: - Request
    
    func getListOfRestaurant() {
        
        let url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(currentLocation!.coordinate.latitude),\(currentLocation!.coordinate.longitude)&radius=\(radius)&type=restaurant&keyword=cruise&key=\(Constants.Keys.mapsForMyIP)"
        
        Alamofire.request(url, method: .get).validate().responseJSON { [weak self]
            response in
            guard let selfNotNil = self else { return }
            switch response.result {
            case .success:
                if let responseValue = response.result.value {
                    if let response = Mapper<PlaceResult>().map(JSONObject: responseValue) {
                        selfNotNil.placeResult = response
                        selfNotNil.tableView.reloadData()
                    }
                }
                break
            case .failure(let error):
                print(error)
                break
            }
            
        }
    }
    
}

// MARK: - Delegate for UITableView


extension MapsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeResult.results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) else {
                return UITableViewCell(style: .subtitle, reuseIdentifier: cellReuseIdentifier)
            }
            return cell
        }()
        
        let resultItem = placeResult.results[indexPath.row]
        print(indexPath.row)
        print(resultItem.name)
        cell.textLabel?.text = resultItem.name
        cell.detailTextLabel?.text = resultItem.address
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let resultItem = placeResult.results[indexPath.row]
        let coordinate = resultItem.geometry.location
        
        let lat = coordinate.lat
        let lng = coordinate.lng
        let position = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        let marker = GMSMarker(position: position)
        marker.title = resultItem.name
        marker.map = mapView
        mapView.animate(toLocation: position)
    }
    
    
}

//MARK:- Delegate for LocationManager

extension MapsVC: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        currentLocation = location
        //        print("Location: \(location)")
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
        }
        
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}

