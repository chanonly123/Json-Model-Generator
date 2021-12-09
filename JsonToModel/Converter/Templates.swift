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
    var templateHeader: String = ""
    var language: LangaugeType = .Swift
    let isUser: Bool
    let date: Int64
    
    static let HEADER_MARKER = "<<<"
    
    init(n: String, t: String, l: LangaugeType, isUser: Bool) {
        self.name = n; self.template = t; language = l; self.isUser = isUser
        self.date = Int64(Date().timeIntervalSince1970)
        self.handleHeader()
    }
    
    func getFullTemplate() -> String {
        return templateHeader + (templateHeader.isEmpty ? "" : TemplateBean.HEADER_MARKER) + template
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

extension TemplateBean {
    private func handleHeader() {
        if let (header, tmpl) = TemplateBean.getItems(rawText: self.template) {
            self.templateHeader = header
            self.template = tmpl
        }
    }
    
    static func getItems(rawText: String) -> (String, String)? {
        if rawText.contains(HEADER_MARKER) {
            if let regex = try? NSRegularExpression(HEADER_MARKER) {
                let items = regex.splitn(rawText, 2)
                return (items[0], items[1])
            }
        }
        return nil
    }
}
