//
//  ViewController.swift
//  AugMap
//
//  Created by kaguya on 2019/05/06.
//  Copyright © 2019 kaguya. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController,
                      CLLocationManagerDelegate,
                      UIGestureRecognizerDelegate,
                      MKMapViewDelegate{
    
    @IBOutlet var map: MKMapView!
    @IBOutlet var LongPress: UILongPressGestureRecognizer!
    var locManager:CLLocationManager!
    @IBOutlet weak var button: UIButton!
    var currentlat:Float = 0
    var currentlon:Float = 0
    var pointAno:MKPointAnnotation = MKPointAnnotation()
    var userLocation: CLLocationCoordinate2D!
    var destLocation: CLLocationCoordinate2D!
    var mkCircle = MKCircle(center:CLLocationCoordinate2DMake(0.0,0.0),radius: 1000)
    var mySearchBar:UISearchBar!
    var myRegion: MKCoordinateRegion!
    var CircleCheck = 0
    @IBOutlet weak var Circlebtn: UIButton!
    
    @IBAction func ARbutton(_ sender: Any) {
             //遷移処理
//             let storyboard: UIStoryboard = self.storyboard!
//             let ARpage = storyboard.instantiateViewController(withIdentifier: "ARpage") as! ARViewController
//             ARpage.pinlon = Float(pointAno.coordinate.longitude)
//             ARpage.pinlat = Float(pointAno.coordinate.latitude)
//             ARpage.currentlat = Float(map.userLocation.coordinate.latitude)
//             ARpage.currentlon = Float(map.userLocation.coordinate.longitude)
//
//             self.present(ARpage,animated: true,completion: nil)

        let sourceL = map.userLocation.coordinate
        let destinaL = pointAno.coordinate
        
        let sourcePlaceMark = MKPlacemark(coordinate: sourceL)
        let destinaPlaceMark = MKPlacemark(coordinate: destinaL)
        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem(placemark: sourcePlaceMark)
        directionRequest.destination = MKMapItem(placemark: destinaPlaceMark)
        directionRequest.transportType = .walking
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate{(response,error)in
            guard let directionResonse = response else{
                if let error = error{
                    print("error")
                }
                return
            }
            let route = directionResonse.routes[0]
            self.map.addOverlay(route.polyline, level: .aboveRoads)
            let rect = route.polyline.boundingMapRect
            self.map.setRegion(MKCoordinateRegion(rect), animated: true)
                                 
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
          let renderer = MKPolylineRenderer(overlay: overlay)
          renderer.strokeColor = UIColor.blue
          renderer.lineWidth = 4.0
          return renderer
      }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        map.delegate = self
        locManager = CLLocationManager()
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            switch CLLocationManager.authorizationStatus(){
            case .authorizedAlways:
                locManager.startUpdatingLocation()
                break
            default:
                break
            }
        }
        initMap()
    }
    

    
//目的地を検索
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        // キーボードを隠す
//        destSearchBar.resignFirstResponder()
//        // セット済みのピンを削除
//        self.map.removeAnnotations(self.map.annotations)
//        // 描画済みの経路を削除
//        self.map.removeOverlays(self.map.overlays)
//
//        // 目的地の文字列から座標検索
//
//        self.geocoder.geocodeAddressString(destSearchBar.text!,completionHandler: {(placemarks: [CLPlacemark]!, error: NSError!) -> Void in
//            if let placemark = placemarks?[0] {
//                // 目的地のΩ座標を取得
//                self.destLocation = CLLocationCoordinate2DMake(placemark.location!.coordinate.latitude, placemark.location!.coordinate.longitude)
//                // 目的地にピンを立てる
//                self.map.addAnnotation(MKPlacemark(placemark: placemark))
//                // 現在地の取得を開始
//                self.locManager.startUpdatingLocation()
//            }
//
//            // 実行エラー　Thread 1: signal SIGABRT
//            } as! CLGeocodeCompletionHandler)
//    }
    
    
    
    
    //位置情報の取得
    func locationManager(manager: CLLocationManager!,didUpdateLocations locations: [AnyObject]!){

        userLocation = CLLocationCoordinate2DMake(manager.location!.coordinate.latitude, manager.location!.coordinate.longitude)

        let userLocAnnotation: MKPointAnnotation = MKPointAnnotation()
        userLocAnnotation.coordinate = userLocation
        userLocAnnotation.title = "現在地"
        map.addAnnotation(userLocAnnotation)
        // 現在地から目的地家の経路を検索
        //getRoute()
    }
    // 位置情報取得に失敗した時に呼び出されるデリゲート.
    private func locationManager(manager: CLLocationManager!,didFailWithError error: NSError!){
        print("locationManager error")
    }
    
//    //地図上に線を引く
//     func getRoute()
//       {
//           // 現在地と目的地のMKPlacemarkを生成
//        let fromPlacemark = MKPlacemark(coordinate:userLocation, addressDictionary:nil)
//        let toPlacemark   = MKPlacemark(coordinate:destLocation, addressDictionary:nil)
//
//           // MKPlacemark から MKMapItem を生成
//        let fromItem = MKMapItem(placemark:fromPlacemark)
//        let toItem   = MKMapItem(placemark:toPlacemark)
//
//           // MKMapItem をセットして MKDirectionsRequest を生成
//        let request = MKDirections.Request()
//
//
//           request.source = fromItem
//           request.destination = toItem
//           request.requestsAlternateRoutes = false // 単独の経路を検索
//        request.transportType = MKDirectionsTransportType.any
//
//           let directions = MKDirections(request:request)
//           directions.calculate(completionHandler: {
//            (response:MKDirections.Response!, error:NSError!) -> Void in
//
//               response.routes.count
//               if (error != nil || response.routes.isEmpty) {
//                   return
//               }
//            let route: MKRoute = response.routes[0] as MKRoute
//               // 経路を描画
//            self.map.addOverlay(route.polyline)
//               // 現在地と目的地を含む表示範囲を設定する
//            var region:MKCoordinateRegion = self.map.region
//            region.span.latitudeDelta=0.02
//            region.span.longitudeDelta=0.02
//            } as! MKDirections.DirectionsHandler)
//       }
    

    
 

    func locationManager(_ manager:CLLocationManager,didUpdateLocations locations:[CLLocation]){
        map.userTrackingMode = .follow
        //現在値とピンの距離を計算
        let distance = CalcDistance(map.userLocation.coordinate,pointAno.coordinate)
        if(0 != distance){
            var str:String = Int(distance/1000).description
            str = str + "km"
            if pointAno.title != str{
                pointAno.title = str
                map.addAnnotation(pointAno)
            }
        }
    }
  
    func initMap(){
        var region:MKCoordinateRegion = map.region
        region.span.latitudeDelta=0.02
        region.span.longitudeDelta=0.02
        map.setRegion(region, animated: true)
        map.showsUserLocation = true
        map.userTrackingMode = MKUserTrackingMode.followWithHeading
        map.userLocation.title = ""
        if pointAno.coordinate.latitude == 0{
            button.isEnabled = false
        }

    }
    
    func updateCurrentpos(_ coordinate:CLLocationCoordinate2D){
        var region:MKCoordinateRegion = map.region
        region.center = coordinate
        map.setRegion(region, animated: true)
    }
    
    @IBAction func mapLongPress(_ sender: UILongPressGestureRecognizer){
        _ = sender.location(in: map)
        
        if sender.state == .began{
            }
        else if sender.state == .ended{
        let tappoint = sender.location(in: view)
        let center = map.convert(tappoint, toCoordinateFrom: map)
        pointAno.coordinate = center
        let distance = CalcDistance(map.userLocation.coordinate,pointAno.coordinate)
            if distance >= 3001.0{
                button.isEnabled = false
                map.removeAnnotation(pointAno)
              let alert:UIAlertController = UIAlertController(title:"error!",message:"距離が遠すぎます", preferredStyle: UIAlertController.Style.alert)
                let confirmAction: UIAlertAction = UIAlertAction(title: "もどる", style: UIAlertAction.Style.default, handler:{
                // 確定ボタンが押された時の処理をクロージャ実装する
                (action: UIAlertAction!) -> Void in
                })
                alert.addAction(confirmAction)
                present(alert,animated: true,completion: nil)
            }else{
                map.addAnnotation(pointAno)
                     button.isEnabled = true
                     pointAno.title = String(distance)
            }
        }
        
    }
    //距離計算
    func CalcDistance(_ a:CLLocationCoordinate2D ,_ b:CLLocationCoordinate2D) -> CLLocationDistance {
            let aloc:CLLocation = CLLocation(latitude: a.latitude, longitude: a.longitude)
            let bloc:CLLocation = CLLocation(latitude: b.latitude, longitude: b.longitude)
            let dist = bloc.distance(from: aloc)
            return dist
    }
    
    //円の表示
//    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//        let circle : MKCircleRenderer = MKCircleRenderer(overlay: overlay);
//        circle.strokeColor = UIColor.green //円のborderの色
//        circle.fillColor = UIColor(red: 0.0, green: 0.2, blue: 0.5, alpha: 0.3)  //円全体の色。今回は赤色
//        circle.lineWidth = 1.0 //円のボーダーの太さ。
//        return circle
//    }
    
    @IBAction func Circle(_ sender: Any) {
     if CircleCheck == 0{
         CircleCheck = 1
        Circlebtn.setTitle("円を非表示", for: .normal)
     let userCoordinate = map.userLocation.coordinate//現在地取得(円の中心)
     mkCircle = MKCircle(center: userCoordinate, radius:3000)//円の中心と半径を設定
     map.addOverlay(mkCircle)//円を描写(さっき書いたメソッドの呼び出し)
     }else{
         CircleCheck = 0
        Circlebtn.setTitle("円を表示", for: .normal)
         map.removeOverlay(mkCircle) //すでにマップ上にある円を削除
      }
    }
}

