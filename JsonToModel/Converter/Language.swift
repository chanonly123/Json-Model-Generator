//
//  Language.swift
//  JsonToModel
//
//  Created by Chandan Karmakar on 25/03/20.
//  Copyright © 2020 Chandan. All rights reserved.
//

import Foundation

enum LangaugeType: String, Codable {
    case Swift, Java, Kotlin, Dart
    
    var model: LanguageModel {
        switch self {
        case .Swift: return SwiftLanguage()
        case .Java: return JavaLanguage()
        case .Kotlin: return KotlinLanguage()
        case .Dart: return DartLanguage()
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
    func get(type: VarTypes) -> String
}

extension LanguageModel {
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
