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
                      UISearchBarDelegate,
                      MKMapViewDelegate{

    
    var locManager:CLLocationManager!
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet var longPressGesRec:UILongPressGestureRecognizer!
    var currentlat:Float = 0
    var currentlon:Float = 0
    var pointAno:MKPointAnnotation = MKPointAnnotation()
    var userLocation: CLLocationCoordinate2D!
    var destLocation: CLLocationCoordinate2D!
    let geocoder = CLGeocoder()
    
    @IBOutlet var map: MKMapView!
    @IBOutlet weak var destSearchBar: UISearchBar!

    
    @IBAction func ARbutton(_ sender: Any) {
             //遷移処理
             let storyboard: UIStoryboard = self.storyboard!
             let ARpage = storyboard.instantiateViewController(withIdentifier: "ARpage") as! ARViewController
             ARpage.pinlon = Float(pointAno.coordinate.longitude)
             ARpage.pinlat = Float(pointAno.coordinate.latitude)
             ARpage.currentlat = Float(map.userLocation.coordinate.latitude)
             ARpage.currentlon = Float(map.userLocation.coordinate.longitude)
             
             self.present(ARpage,animated: true,completion: nil)
         
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        map.delegate = self
        destSearchBar.delegate = self
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
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // キーボードを隠す
        destSearchBar.resignFirstResponder()
        // セット済みのピンを削除
        self.map.removeAnnotations(self.map.annotations)
        // 描画済みの経路を削除
        self.map.removeOverlays(self.map.overlays)

        // 目的地の文字列から座標検索
     
        self.geocoder.geocodeAddressString(destSearchBar.text!,completionHandler: {(placemarks: [CLPlacemark]!, error: NSError!) -> Void in
            if let placemark = placemarks?[0] {
                // 目的地のΩ座標を取得
                self.destLocation = CLLocationCoordinate2DMake(placemark.location!.coordinate.latitude, placemark.location!.coordinate.longitude)
                // 目的地にピンを立てる
                self.map.addAnnotation(MKPlacemark(placemark: placemark))
                // 現在地の取得を開始
                self.locManager.startUpdatingLocation()
            }
            
            // 実行エラー　Thread 1: signal SIGABRT
            } as! CLGeocodeCompletionHandler)
    }
    
    
    
    
    //位置情報の取得
    func locationManager(manager: CLLocationManager!,didUpdateLocations locations: [AnyObject]!){

        userLocation = CLLocationCoordinate2DMake(manager.location!.coordinate.latitude, manager.location!.coordinate.longitude)

        let userLocAnnotation: MKPointAnnotation = MKPointAnnotation()
        userLocAnnotation.coordinate = userLocation
        userLocAnnotation.title = "現在地"
        map.addAnnotation(userLocAnnotation)
        // 現在地から目的地家の経路を検索
        getRoute()
    }
    // 位置情報取得に失敗した時に呼び出されるデリゲート.
    private func locationManager(manager: CLLocationManager!,didFailWithError error: NSError!){
        print("locationManager error")
    }
    
    //地図上に線を引く
     func getRoute()
       {
           // 現在地と目的地のMKPlacemarkを生成
        let fromPlacemark = MKPlacemark(coordinate:userLocation, addressDictionary:nil)
        let toPlacemark   = MKPlacemark(coordinate:destLocation, addressDictionary:nil)

           // MKPlacemark から MKMapItem を生成
        let fromItem = MKMapItem(placemark:fromPlacemark)
        let toItem   = MKMapItem(placemark:toPlacemark)

           // MKMapItem をセットして MKDirectionsRequest を生成
        let request = MKDirections.Request()


           request.source = fromItem
           request.destination = toItem
           request.requestsAlternateRoutes = false // 単独の経路を検索
        request.transportType = MKDirectionsTransportType.any

           let directions = MKDirections(request:request)
           directions.calculate(completionHandler: {
            (response:MKDirections.Response!, error:NSError!) -> Void in

               response.routes.count
               if (error != nil || response.routes.isEmpty) {
                   return
               }
            let route: MKRoute = response.routes[0] as MKRoute
               // 経路を描画
            self.map.addOverlay(route.polyline)
               // 現在地と目的地を含む表示範囲を設定する
            var region:MKCoordinateRegion = self.map.region
            region.span.latitudeDelta=0.02
            region.span.longitudeDelta=0.02
            } as! MKDirections.DirectionsHandler)
       }
    

    
 

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
        let  CGPoint = sender.location(in: map)
        
        if sender.state == .began{
            }
        else if sender.state == .ended{
        let tappoint = sender.location(in: view)
        let center = map.convert(tappoint, toCoordinateFrom: map)
        
        pointAno.coordinate = center
        
        map.addAnnotation(pointAno)
        button.isEnabled = true
        
        pointAno.title = "目的地"
        
        }
        
    }
    //距離計算
    func CalcDistance(_ a:CLLocationCoordinate2D ,_ b:CLLocationCoordinate2D) -> CLLocationDistance {
            let aloc:CLLocation = CLLocation(latitude: a.latitude, longitude: a.longitude)
            let bloc:CLLocation = CLLocation(latitude: b.latitude, longitude: b.longitude)
            let dist = bloc.distance(from: aloc)
            return dist
    }
    
    
}

