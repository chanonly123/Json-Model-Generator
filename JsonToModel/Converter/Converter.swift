//
//  Converter.swift
//  JsonToModel
//
//  Created by Chandan on 07/11/18.
//  Copyright © 2018 Chandan. All rights reserved.
//

import Foundation

class Converter {
    private var queue: [[String: Any?]] = []
    private var classNames: [String] = []
    
    private var handler: ((String?, String?) -> Void)?
    private var finalString: String = ""
    
    var libType: Moldable = ObjectMapper()
    var rooClassName: String = "Root"
    var caseTypeClass: CaseType = .upperCamel
    var caseTypeVar: CaseType = .camel
    
    var infix = "_"
    var postfix = "-"
    
    func convertToDictionary(text: String, handler: @escaping ((String?, String?) -> Void)) {
        self.handler = handler
        if let data = text.data(using: .utf8) {
            do {
                if let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    queue.append(dict)
                    classNames.append(rooClassName)
                    dictToClass()
                } else {
                    callHandler(text: nil, error: "Error converting to Dictionary")
                }
            } catch {
                print(error.localizedDescription)
                callHandler(text: nil, error: error.localizedDescription)
            }
        } else {
            callHandler(text: nil, error: "Error converting to Data")
        }
    }
    
    private func dictToClass() {
        if let dict = queue.popLast() {
            let className = classNames.popLast()!
            var string = libType.classLine(name: className) + newL
            for key in dict.keys {
                if let value = dict[key] {
                    let varName = key.to(caseType: caseTypeVar)
                    if let nsNumber = value as? NSNumber {
                        switch nsNumber.getType() {
                        case "Bool":
                            string += tab + libType.varDecLine(name: varName, type: "Bool") + newL
                        case "Int":
                            string += tab + libType.varDecLine(name: varName, type: "Int") + newL
                        case "Double":
                            string += tab + libType.varDecLine(name: varName, type: "Double") + newL
                        default:
                            break
                        }
                    } else if value is String {
                        string += tab + libType.varDecLine(name: varName, type: "String") + newL
                    } else if value is NSArray {
                        let array: NSArray = value as! NSArray
                        if array.filter({ $0 is Int }).count == array.count {
                            string += tab + libType.varDecLine(name: varName, type: "[Int]") + newL
                        } else if array.filter({ $0 is Double }).count == array.count {
                            string += tab + libType.varDecLine(name: varName, type: "[Double]") + newL
                        } else if array.filter({ $0 is Bool }).count == array.count {
                            string += tab + libType.varDecLine(name: varName, type: "[Bool]") + newL
                        } else if array.filter({ $0 is [String: Any?] }).count == array.count {
                            let className = key.to(caseType: caseTypeClass)
                            string += tab + libType.varDecLine(name: varName, type: "[\(className)]") + newL
                            queue.append(array.firstObject as! [String: Any?])
                            classNames.append(className)
                        } else {
                            string += tab + libType.varDecLine(name: varName, type: "[NSArray]") + newL
                        }
                    } else if value is [String: Any?] {
                        let className = key.to(caseType: caseTypeClass)
                        string += tab + libType.varDecLine(name: varName, type: "\(className)") + newL
                        queue.append(value as! [String: Any?])
                        classNames.append(className)
                    }
                }
            }
            
            if let extra = libType.extraFunctionLine() {
                string += newL + tab + extra + newL
            }
            
            // decode function
            if let funcLine = libType.decodeFuncLine() {
                string += newL + tab + funcLine + newL
                for key in dict.keys {
                    let varName = key.to(caseType: caseTypeVar)
                    string += tab + tab + libType.decodeLine(name: varName, key: key)! + newL
                }
                string += tab + "}" + newL // end of func
            }
            
            // encode function
            if let funcLine = libType.encodeFuncLine() {
                string += newL + tab + funcLine + newL
                for key in dict.keys {
                    let varName = key.to(caseType: caseTypeVar)
                    string += tab + tab + libType.encodeLine(name: varName, key: key)! + newL
                }
                string += tab + (libType.encodeFuncEndLine() ?? "}") + newL // end of func
            }
            
            string += "}" + newL + newL // end of class
            finalString += string
        }
        if queue.count > 0 {
            dictToClass()
        } else {
            callHandler(text: finalString, error: nil)
        }
    }
    
    private func callHandler(text: String?, error: String?) {
        DispatchQueue.main.async { [weak self] in
            self?.handler?(text, error)
        }
    }
    
    let newL = "\n"
    let tab = "    "
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

extension String {
    func to(caseType: CaseType) -> String {
        switch caseType {
        case .upperCamel:
            return toCamelCaseCapFirst()
        case .camel:
            return toCamelCase()
        case .lowerSnake:
            return toSnakeCase(lowercase: true)
        case .snake:
            return toSnakeCase(lowercase: false)
        default:
            return self
        }
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.dropFirst()
    }
    
    func toCamelCaseCapFirst() -> String {
        return replacingOccurrences(of: "-", with: "_")
            .split(separator: "_").map({ String($0).capitalizingFirstLetter() }).joined()
    }
    
    func toCamelCase() -> String {
        var comps = replacingOccurrences(of: "-", with: "_").split(separator: "_")
        let first = comps.removeFirst()
        var last = comps.map({ return String($0).capitalizingFirstLetter() })
        last.insert(String(first), at: 0)
        return last.joined()
    }
    
    func toSnakeCase(lowercase: Bool) -> String {
        let pattern = "([a-z0-9])([A-Z])"
        
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: self.count)
        let str = regex?.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "$1_$2")
        if lowercase {
            return str?.lowercased() ?? self
        }
        return str?.split(separator: "_").map({ String($0).capitalizingFirstLetter() }).joined(separator: "_") ?? self
    }
}

protocol Moldable {
    func importLine() -> String
    
    func classLine(name: String) -> String
    
    func varDecLine(name: String, type: String) -> String
    
    func extraFunctionLine() -> String?
    
    func decodeFuncLine() -> String?
    func decodeLine(name: String, key: String) -> String?
    
    func encodeFuncLine() -> String?
    func encodeLine(name: String, key: String) -> String?
    func encodeFuncEndLine() -> String?
}

enum CaseType {
    case upperCamel, camel, snake, lowerSnake, none
}
