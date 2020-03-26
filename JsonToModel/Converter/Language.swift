//
//  Language.swift
//  JsonToModel
//
//  Created by Chandan Karmakar on 25/03/20.
//  Copyright © 2020 Chandan. All rights reserved.
//

import Foundation

enum LangaugeType: String, Codable {
    case Swift, Java, Kotlin
    
    var model: LanguageModel {
        switch self {
        case .Swift: return SwiftLanguage()
        case .Java: return JavaLanguage()
        case .Kotlin: return KotlinLanguage()
        }
    }
}

protocol LanguageModel {
    var bool: String { get }
    var int: String { get }
    var string: String { get }
    var double: String { get }
    var any: String { get }
    func array(type: String) -> String
}

class JavaLanguage: LanguageModel {
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

class SwiftLanguage: LanguageModel {
    var bool: String { return "Bool" }
    var int: String { return "Int" }
    var string: String { return "String" }
    var double: String { return "Double" }
    var any: String { return "Any" }
    func array(type: String) -> String {
        return "[\(type)]"
    }
}

class KotlinLanguage: LanguageModel {
    var bool: String { return "Boolean" }
    var int: String { return "Int" }
    var string: String { return "String" }
    var double: String { return "Double" }
    var any: String { return "Any" }
    func array(type: String) -> String {
        switch type {
        case "Boolean": return "BooleanArray"
        case "Int": return "IntArray"
        case "Double": return "DoubleArray"
        default: return "ArrayList<\(type)>"
        }
    }
}


