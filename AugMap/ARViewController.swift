//
//  ARViewController.swift
//  
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
    var locManager: CLLocationManager!
    
    @IBOutlet weak var backbutton: UIButton!
    //前ページからのデータ受け取り用変数
    var pinlon:Float = 0.0
    var pinlat:Float = 0.0
    var currentlon:Float = 0.0
    var currentlat:Float = 0.0
    
     var angle:Float = -1
     let lat2km:Float = 111319.319
     var distance:Double = 0
    var globaldz:Float = 0.0
    var globaldx:Float = 0.0

    
    @IBAction func back(_ sender: Any) {
        let storyboard: UIStoryboard = self.storyboard!
        let mappage = storyboard.instantiateViewController(withIdentifier: "mappage")
        self.present(mappage,animated:true,completion:nil)
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
        let unko = SIMD3<Float>(100,100,100)
        model.scale = unko
        anchor1.addChild(model)
    }
    //オブジェクト座標算出メソッド
    func CalcAngle(_ pinlat1:Float ,_ currentlat2:Float,_ pinlon1:Float,_ currentlon2:Float) -> SIMD3<Float>{
        globaldz = (currentlat2 - pinlat1) * lat2km
        globaldx = -(currentlon2 - pinlon1) * lat2km
        let data = SIMD3<Float>(globaldx,0,globaldz)
        return data
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let nowlat = (manager.location?.coordinate.latitude)!
        let nowlon = (manager.location?.coordinate.longitude)!
        let result = CalcAngle(pinlat, Float(nowlat), pinlon, Float(nowlon))
        let unkox = result.x
        let unkoz = result.z
        judg1km(unkox, unkoz)
        }
    //２点の座標から距離をmで表示する
    func CalcDistance(_ Destination_lat:Double,_ Current_lat:Double,_ Destination_lon:Double,_ Current_lon:Double) -> Double{
        
        let now:CLLocation = CLLocation(latitude: Current_lat, longitude: Current_lon)
        let pin:CLLocation = CLLocation(latitude: Destination_lat, longitude: Destination_lon)
        let Cdistance = pin.distance(from: now)
        return Cdistance
    }
    
    func First() ->Double{
        let Current_lat = (locManager.location?.coordinate.latitude)!
        let Current_lon = (locManager.location?.coordinate.longitude)!
        print("nowlat:\(Current_lat)")
        print("now:lon:\(Current_lon)")
        print("pinlon:\(pinlon)")
        print("pinlat:\(pinlat)")
        distance = CalcDistance(Double(pinlat), Current_lat, Double(pinlon), Current_lon)
        print(distance)
        return distance
    }
    
    func judg1km(_ dx:Float,_ dz:Float) {
        
        var _dx:Float = dx
        var _dz:Float = dz
        
        if _dx < 0 && _dz < 0{
            _dx = -_dx
            _dz = -_dz
            km(_dx,_dz)
        }else if _dx < 0{
            _dx = -_dx
            km(_dx,_dz)
        }else if _dz < 0{
            _dz = -_dz
            km(_dx,_dz)
        }else{
            km(_dz,_dz)
        }
    }
    func km(_ x:Float,_ z:Float){
        let _1km:Float = 1000
        if x > _1km && z > _1km{
            let _x = x / _1km
            let _z = z / _1km
        }else if x > _1km{
            let _x = x / _1km
        }else if z > _1km{
            let _z = z / _1km
        }else{
            
        }
        
    }
}
