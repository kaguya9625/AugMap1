//
//  ViewController.swift
//  real
//
//  Created by IS10 on 2019/11/25.
//  Copyright © 2019 IS10. All rights reserved.
//

import UIKit
import ARKit
import RealityKit
import CoreLocation

class ARViewController: UIViewController,
                        UIGestureRecognizerDelegate,
                        CLLocationManagerDelegate {
    
    @IBOutlet var arView: ARView!
    @IBOutlet weak var back: UIButton!
    var locManager: CLLocationManager!
    
    //前ページからのデータ受け取り用変数
    var pinlon:Float = 0.0
    var pinlat:Float = 0.0
    var currentlon:Float = 0.0
    var currentlat:Float = 0.0
    
     
    var distance:Double = 0
    var globaldz:Float = 0.0
    var globaldx:Float = 0.0
    
    @IBAction func backbutton(_ sender: Any) {
           //遷移処理
           let storyboard: UIStoryboard = self.storyboard!
           let mappage = storyboard.instantiateViewController(withIdentifier: "mappage")
           self.present(mappage,animated: true,completion: nil)
       }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
        locManager.startUpdatingLocation()
        initar()
        setobj()
    }
    func setupLocationManager(){
        locManager = CLLocationManager()
    }
    override func viewWillDisappear(_ animated: Bool) {
        arView.session.pause()
    }
    
    
    func initar(){
       //arView.debugOptions = [.showStatistics, .showFeaturePoints,.showWorldOrigin]
        let configuration = ARWorldTrackingConfiguration()
       configuration.worldAlignment = .gravityAndHeading
       arView.session.run(configuration)
    }
    
    func setobj(){
        let Aug = CalcAngle(pinlat, currentlat, pinlon, currentlon)
        let anchor1 = AnchorEntity(world: Aug)
        arView.scene.anchors.append(anchor1)
        guard let model = try? Entity.load(named:"art.scnassets/tinko") else {return}
        let unko = SIMD3<Float>(30,30,30)
        model.scale = unko
        anchor1.addChild(model)
    }
    //オブジェクト座標算出メソッド
    func CalcAngle(_ pinlat1:Float ,_ currentlat2:Float,_ pinlon1:Float,_ currentlon2:Float) -> SIMD3<Float>{
        let lat2km:Float = 111319.319
        globaldz = (currentlat2 - pinlat1) * lat2km
        globaldx = -(currentlon2 - pinlon1) * lat2km
        let _judg = judg()
        switch _judg {
        case 0:
            print("0")
        case 1:
            globaldx = globaldx/4
            globaldz = globaldz/4
        default:
            print("default")
        }
        let data = SIMD3<Float>(globaldx,-1,globaldz)
        return data
    }
    
    //２点の座標から距離をmで表示する
    func CalcDistance(_ Destination_lat:Double,_ Current_lat:Double,_ Destination_lon:Double,_ Current_lon:Double) -> Double{
        let now:CLLocation = CLLocation(latitude: Current_lat, longitude: Current_lon)
        let pin:CLLocation = CLLocation(latitude: Destination_lat, longitude: Destination_lon)
        let Cdistance = pin.distance(from: now)
        return Cdistance
    }
    func judg() ->Int{
        var data = 0
        let Current_lat = Float((locManager.location?.coordinate.latitude)!)
        let Current_lon = Float((locManager.location?.coordinate.longitude)!)
        distance = CalcDistance(Double(pinlat), Double(Current_lat), Double(pinlon), Double(Current_lon))
        print(distance)
        if distance <= 3000 && 1000 <= distance{
            print("4/1")
            data = 1
        }else{
            print("non")
        }
        return data
    }
    
    func check()->Int{
        var unko = 0
        if distance <= 3000 && distance >= 2501{
            unko = 80
        }else if distance <= 2500 && distance >= 2001{
            unko = 70
        }else if distance <= 2000 && distance >= 1501{
            unko = 60
        }else if distance <= 1500 && distance >= 1001{
            unko = 50
        }else if distance <= 1000 && distance >= 501{
            unko = 40
        }else if distance <= 500 && distance >= 101{
            unko = 30
        }else if distance <= 100 && distance >= 51{
            unko = 10
        }
        
        return unko
    }
}
