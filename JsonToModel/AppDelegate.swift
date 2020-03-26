//
//  AppDelegate.swift
//  JsonToModel
//
//  Created by Chandan on 05/11/18.
//  Copyright © 2018 Chandan. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @IBAction func actionDeleteUserTemplates(_ sender: Any) {
        LocalVars.savedTemplates = nil
        ViewController.viewc?.reloadTemplates()
    }
}

