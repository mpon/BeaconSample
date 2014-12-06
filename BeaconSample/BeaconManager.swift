//
//  BeaconManager.swift
//  BeaconSample
//
//  Created by Masato Oshima on 2014/12/06.
//  Copyright (c) 2014年 Masato Oshima. All rights reserved.
//

import UIKit
import CoreLocation


/**
    ビーコンの受信を受けてNSNotificationをPostするクラス

    シングルトンなのでsharedInstance経由でアクセスする
*/
class BeaconManager: NSObject, CLLocationManagerDelegate {
    
    /// ビーコンを受信したときの通知名
    class var BeaconReceiveNotification :String { return "BeaconReceiveNotification" }
    
    
    /// 監視するiBeacon
    private let beaconRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXXX"), identifier: NSBundle.mainBundle().bundleIdentifier)
    
    private let locationManager = CLLocationManager()
    
    /**
        シングルトンインスタンス
    */
    class var sharedInstance : BeaconManager {
        struct Static {
            static let instance : BeaconManager = BeaconManager()
        }
        return Static.instance
    }
    
    /**
        iBeaconの監視を開始する
    */
    func startMonitoring() {
        self.locationManager.delegate = self
        
        if !CLLocationManager.isMonitoringAvailableForClass(CLBeaconRegion) {
            return
        }
        
        if !CLLocationManager.isRangingAvailable() {
            return
        }
        
        // アプリがバックグラウンド状態の場合は位置情報のバックグラウンド更新をする
        // これをしないとiBeaconの範囲に入ったか入っていないか検知してくれない
        let appStatus = UIApplication.sharedApplication().applicationState
        let isBackground = appStatus == .Background || appStatus == .Inactive
        if isBackground {
            self.locationManager.startUpdatingLocation()
        }
        
        // locationManager: didStartMonitoringForRegion: のdelegateが呼ばれる
        self.locationManager.startMonitoringForRegion(self.beaconRegion)
    }
    
    /**
        iBeaconのレンジングを再開する
    */
    func resumeRanging() {
        self.locationManager.startMonitoringForRegion(self.beaconRegion)
    }
    
    /**
        iBeaconのレンジングをストップする。
    */
    func stopRanging() {
        self.locationManager.stopRangingBeaconsInRegion(self.beaconRegion)
    }
    
    
    // MARK: - CLLocationManagerDelegate
    
    // region内にすでにいる場合に備えて、必ずregionについての状態を知らせてくれるように要求する必要がある
    // このリクエストは非同期で行われ、結果は locationManager:didDetermineState:forRegion: で呼ばれる
    func locationManager(manager: CLLocationManager!, didStartMonitoringForRegion region: CLRegion!) {
        manager.requestStateForRegion(region)
    }
    
    // 位置情報を使うためのユーザーへの認証が必要になる
    // 認証を依頼するためにコードでリクエストを出すないといけない
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .NotDetermined {
            self.locationManager.requestAlwaysAuthorization()
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println(error)
    }
    
    // iBeaconの範囲内にいるのかいないのかが通知される
    // いる場合はレンジングを開始する。
    func locationManager(manager: CLLocationManager!, didDetermineState state: CLRegionState, forRegion region: CLRegion!) {
        switch state {
        case .Inside:
            if region is CLBeaconRegion && CLLocationManager.isRangingAvailable() {
                manager.startRangingBeaconsInRegion(region as CLBeaconRegion)
            }
        default:
            break
        }
    }
    
    // iBeaconの範囲内にいる場合に1秒間隔で呼ばれ、iBeaconの情報を取得できる。
    func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
        
        // Beacon情報とともにNSNotificationCenterで通知する
        if !beacons.isEmpty {
            NSNotificationCenter.defaultCenter()
                .postNotificationName(BeaconManager.BeaconReceiveNotification, object: beacons)
        }
    }
}
