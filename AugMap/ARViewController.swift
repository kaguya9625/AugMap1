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
    override var prefersStatusBarHidden: Bool { return true }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation { return .slide }
    
    @IBOutlet var arView: ARView!
    @IBOutlet weak var back: UIButton!
    var locManager: CLLocationManager!
    
    //前ページからのデータ受け取り用変数
    var pinlon:Float = 0.0
    var pinlat:Float = 0.0
    var currentlon:Float = 0.0
    var currentlat:Float = 0.0
    var anchor:AnchorEntity!
     
    var distance:Double = 0
    var globaldz:Float = 0.0
    var globaldx:Float = 0.0
    
    @IBAction func backbutton(_ sender: Any) {
        //遷移処理
          let storyboard: UIStoryboard = self.storyboard!
           let mappage = storyboard.instantiateViewController(withIdentifier: "mappage")
           self.present(mappage,animated: true,completion: nil)
        arView.scene.removeAnchor(anchor)
       }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
        locManager.startUpdatingLocation()
        initar()
        setobj()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        alert()
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
        let check = judg()
        var objname = ""
        switch check {
        case 1:
            objname = "kanban"
        case 2:
            //objname = "untitled"
            objname = "animation"
        default:
            break
        }
        
       let Light = DirectionalLightComponent(color: .white, intensity: 2500, isRealWorldProxy: true)
       guard let model = try? Entity.load(named:"art.scnassets/\(objname)") else {return}
       let Aug = CalcAngle(pinlat, currentlat, pinlon, currentlon)
        anchor = AnchorEntity(world: Aug)
        anchor.components.set(Light)
        arView.scene.anchors.append(anchor)

        let unko = SIMD3<Float>(10,10,10)
        model.scale = unko
        anchor.addChild(model)
        
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
        case 2:
            break
        default:
            print("default")
        }
        let data = SIMD3<Float>(globaldx,-1.25,globaldz)
        return data
    }
    
    //２点の座標から距離をmで表示する
    func CalcDistance(_ Destination_lat:Double,_ Current_lat:Double,_ Destination_lon:Double,_ Current_lon:Double) -> Double{
        let now:CLLocation = CLLocation(latitude: Current_lat, longitude: Current_lon)
        let pin:CLLocation = CLLocation(latitude: Destination_lat, longitude: Destination_lon)
        let Cdistance = pin.distance(from: now)
        return Cdistance
    }
    
    //距離が1000~3000mの場合4/1
    func judg() ->Int{
        var data = 0
        let Current_lat = Float((locManager.location?.coordinate.latitude)!)
        let Current_lon = Float((locManager.location?.coordinate.longitude)!)
        distance = CalcDistance(Double(pinlat), Double(Current_lat), Double(pinlon), Double(Current_lon))
        print(distance)
        if distance <= 3000 && 50 <= distance{
            print("看板")
            data = 1
        }else if distance <= 49 && 0 <= distance{
            print("かまトぅ")
            data = 2
        }else{
           print("non")
        }
        return data
    }
    
    func alert(){
       let alert:UIAlertController = UIAlertController(title:"注意",message:"歩きスマホに注意してください", preferredStyle: UIAlertController.Style.alert)
        let confirmAction: UIAlertAction = UIAlertAction(title: "了解", style: UIAlertAction.Style.default, handler:{
        // 確定ボタンが押された時の処理をクロージャ実装する
        (action: UIAlertAction!) -> Void in
        })
        alert.addAction(confirmAction)
        present(alert,animated: true,completion: nil)
    }
    
}
