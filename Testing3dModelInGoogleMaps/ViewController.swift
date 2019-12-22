import UIKit
import GoogleMaps
import CoreLocation
import SceneKit

 
class HHCarMarker:GMSMarker {
    var cameraNode = SCNNode()
//    let scene = SCNScene(named:"Assets.scnassets/lexus_hs.obj")!
    let scene = SCNScene(named:"Assets.scnassets/Tesla+Model+X.dae")!

    let sceneView = SCNView.init()
    var car = SCNNode()
 
    let horizontalTiltDegree: Double = 10.0
    //let cameraAltitude: Float = 80.0
    let cameraAltitude: Float = 13
    let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
    var lastHeading : Double = 0.0
    var heading:CLHeading = CLHeading(){
        didSet {
            self.car.eulerAngles = SCNVector3(x:0, y: -Float(deg2rad(self.heading.trueHeading)) - Float(Double.pi/2) , z: 0.0)
        }
    }
    
    var scale: Float = 1 {
        didSet {
            car.scale = SCNVector3(x: scale, y: scale, z: scale)
        }
    }
    
    override init(){
        super.init()
        self.appearAnimation = .pop
        setupSceneKit()
    }
    func setupSceneKit() {
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3.init(7, 8, 0.0)
        cameraNode.eulerAngles = SCNVector3(x: Float(deg2rad(3)), y: Float(Double.pi/2), z: Float(deg2rad(40)))
        
        scene.rootNode.addChildNode(cameraNode)
        sceneView.frame = containerView.bounds
        containerView.addSubview(sceneView)
        sceneView.allowsCameraControl = false
        sceneView.autoenablesDefaultLighting = true
        sceneView.backgroundColor = UIColor.clear
        sceneView.scene = scene
        sceneView.antialiasingMode = .none
        containerView.addSubview(sceneView)
         
        self.iconView = containerView
        self.groundAnchor = CGPoint.init(x: 0.5, y: 0.5)
        
        car = scene.rootNode.childNode(withName: "parent", recursively: true)!
        //car.geometry?.materials.first?.diffuse.contents = UIImage(named: "Assets.scnassets/Lexus jpg.jpg")
        car.scale = SCNVector3(x: scale, y: scale, z: scale)
        car.eulerAngles = SCNVector3(x: 0 , y:  0  , z: 0.0)
        
        
    }
    
   
    
}
func deg2rad(_ number: Double) -> Double {
       return number * .pi / 180
   }

class ViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate, SCNSceneRendererDelegate {
    @IBOutlet weak var mapView: GMSMapView!
    var locationManager = CLLocationManager()
    var marker:HHCarMarker!
 
    
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
    
    func setupMap() {
        mapView.delegate = self
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = false
        mapView.settings.rotateGestures = false
        mapView.settings.tiltGestures = false
        mapView.animate(toZoom:  16)
        //mapView.animate(toViewingAngle: 0)
        marker = HHCarMarker.init()
        marker.map = mapView
        self.mapView.animate(toViewingAngle: 20)
        if let styleURL = Bundle.main.url(forResource: "mapStyle", withExtension: "json") {
            mapView.mapStyle = try! GMSMapStyle(contentsOfFileURL: styleURL)
         }

        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last?.coordinate
        marker.position = location!
        self.mapView.animate(toLocation: location!)
    }
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        let zoom = position.zoom
        let scale = (position.zoom/16)
        print(scale)
        marker.scale = scale > 1 ? 1: scale
        print(marker.scale)
     }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
   
        marker.heading = newHeading
        
     }
}


  
