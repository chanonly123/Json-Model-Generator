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
}

extension TemplateList {
    static func createInitialList() -> [TemplateBean] {
        var arr = [TemplateBean]()
        let url = Bundle.main.url(forResource: "TemplateData", withExtension: "txt")!
        let str = (try? String(contentsOf: url).split(separator: "#")) ?? []
        var i = 0
        while i + 1 < str.count {
            let t = TemplateBean()
            t.name = String(str[i]).trimmingCharacters(in: .whitespacesAndNewlines)
            t.template = String(str[i+1]).trimmingCharacters(in: .whitespacesAndNewlines)
            i += 2
            arr.append(t)
        }
        return arr
    }
}
