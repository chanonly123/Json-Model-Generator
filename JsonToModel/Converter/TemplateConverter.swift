//
//  TemplateConerter.swift
//  JsonToModel
//
//  Created by Chandan Karmakar on 20/03/20.
//  Copyright © 2020 Chandan. All rights reserved.
//

import Foundation

class TemplateConverter {
    var template: String
    var jsonString: String
    var completion: ((ConversionResult)->Void)?
    
    var caseTypeClass: CaseType = .none
    var caseTypeVar: CaseType = .none
    
    init(t: String, js: String) {
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
        for key in dict.keys {
            guard let value = dict[key] else { continue }
            var varType: String
            
            if let nsNumber = value as? NSNumber {
                varType = nsNumber.getType()
            } else if value is String {
                varType = "String"
            } else if let array = value as? NSArray {
                if array.filter({ $0 is Int }).count == array.count {
                    varType = "[Int]"
                } else if array.filter({ $0 is Double }).count == array.count {
                    varType = "[Double]"
                } else if array.filter({ $0 is Bool }).count == array.count {
                    varType = "[Bool]"
                } else if array.filter({ $0 is String }).count == array.count {
                    varType = "[String]"
                } else if array.filter({ $0 is [String: Any?] }).count == array.count {
                    if let subDict = array.firstObject as? [String: Any?] {
                        let sub = process(dict: subDict)
                        sub.className = key.to(caseType: caseTypeClass)
                        mirror.sub.append(sub)
                    }
                    varType = key.to(caseType: caseTypeClass)
                } else {
                    varType = "NSArray"
                }
            } else if let subDict = value as? [String: Any?] {
                let sub = process(dict: subDict)
                sub.className = key.to(caseType: caseTypeClass)
                mirror.sub.append(sub)
                varType = sub.className
            } else {
                varType = "Any"
            }
            
            mirror.key.append(key)
            mirror.varName.append(key.to(caseType: caseTypeVar))
            mirror.varType.append(varType)
        }
        return mirror
    }
    
    func getString(mirror: MirrorModel) -> String {
        var subs = mirror.sub.map { getString(mirror: $0) }
        subs.insert(mirror.toString(template: template), at: 0)
        return subs.joined(separator: "\n\n")
    }
    
    func failedCompletion(_ error: Error) {
        DispatchQueue.main.async {
            self.completion?(ConversionResult.failed(error))
        }
    }
}

class MirrorModel {
    //var classType: String = ""
    var className: String = "Root"
    var varName: [String] = []
    var varType: [String] = []
    var key: [String] = []
    
    var sub: [MirrorModel] = []
    
    func toString(template: String) -> String {
        var template = template
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
                let newLine = line.replacingOccurrences(of: "{\(tVarName)}", with: "\(varName[i])")
                    .replacingOccurrences(of: "{\(tVarType)}", with: "\(varType[i])")
                    .replacingOccurrences(of: "{\(tKey)}", with: "\(key[i])")
                
                loopsString += "\(String(repeating: " ", count: indentSpaceCount)) \(newLine)"
                if i < varName.count - 1 {
                    loopsString += "\n"
                }
            }
            template.replaceSubrange(lineStartIndex..<end.upperBound, with: loopsString)
        }
        return template.replacingOccurrences(of: "{\(tClassName)}", with: className)
    }
    
    //let tClassType = "class_type"
    let tClassName = "class_name"
    let tVarName = "var_name"
    let tVarType = "var_type"
    let tKey = "key"
}

enum ConversionResult {
    case success(String), failed(Error)
}

extension NSNumber {
    func getType() -> String {
        switch CFGetTypeID(self as CFTypeRef) {
        case CFBooleanGetTypeID():
            return "Bool"
        case CFNumberGetTypeID():
            switch CFNumberGetType(self as CFNumber) {
            case .sInt8Type:
                return "Int"
            case .sInt16Type:
                return "Int"
            case .sInt32Type:
                return "Int"
            case .sInt64Type:
                return "Int"
            case .doubleType:
                return "Double"
            default:
                return "Double"
            }
        default:
            return "NSNumber"
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
