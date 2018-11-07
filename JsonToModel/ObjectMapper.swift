//
//  ObjectMapper.swift
//  JsonToModel
//
//  Created by Chandan on 06/11/18.
//  Copyright © 2018 Chandan. All rights reserved.
//

import Foundation

class ObjectMapper: Moldable {
    func importLine() -> String {
        return "import ObjectMapper"
    }
    
    func classLine(name: String) -> String {
        return "class \(name): Mappable {"
    }
    
    func varDecLine(name: String, type: String) -> String {
        return "var \(name): \(type)?"
    }
    
    func decodeFuncLine() -> String? {
        return "func mapping(map: Map) {"
    }
    
    func decodeLine(name: String, key: String) -> String? {
        return "\(name) <- map[\"\(key)\"]"
    }
    
    func encodeFuncLine() -> String? {
        return nil
    }
    
    func encodeLine(name: String, key: String) -> String? {
        return nil
    }
}
