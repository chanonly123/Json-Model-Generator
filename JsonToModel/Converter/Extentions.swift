//
//  Converter.swift
//  JsonToModel
//
//  Created by Chandan on 07/11/18.
//  Copyright © 2018 Chandan. All rights reserved.
//

import Foundation

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

enum CaseType {
    case upperCamel, camel, snake, lowerSnake, none
}
