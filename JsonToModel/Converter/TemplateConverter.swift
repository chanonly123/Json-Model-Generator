//
//  TemplateConerter.swift
//  JsonToModel
//
//  Created by Chandan Karmakar on 20/03/20.
//  Copyright © 2020 Chandan. All rights reserved.
//

import Foundation

class TemplateConverter {
    var template: TemplateBean
    var jsonString: String
    var completion: ((ConversionResult)->Void)?
    
    var caseTypeClass: CaseType = .none
    var caseTypeVar: CaseType = .none
    
    init(t: TemplateBean, js: String) {
        template = t
        jsonString = js
    }
    
    func convert() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let `self` = self else { return }
            if let data = self.jsonString.data(using: .utf8) {
                do {
                    if let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        let template = self.process(dict: dict)
                        let final = self.getString(mirror: template)
                        DispatchQueue.main.async {
                            self.completion?(ConversionResult.success(final))
                        }
                    } else {
                        self.failedCompletion(NSError(domain: "Error converting to Dictionary", code: 1))
                    }
                } catch {
                    self.failedCompletion(error)
                }
            } else {
                self.failedCompletion(NSError(domain: "Error converting to Data", code: 2))
            }
        }
    }
    
    func process(dict: [String: Any?]) -> MirrorModel {
        let mirror = MirrorModel()
        let lang: AnyLanguage = template.name.contains("Java") ? JavaLanguage() : SwiftLanguage()
        for key in dict.keys {
            guard let value = dict[key] else { continue }
            var varType: String
            
            if let nsNumber = value as? NSNumber {
                varType = nsNumber.getType(lang: lang)
            } else if value is String {
                varType = lang.string
            } else if let array = value as? NSArray {
                if array.filter({ $0 is Int }).count == array.count {
                    varType = lang.array(type: lang.int)
                } else if array.filter({ $0 is Double }).count == array.count {
                    varType = lang.array(type: lang.double)
                } else if array.filter({ $0 is Bool }).count == array.count {
                    varType = lang.array(type: lang.bool)
                } else if array.filter({ $0 is String }).count == array.count {
                    varType = lang.array(type: lang.string)
                } else if array.filter({ $0 is [String: Any?] }).count == array.count {
                    if let subDict = array.firstObject as? [String: Any?] {
                        let sub = process(dict: subDict)
                        sub.className = key.to(caseType: caseTypeClass)
                        mirror.sub.append(sub)
                    }
                    varType = lang.array(type: key.to(caseType: caseTypeClass))
                } else {
                    varType = lang.array(type: lang.any)
                }
            } else if let subDict = value as? [String: Any?] {
                let sub = process(dict: subDict)
                sub.className = key.to(caseType: caseTypeClass)
                mirror.sub.append(sub)
                varType = sub.className
            } else {
                varType = lang.any
            }
            
            mirror.key.append(key)
            mirror.varName.append(key.to(caseType: caseTypeVar))
            mirror.varType.append(varType)
        }
        return mirror
    }
    
    func getString(mirror: MirrorModel) -> String {
        var subs = mirror.sub.map { getString(mirror: $0) }
        subs.insert(mirror.toString(template: template.template), at: 0)
        return subs.joined(separator: "\n\n")
    }
    
    func failedCompletion(_ error: Error) {
        DispatchQueue.main.async {
            self.completion?(ConversionResult.failed(error))
        }
    }
}

class MirrorModel {
    var className: String = "Root"
    var varName: [String] = []
    var varType: [String] = []
    var key: [String] = []
    
    var sub: [MirrorModel] = []
    
    func toString(template: String) -> String {
        var template = template.replacingOccurrences(of: "\t", with: "    ")
        while true {
            guard let start = template.range(of: "<loop>"),
                let end = template.range(of: "</loop>") else { break }
            let line = template[start.upperBound..<end.lowerBound]
            
            var lineStartIndex = template.index(before: start.lowerBound)
            var indentSpaceCount = 0
            while template[lineStartIndex] == " " {
                lineStartIndex = template.index(before: lineStartIndex)
                indentSpaceCount += 1
            }
            
            var loopsString = "\n"
            for i in 0..<varName.count {
                let newLine = line.replacingOccurrences(of: "\(tVarName)", with: "\(varName[i])")
                    .replacingOccurrences(of: "\(tVarType)", with: "\(varType[i])")
                    .replacingOccurrences(of: "\(tKey)", with: "\(key[i])")
                
                loopsString += "\(String(repeating: " ", count: indentSpaceCount))\(newLine)"
                if i < varName.count - 1 {
                    loopsString += "\n"
                }
            }
            if loopsString.last == "," {
                loopsString.removeLast()
            }
            template.replaceSubrange(lineStartIndex..<end.upperBound, with: loopsString)
        }
        return template.replacingOccurrences(of: "\(tClassName)", with: className)
    }
    
    let tClassName = "{class_name}"
    let tVarName = "{var_name}"
    let tVarType = "{var_type}"
    let tKey = "{key}"
}

enum ConversionResult {
    case success(String), failed(Error)
}

extension NSNumber {
    func getType(lang: AnyLanguage) -> String {
        switch CFGetTypeID(self as CFTypeRef) {
        case CFBooleanGetTypeID():
            return lang.bool
        case CFNumberGetTypeID():
            switch CFNumberGetType(self as CFNumber) {
            case .sInt8Type,.sInt16Type, .sInt32Type, .sInt64Type:
                return lang.int
            case .doubleType:
                return lang.double
            default:
                return lang.double
            }
        default:
            return lang.any
        }
    }
}

extension Data {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return  nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}

extension String {
    var html2AttributedString: NSAttributedString? {
        return Data(utf8).html2AttributedString
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}

class JavaLanguage: AnyLanguage {
    var bool: String { return "boolean" }
    var int: String { return "int" }
    var string: String { return "String" }
    var double: String { return "double" }
    var any: String { return "Object" }
    func array(type: String) -> String {
        switch type {
        case "boolean": return "boolean[]"
        case "int": return "int[]"
        case "double": return "double[]"
        default: return "ArrayList<\(type)>"
        }
    }
}

class SwiftLanguage: AnyLanguage {
    var bool: String { return "Bool" }
    var int: String { return "Int" }
    var string: String { return "String" }
    var double: String { return "Double" }
    var any: String { return "Any" }
    func array(type: String) -> String {
        return "[\(type)]"
    }
}

protocol AnyLanguage {
    var bool: String { get }
    var int: String { get }
    var string: String { get }
    var double: String { get }
    var any: String { get }
    func array(type: String) -> String
}


