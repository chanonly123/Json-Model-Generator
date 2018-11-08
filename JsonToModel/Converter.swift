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
                    if type(of: value) == type(of: NSNumber(value: true)) {
                        string += tab + libType.varDecLine(name: key, type: "Bool") + newL
                    } else if value is Int {
                        string += tab + libType.varDecLine(name: key, type: "Int") + newL
                    } else if value is Double {
                        string += tab + libType.varDecLine(name: key, type: "Double") + newL
                    } else if value is String {
                        string += tab + libType.varDecLine(name: key, type: "String") + newL
                    } else if value is NSArray {
                        let array: NSArray = value as! NSArray
                        if array.filter({ $0 is Int }).count == array.count {
                            string += tab + libType.varDecLine(name: key, type: "[Int]") + newL
                        } else if array.filter({ $0 is Double }).count == array.count {
                            string += tab + libType.varDecLine(name: key, type: "[Double]") + newL
                        } else if array.filter({ $0 is Bool }).count == array.count {
                            string += tab + libType.varDecLine(name: key, type: "[Bool]") + newL
                        } else if array.filter({ $0 is [String: Any?] }).count == array.count {
                            let className = key.toCamel
                            string += tab + libType.varDecLine(name: key, type: "[\(className)]") + newL
                            queue.append(array.firstObject as! [String: Any?])
                            classNames.append(className)
                        } else {
                            string += tab + libType.varDecLine(name: key, type: "[NSArray]") + newL
                        }
                    } else if value is [String: Any?] {
                        let className = key.toCamel
                        string += tab + libType.varDecLine(name: key, type: "[\(className)]") + newL
                        queue.append(value as! [String: Any?])
                        classNames.append(className)
                    }
                }
            }
            
            // decode function
            if let funcLine = libType.decodeFuncLine() {
                string += newL + tab + funcLine + newL
                for key in dict.keys {
                    string += tab + tab + libType.decodeLine(name: key, key: key)! + newL
                }
                string += tab + "}" + newL // end of func
            }
            
            // encode function
            if let funcLine = libType.encodeFuncLine() {
                string += newL + tab + funcLine + newL
                for key in dict.keys {
                    string += tab + tab + libType.encodeLine(name: key, key: key)! + newL
                }
                string += tab + "}" + newL // end of func
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

extension String {
    var toCamel: String {
        return split(separator: "_").reduce(into: "", { $0 += $1.capitalized })
    }
}

protocol Moldable {
    func importLine() -> String
    func classLine(name: String) -> String
    func varDecLine(name: String, type: String) -> String
    func decodeFuncLine() -> String?
    func decodeLine(name: String, key: String) -> String?
    func encodeFuncLine() -> String?
    func encodeLine(name: String, key: String) -> String?
}
