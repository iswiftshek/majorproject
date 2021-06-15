//
//  LocationViewController.swift
//  MSIT - Notifier
//
//  Created by Abhishek Sansanwal on 11/06/21.
//  Copyright © 2021 Verved. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import ARKit

class LocationViewController : UIViewController, ARSCNViewDelegate {
    
    // Step 2: Declare a CLLocationManager object at the ViewController level to prevent the instance from being released by system.
      var locationManager: CLLocationManager?
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var trackingStateLabel: UILabel!

    private var startNode: SCNNode?
    private var endNode: SCNNode?
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    var counter = 0
    var c1 : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    var c2 : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    var c3 : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    var c4 : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    
    
    
    override func viewDidLoad() {
        counter = 0
        super.viewDidLoad()
        // Step 3: initalise and configure CLLocationManager
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager?.startUpdatingHeading()
        // Step 4: request authorization
        locationManager?.requestWhenInUseAuthorization()
        // or
        locationManager?.requestAlwaysAuthorization()
        
        // Set the view's delegate
        sceneView.delegate = self
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        // Add feature points debug options
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LocationViewController.handleTapGesture))
        view.addGestureRecognizer(tapGestureRecognizer)

        distanceLabel.text = "Distance: ?"
        distanceLabel.textColor = .red
        distanceLabel.frame = CGRect(x: 5, y: 20, width: 150, height: 25)
        

        trackingStateLabel.frame = CGRect(x: 5, y: 35, width: 300, height: 25)
        

        setupFocusSquare()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause the view's session
        sceneView.session.pause()
    }

    @objc func handleTapGesture(sender: UITapGestureRecognizer) {
        
        
        if sender.state != .ended {
            return
        }
        guard let currentFrame = sceneView.session.currentFrame else {
            return
        }

        if let endNode = endNode {
            // Reset
            startNode?.removeFromParentNode()
            self.startNode = nil
            endNode.removeFromParentNode()
            self.endNode = nil
            distanceLabel.text = "Distance: ?"
            return
        }

        let planeHitTestResults = sceneView.hitTest(view.center, types: .existingPlaneUsingExtent)
        if let result = planeHitTestResults.first {
            let hitPosition = SCNVector3.positionFromTransform(result.worldTransform)
            let sphere = SCNSphere(radius: 0.005)
            sphere.firstMaterial?.diffuse.contents = UIColor.red
            sphere.firstMaterial?.lightingModel = .constant
            sphere.firstMaterial?.isDoubleSided = true
            let node = SCNNode(geometry: sphere)
            node.position = hitPosition
            sceneView.scene.rootNode.addChildNode(node)
            
            print(counter)

            if let startNode = startNode {
                endNode = node
                let vector = startNode.position - node.position
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                formatter.roundingMode = .ceiling
                formatter.maximumFractionDigits = 2
                // Scene units map to meters in ARKit.
                distanceLabel.text = "Distance: " + formatter.string(from: NSNumber(value: vector.length()))! + " m"
                if counter == 0 {
                    print("#@#@#@#@#@#@#@#@#@#")
                    print("#@#@#@#@#@#@#@#@#@#")
                    print("#@#@#@#@#@#@#@#@#@#")
                    c1 = locationWithBearing(bearingRadians: (locationManager?.heading!.trueHeading)!, distanceMeters: Double(vector.length()), origin: (locationManager?.location!.coordinate)!)
                    
                    counter = counter + 1
                }
                else if counter == 1 {
                    c2 = locationWithBearing(bearingRadians: (locationManager?.heading!.trueHeading)!, distanceMeters: Double(vector.length()), origin: (locationManager?.location!.coordinate)!)

                    counter = counter + 1
                }
                else if counter == 2 {
                    c3 = locationWithBearing(bearingRadians: (locationManager?.heading!.trueHeading)!, distanceMeters: Double(vector.length()), origin: (locationManager?.location!.coordinate)!)
                    
                    counter = counter + 1
                }
                else if counter == 3 {
                    c4 = locationWithBearing(bearingRadians: (locationManager?.heading!.trueHeading)!, distanceMeters: Double(vector.length()), origin: (locationManager?.location!.coordinate)!)
                    
                    counter = counter + 1
                    
                    if #available(iOS 13.0, *) {
                        let MainVC: AttendanceViewController = self.storyboard?.instantiateViewController(identifier: "MainVC") as! AttendanceViewController
                        MainVC.cp1 = c1
                        MainVC.cp2 = c2
                        MainVC.cp3 = c3
                        MainVC.cp4 = c4
                        self.navigationController?.pushViewController(MainVC, animated: true)
                    } else {
                        // Fallback on earlier versions
                    }
                    
                }
                else {
                    //default statement
                    print("end of if else statements")
                }
            }
            else {
                startNode = node
            }
        }
        else {
            // Create a transform with a translation of 0.1 meters (10 cm) in front of the camera
            var translation = matrix_identity_float4x4
            translation.columns.3.z = -0.1
            // Add a node to the session
            let sphere = SCNSphere(radius: 0.005)
            sphere.firstMaterial?.diffuse.contents = UIColor.red
            sphere.firstMaterial?.lightingModel = .constant
            sphere.firstMaterial?.isDoubleSided = true
            let sphereNode = SCNNode(geometry: sphere)
            sphereNode.simdTransform = simd_mul(currentFrame.camera.transform, translation)
            sceneView.scene.rootNode.addChildNode(sphereNode)
            
            print("BELOW: \(counter)")

            if let startNode = startNode {
                endNode = sphereNode
                self.distanceLabel.text = String(format: "%.2f", distance(startNode: startNode, endNode: sphereNode)) + "m"
                
                if counter == 0 {
                    print("#@#@#@#@#@#@#@#@#@#")
                    print("#@#@#@#@#@#@#@#@#@#")
                    print("#@#@#@#@#@#@#@#@#@#")
                    c1 = locationWithBearing(bearingRadians: (locationManager?.heading!.trueHeading)!, distanceMeters: Double(distance(startNode: startNode, endNode: sphereNode)), origin: (locationManager?.location!.coordinate)!)
                    
                    counter = counter + 1
                }
                else if counter == 1 {
                    c2 = locationWithBearing(bearingRadians: (locationManager?.heading!.trueHeading)!, distanceMeters: Double(distance(startNode: startNode, endNode: sphereNode)), origin: (locationManager?.location!.coordinate)!)

                    counter = counter + 1
                }
                else if counter == 2 {
                    c3 = locationWithBearing(bearingRadians: (locationManager?.heading!.trueHeading)!, distanceMeters: Double(distance(startNode: startNode, endNode: sphereNode)), origin: (locationManager?.location!.coordinate)!)
                    
                    counter = counter + 1
                }
                else if counter == 3 {
                    c4 = locationWithBearing(bearingRadians: (locationManager?.heading!.trueHeading)!, distanceMeters: Double(distance(startNode: startNode, endNode: sphereNode)), origin: (locationManager?.location!.coordinate)!)
                    
                    counter = counter + 1
                    
                    if #available(iOS 13.0, *) {
                        let MainVC: AttendanceViewController = self.storyboard?.instantiateViewController(identifier: "MainVC") as! AttendanceViewController
                        MainVC.cp1 = c1
                        MainVC.cp2 = c2
                        MainVC.cp3 = c3
                        MainVC.cp4 = c4
                        self.navigationController?.pushViewController(MainVC, animated: true)
                    } else {
                        // Fallback on earlier versions
                    }
                    
                    print("ALL COORDINATES")
                    print("ALL COORDINATES")
                    print(c1)
                    print(c2)
                    print(c3)
                    print(c4)
                    print("ALL COORDINATES")
                    print("ALL COORDINATES")
                    
                }
                else {
                    //default statement
                    print("end of if else statements")
                }
                
            }
            else {
                startNode = sphereNode
            }
        }
    }

    func distance(startNode: SCNNode, endNode: SCNNode) -> Float {
        let vector = SCNVector3Make(startNode.position.x - endNode.position.x, startNode.position.y - endNode.position.y, startNode.position.z - endNode.position.z)
        // Scene units map to meters in ARKit.
        return sqrtf(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)
    }

    var dragOnInfinitePlanesEnabled = false

    // MARK: - ARSCNViewDelegate

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.updateFocusSquare()
        }
    }

    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
        case .notAvailable:
            trackingStateLabel.text = "Tracking not available"
            trackingStateLabel.textColor = .red
        case .normal:
            trackingStateLabel.text = "Tracking normal"
            trackingStateLabel.textColor = .green
        case .limited(let reason):
            switch reason {
            case .excessiveMotion:
                trackingStateLabel.text = "Tracking limited: excessive motion"
            case .insufficientFeatures:
                trackingStateLabel.text = "Tracking limited: insufficient features"
            case .initializing:
                trackingStateLabel.text = "Tracking limited: initializing"
            case .relocalizing:
                print("eeeeeeeeeeeeeeee")
            }
            trackingStateLabel.textColor = .yellow
        }
    }

    // MARK: - Focus Square

    var focusSquare = FocusSquare()

    func setupFocusSquare() {
        focusSquare.unhide()
        focusSquare.removeFromParentNode()
        sceneView.scene.rootNode.addChildNode(focusSquare)
    }

    func updateFocusSquare() {
        let (worldPosition, planeAnchor, _) = worldPositionFromScreenPosition(view.center, objectPos: focusSquare.position)
        if let worldPosition = worldPosition {
            focusSquare.update(for: worldPosition, planeAnchor: planeAnchor, camera: sceneView.session.currentFrame?.camera)
        }
    }
    
    func locationWithBearing(bearingRadians:Double, distanceMeters:Double, origin:CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let distRadians = distanceMeters / (6372797.6) // earth radius in meters

        let lat1 = origin.latitude * M_PI / 180
        let lon1 = origin.longitude * M_PI / 180

        let lat2 = asin(sin(lat1) * cos(distRadians) + cos(lat1) * sin(distRadians) * cos(bearingRadians))
        let lon2 = lon1 + atan2(sin(bearingRadians) * sin(distRadians) * cos(lat1), cos(distRadians) - sin(lat1) * sin(lat2))

        return CLLocationCoordinate2D(latitude: lat2 * 180 / M_PI, longitude: lon2 * 180 / M_PI)
    }
    
    
}

// Step 5: Implement the CLLocationManagerDelegate to handle the callback from CLLocationManager
extension LocationViewController: CLLocationManagerDelegate {
    
    // Code from Apple PlacingObjects demo: https://developer.apple.com/sample-code/wwdc/2017/PlacingObjects.zip

    func worldPositionFromScreenPosition(_ position: CGPoint,
                                         objectPos: SCNVector3?,
                                         infinitePlane: Bool = false) -> (position: SCNVector3?, planeAnchor: ARPlaneAnchor?, hitAPlane: Bool) {

        // -------------------------------------------------------------------------------
        // 1. Always do a hit test against exisiting plane anchors first.
        //    (If any such anchors exist & only within their extents.)

        let planeHitTestResults = sceneView.hitTest(position, types: .existingPlaneUsingExtent)
        if let result = planeHitTestResults.first {

            let planeHitTestPosition = SCNVector3.positionFromTransform(result.worldTransform)
            let planeAnchor = result.anchor

            // Return immediately - this is the best possible outcome.
            return (planeHitTestPosition, planeAnchor as? ARPlaneAnchor, true)
        }

        // -------------------------------------------------------------------------------
        // 2. Collect more information about the environment by hit testing against
        //    the feature point cloud, but do not return the result yet.

        var featureHitTestPosition: SCNVector3?
        var highQualityFeatureHitTestResult = false

        let highQualityfeatureHitTestResults = sceneView.hitTestWithFeatures(position, coneOpeningAngleInDegrees: 18, minDistance: 0.2, maxDistance: 2.0)

        if !highQualityfeatureHitTestResults.isEmpty {
            let result = highQualityfeatureHitTestResults[0]
            featureHitTestPosition = result.position
            highQualityFeatureHitTestResult = true
        }

        // -------------------------------------------------------------------------------
        // 3. If desired or necessary (no good feature hit test result): Hit test
        //    against an infinite, horizontal plane (ignoring the real world).

        if (infinitePlane && dragOnInfinitePlanesEnabled) || !highQualityFeatureHitTestResult {

            let pointOnPlane = objectPos ?? SCNVector3Zero

            let pointOnInfinitePlane = sceneView.hitTestWithInfiniteHorizontalPlane(position, pointOnPlane)
            if pointOnInfinitePlane != nil {
                return (pointOnInfinitePlane, nil, true)
            }
        }

        // -------------------------------------------------------------------------------
        // 4. If available, return the result of the hit test against high quality
        //    features if the hit tests against infinite planes were skipped or no
        //    infinite plane was hit.

        if highQualityFeatureHitTestResult {
            return (featureHitTestPosition, nil, false)
        }

        // -------------------------------------------------------------------------------
        // 5. As a last resort, perform a second, unfiltered hit test against features.
        //    If there are no features in the scene, the result returned here will be nil.

        let unfilteredFeatureHitTestResults = sceneView.hitTestWithFeatures(position)
        if !unfilteredFeatureHitTestResults.isEmpty {
            let result = unfilteredFeatureHitTestResults[0]
            return (result.position, nil, false)
        }

        return (nil, nil, false)
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
