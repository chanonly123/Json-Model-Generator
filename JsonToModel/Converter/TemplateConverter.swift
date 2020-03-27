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
    var templateString: String = ""
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
        let mirror = MirrorModel(template.language.model)
        for key in dict.keys {
            guard let value = dict[key] else { continue }
            var varType: VarTypes
            
            if let nsNumber = value as? NSNumber {
                varType = nsNumber.getType()
            } else if value is String {
                varType = .string
            } else if let array = value as? NSArray {
                if array.filter({ $0 is Int }).count == array.count {
                    varType = .array(.int)
                } else if array.filter({ $0 is Double }).count == array.count {
                    varType = .array(.double)
                } else if array.filter({ $0 is Bool }).count == array.count {
                    varType = .array(.boolean)
                } else if array.filter({ $0 is String }).count == array.count {
                    varType = .array(.string)
                } else if array.filter({ $0 is [String: Any?] }).count == array.count {
                    if let subDict = array.firstObject as? [String: Any?] {
                        let sub = process(dict: subDict)
                        sub.className = key.to(caseType: caseTypeClass)
                        mirror.sub.append(sub)
                    }
                    varType = .array(.userDefined(key.to(caseType: caseTypeClass)))
                } else {
                    varType = .array(.any)
                }
            } else if let subDict = value as? [String: Any?] {
                let sub = process(dict: subDict)
                sub.className = key.to(caseType: caseTypeClass)
                mirror.sub.append(sub)
                varType = .userDefined(sub.className)
            } else {
                varType = .any
            }
            
            mirror.key.append(key)
            mirror.varName.append(key.to(caseType: caseTypeVar))
            mirror.varType.append(varType)
        }
        return mirror
    }
    
    func getString(mirror: MirrorModel) -> String {
        var subs = mirror.sub.map { getString(mirror: $0) }
        subs.insert(mirror.toString(template: templateString), at: 0)
        return subs.joined(separator: "\n\n")
    }
    
    func failedCompletion(_ error: Error) {
        DispatchQueue.main.async {
            self.completion?(ConversionResult.failed(error))
        }
    }
}

enum DataTypes: String {
    case all = "loop", fundamental, derived, array
}

class MirrorModel {
    let lang: LanguageModel
    
    var className: String = "Root"
    var varName: [String] = []
    var varType: [VarTypes] = []
    var key: [String] = []
    
    var sub: [MirrorModel] = []

    init(_ l: LanguageModel) {
        lang = l
    }
    
    func toString(template: String) -> String {
        var template = template.replacingOccurrences(of: "\t", with: "    ")
        
        replaceLoops(dataType: DataTypes.all, template: &template)
        replaceLoops(dataType: DataTypes.fundamental, template: &template)
        replaceLoops(dataType: DataTypes.derived, template: &template)
        replaceLoops(dataType: DataTypes.array, template: &template)
        
        return template.replacingOccurrences(of: "\(tClassName)", with: className)
    }
    
    func replaceLoops(dataType: DataTypes, template: inout String) {
        let loopType = dataType.rawValue
        while true {
            guard let start = template.range(of: "<\(loopType)>"),
                let end = template.range(of: "</\(loopType)>"),
                start.upperBound < end.lowerBound
                else { break }
            
            
            let line = template[start.upperBound..<end.lowerBound]
            
            var lineStartIndex = template.index(before: start.lowerBound)
            var indentSpaceCount = 0
            while template[lineStartIndex] == " " {
                lineStartIndex = template.index(before: lineStartIndex)
                indentSpaceCount += 1
            }
                        
            var loopsString = ""
            for i in 0..<varName.count {
                let type = self.varType[i]
                if dataType == .all || type.getGroup == dataType {
                    let varType = lang.get(type: type)
                    let newLine = line.replacingOccurrences(of: "\(tVarName)", with: "\(varName[i])")
                        .replacingOccurrences(of: "\(tVarType)", with: "\(varType)")
                        .replacingOccurrences(of: "\(tKey)", with: "\(key[i])")
                    
                    loopsString += "\(String(repeating: " ", count: indentSpaceCount))\(newLine)"
                }
            }
            if let firstNewLine = loopsString.firstIndex(where: { $0 == "\n" }) {
                loopsString.replaceSubrange(loopsString.startIndex...firstNewLine, with: "")
            }
            if let lastCommaIndex = loopsString.lastIndex(where: { $0 == "," })  {
                loopsString.remove(at: lastCommaIndex)
            }
            
            template.replaceSubrange(template.index(after: lineStartIndex)..<end.upperBound, with: loopsString)
        }
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
    func getType() -> VarTypes {
        switch CFGetTypeID(self as CFTypeRef) {
        case CFBooleanGetTypeID():
            return .boolean
        case CFNumberGetTypeID():
            switch CFNumberGetType(self as CFNumber) {
            case .sInt8Type,.sInt16Type, .sInt32Type, .sInt64Type:
                return .int
            case .doubleType:
                return .double
            default:
                return .double
            }
        default:
            return .any
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
