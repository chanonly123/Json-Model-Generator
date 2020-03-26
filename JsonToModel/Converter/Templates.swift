//
//  Templates.swift
//  JsonToModel
//
//  Created by Chandan Karmakar on 23/03/20.
//  Copyright © 2020 Chandan. All rights reserved.
//

import Foundation

class TemplateList: Codable {
    var list: [TemplateBean] = []
}

class TemplateBean: Codable {
    var name: String = ""
    var template: String = ""
    var language: LangaugeType = .Swift
    let isUser: Bool
    let date: Int64 = Int64(Date().timeIntervalSince1970)
    
    init(n: String, t: String, l: LangaugeType, isUser: Bool) {
        self.name = n; self.template = t; language = l; self.isUser = isUser
    }
}

extension TemplateList {
    static func createInitialList() -> [TemplateBean] {
        var arr = [TemplateBean]()
        let url = Bundle.main.url(forResource: "TemplateData", withExtension: "txt")!
        let str = (try? String(contentsOf: url).split(separator: "#")) ?? []
        var i = 0
        while i + 1 < str.count {
            let name = str[i].split(separator: "|")[0].trimmingCharacters(in: .whitespacesAndNewlines)
            let lang = str[i].split(separator: "|")[1].trimmingCharacters(in: .whitespacesAndNewlines)
            let template = String(str[i+1]).trimmingCharacters(in: .whitespacesAndNewlines)
            let t = TemplateBean(n: name, t: template, l: LangaugeType(rawValue: lang)!, isUser: false)
            i += 2
            arr.append(t)
        }
        return arr
    }
}
