//
//  AttendanceViewController.swift
//  MSIT - Notifier
//
//  Created by Abhishek Sansanwal on 11/06/21.
//  Copyright © 2021 Verved. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class AttendanceViewController : UIViewController, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager?
    var c = 0
    
    @IBOutlet weak var attendanceLabel: UILabel!
    @IBAction func markAttendance(_ sender: Any) {
        locationManager?.startUpdatingLocation()
        locationManager?.requestLocation()
        
        print(locationManager?.location?.coordinate)
        
        print("FINDING ERROR BROOOOO")
        print("%")
        print("%")
        print(cp1.longitude)
        print("%")
        print("%")
        print("FINDING ERROR BROOOOO")
        
        checkPresence(vertices: 4, vertx: [cp1.latitude,cp2.latitude,cp3
                                            .latitude,cp4.latitude], verty: [cp1.longitude,cp2.longitude,cp3.longitude,cp4.longitude], testx: (locationManager?.location?.coordinate.latitude)!, testy: (locationManager?.location?.coordinate.longitude)!)
        if c == 0 {
            print("Absent")
            attendanceLabel.textColor = .red
            attendanceLabel.text = "Absent!"
        }
        else {
            print("Present")
            attendanceLabel.textColor = .green
            attendanceLabel.text = "Present!"
        }
        
        locationManager?.stopUpdatingLocation()
        print("Attendance Marked")
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func checkPresence(vertices: Int, vertx: [Double], verty: [Double], testx: Double, testy: Double) {
        
        var i = 0
        var j = vertices - 1
        
        for _ in 0...vertices - 1 {
                    if  (verty[i] > testy) != (verty[j]>testy) {
                        if (testx < (vertx[j]-vertx[i]) * (testy-verty[i]) / (verty[j]-verty[i]) + vertx[i]) {
                            if c == 0 {
                                c = 1
                            }
                            else {
                                c = 0
                            }
                        }
                    }
                    j = i
                    i = i + 1
            
        }
        
        // This proves the presense of a point within the specified polygon. If the value of C is 1 that means the student in present in the classroom or else absent.
        print("FINAL VALUE OF C:")
        
    }
    
    var cp1 : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    var cp2 : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    var cp3 : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    var cp4 : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    
  /*  locationManager?.startUpdatingLocation()
    locationManager?.requestLocation()
    print(locationManager?.location?.coordinate)
    locationManager?.stopUdatingLocation()*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("WE OUT HERE DAWG")
        print("WE OUT HERE DAWG")
        print(cp1)
        print(cp2)
        print(cp3)
        print(cp4)
        print("WE OUT HERE DAWG")
        print("WE OUT HERE DAWG")
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager?.startUpdatingHeading()
        attendanceLabel.text = ""
    }
    
    
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    switch status {
    case .denied: // Setting option: Never
      print("LocationManager didChangeAuthorization denied")
    case .notDetermined: // Setting option: Ask Next Time
      print("LocationManager didChangeAuthorization notDetermined")
    case .authorizedWhenInUse: // Setting option: While Using the App
      print("LocationManager didChangeAuthorization authorizedWhenInUse")
      
      // Stpe 6: Request a one-time location information
      locationManager?.requestLocation()
    case .authorizedAlways: // Setting option: Always
      print("LocationManager didChangeAuthorization authorizedAlways")
      
      // Stpe 6: Request a one-time location information
      locationManager?.requestLocation()
    case .restricted: // Restricted by parental control
      print("LocationManager didChangeAuthorization restricted")
    default:
      print("LocationManager didChangeAuthorization")
    }
  }

  // Step 7: Handle the location information
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    print("LocationManager didUpdateLocations: numberOfLocation: \(locations.count)")
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    /*
    locations.forEach { (location) in
      print("LocationManager didUpdateLocations: \(dateFormatter.string(from: location.timestamp)); \(location.coordinate.latitude), \(location.coordinate.longitude)")
      print("LocationManager altitude: \(location.altitude)")
      print("LocationManager floor?.level: \(location.floor?.level)")
      print("LocationManager horizontalAccuracy: \(location.horizontalAccuracy)")
      print("LocationManager verticalAccuracy: \(location.verticalAccuracy)")
      print("LocationManager speedAccuracy: \(location.speedAccuracy)")
      print("LocationManager speed: \(location.speed)")
      print("LocationManager timestamp: \(location.timestamp)")
        if #available(iOS 13.4, *) {
            print("LocationManager courseAccuracy: \(location.courseAccuracy)")
        } else {
            // Fallback on earlier versions
        } // 13.4
      print("LocationManager course: \(location.course)")
    } */
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("LocationManager didFailWithError \(error.localizedDescription)")
    if let error = error as? CLError, error.code == .denied {
       // Location updates are not authorized.
      // To prevent forever looping of `didFailWithError` callback
       locationManager?.stopMonitoringSignificantLocationChanges()
       return
    }
  }
    
}
