//
//  VersionCheck.swift
//  JsonToModel
//
//  Created by Chandan Karmakar on 06/05/20.
//  Copyright © 2020 Chandan. All rights reserved.
//

import Cocoa

class VersionCheck {
    static func checkVersion() {
        DispatchQueue.global(qos: .utility).async {
            let urlString = "https://github.com/chanonly123/Json-Model-Generator/raw/master/new_version_info.json"
            guard let url = URL(string: urlString) else {
                print("no url"); return
            }
            guard let data = try? Data(contentsOf: url) else {
                print("no data"); return
            }
            guard let verData = try? JSONDecoder().decode(VersionData.self, from: data) else {
                print("no verData"); return
            }
            guard let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
                print("no appVersion"); return
            }
            guard let appVersionInt = Int(appVersion.replacingOccurrences(of: ".", with: "")) else {
                print("no appVersionInt"); return
            }
            if let newVersion = verData.newVersion?.replacingOccurrences(of: ".", with: ""),
                let redirectUrl = verData.redirectUrl,
                let newVersionInt = Int(newVersion),
                newVersionInt > appVersionInt {
                DispatchQueue.main.async {
                    let alert = NSAlert()
                    alert.messageText = "New version available \(verData.newVersion!)"
                    alert.addButton(withTitle: "Update")
                    alert.addButton(withTitle: "Later")
                    if alert.runModal() == .alertFirstButtonReturn {
                        if let url = URL(string: redirectUrl) {
                            NSWorkspace.shared.open(url)
                        }
                    }
                }
            }
        }
        
    }
}

class VersionData: Codable {
    var redirectUrl: String?
    var newVersion: String?
}
