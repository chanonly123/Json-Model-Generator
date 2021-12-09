//
//  Language.swift
//  JsonToModel
//
//  Created by Chandan Karmakar on 25/03/20.
//  Copyright © 2020 Chandan. All rights reserved.
//

import Foundation

enum LangaugeType: String, Codable {
    case Swift, Java, Kotlin, Dart, CSharp, Python
    
    var model: LanguageModel {
        switch self {
        case .Swift: return SwiftLanguage()
        case .Java: return JavaLanguage()
        case .Kotlin: return KotlinLanguage()
        case .Dart: return DartLanguage()
        case .CSharp: return CSharpLanguage()
        case .Python: return PythonLanguage()
        }
    }
}

indirect enum VarTypes {
    case int, double, string, any, boolean, array(VarTypes), userDefined(String)
    var getGroup: DataTypes {
        switch self {
        case .int, .double, .string, .boolean:
            return .fundamental
        case .array(let type):
            switch type {
            case .userDefined(_): return .arrayDerived
            default: return .array
            }
        case .userDefined(_), .any:
            return .derived
        }
    }
    
}

protocol LanguageModel {
    var headerSpacer: Int { get }
    func get(type: VarTypes) -> String
}

extension LanguageModel {
    var headerSpacer: Int { return 1 }
    
    func subType(type: VarTypes) -> String {
        switch type {
        case .array(let type): return get(type: type)
        default: return ""
        }
    }
}

class JavaLanguage: LanguageModel {
    func get(type: VarTypes) -> String {
        switch type {
        case .int: return "int"
        case .boolean: return "bool"
        case .double: return "double"
        case .string: return "String"
        case .any: return "Object"
        case .array(let type):
            switch type {
            case .int: return "int[]"
            case .boolean: return "boolean[]"
            case .double: return "double[]"
            case .string: return "String[]"
            case .any: return "ArrayList<Object>"
            case .array(let type): return "ArrayList<" + get(type: type) + ">"
            case .userDefined(let type): return "ArrayList<" + type + ">"
            }
        case .userDefined(let type): return type
        }
    }
}

class SwiftLanguage: LanguageModel {
    func get(type: VarTypes) -> String {
        switch type {
        case .int: return "Int"
        case .boolean: return "Bool"
        case .double: return "Double"
        case .string: return "String"
        case .any: return "Any"
        case .array(let type): return "[" + get(type: type) + "]"
        case .userDefined(let type): return type
        }
    }
}

class DartLanguage: LanguageModel {
    func get(type: VarTypes) -> String {
        switch type {
        case .int: return "int"
        case .boolean: return "bool"
        case .double: return "double"
        case .string: return "String"
        case .any: return "Object"
        case .array(let type):
            switch type {
            case .int: return "List<int>"
            case .boolean: return "List<boolean>"
            case .double: return "List<double>"
            case .string: return "List<String>"
            case .any: return "<dynamic>"
            case .array(let type): return "List<" + get(type: type) + ">"
            case .userDefined(let type): return "List<" + type + ">"
            }
        case .userDefined(let type): return type
        }
    }
}

class KotlinLanguage: LanguageModel {
    func get(type: VarTypes) -> String {
        switch type {
        case .int: return "Int"
        case .boolean: return "Bool"
        case .double: return "Double"
        case .string: return "String"
        case .any: return "Any"
        case .userDefined(let type): return type
        case .array(let type): return "[" + get(type: type) + "]"
        }
    }
}

class CSharpLanguage: LanguageModel {
    func get(type: VarTypes) -> String {
        switch type {
        case .int: return "int"
        case .double: return "double"
        case .string: return "string"
        case .any: return "object"
        case .boolean: return "bool"
        case .userDefined(let utype): return utype
        case .array(let atype): return "List<\(get(type: atype))>"
        }
    }
}

class PythonLanguage: LanguageModel {
    var headerSpacer: Int { return 2 }
    
    func get(type: VarTypes) -> String {
        switch type {
        case .int: return "int"
        case .double: return "float"
        case .string: return "str"
        case .any: return "Any"
        case .boolean: return "bool"
        case .userDefined(let utype): return utype
        case .array(let atype): return "list[\(get(type: atype))]"
        }
    }
}
