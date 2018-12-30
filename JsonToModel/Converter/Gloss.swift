//
//  ObjectMapper.swift
//  JsonToModel
//
//  Created by Chandan on 06/11/18.
//  Copyright © 2018 Chandan. All rights reserved.
//

import Foundation

class Gloss: Moldable {

    func importLine() -> String {
        return "import Gloss"
    }
    
    func classLine(name: String) -> String {
        return "struct \(name): JSONDecodable {"
    }
    
    func varDecLine(name: String, type: String) -> String {
        return "let \(name): \(type)?"
    }
    
    func extraFunctionLine() -> String? {
        return nil
    }
    
    func decodeFuncLine() -> String? {
        return "init?(json: JSON) {"
    }
    
    func decodeLine(name: String, key: String) -> String? {
        return "\(name) = \"\(key)\" <~~ json"
    }
    
    func encodeFuncLine() -> String? {
        return "func toJSON() -> JSON? {\n        return jsonify(["
    }
    
    func encodeLine(name: String, key: String) -> String? {
        return "    \"\(key)\" ~~> \(name)"
    }
    
    func encodeFuncEndLine() -> String? {
        return "    ])\n    }"
    }
}
