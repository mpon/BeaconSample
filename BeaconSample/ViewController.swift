//
//  ViewController.swift
//  BeaconSample
//
//  Created by Masato Oshima on 2014/12/06.
//  Copyright (c) 2014年 Masato Oshima. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveBeacons:", name: BeaconManager.BeaconReceiveNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: BeaconManager.BeaconReceiveNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
        ビーコンを受信したときにNSNotificationCenterから通知される
    
        :param: NSNotification The notification from NSNotificationCenter has object beacons
    */
    func didReceiveBeacons(notification: NSNotification) {
        if let beacons = notification.object as? [AnyObject]! {
            println(beacons.count)
        }
    }


}

