//
//  Highlighter.swift
//  JsonToModel
//
//  Created by Chandan on 07/11/18.
//  Copyright © 2018 Chandan. All rights reserved.
//

import Foundation
import SavannaKit

class MyLexer: Lexer {
    init() {}
    
    func getSavannaTokens(input: String) -> [Token] {
        var tokens = [MyToken]()
        input.enumerateSubstrings(in: input.startIndex..<input.endIndex, options: [.byWords]) { word, range, _, _ in
            if let word = word {
                let type = MyTokenType(word)
                let token = MyToken(type: type, isEditorPlaceholder: false, isPlain: false, range: range)
                tokens.append(token)
            }
        }
        return tokens
    }
}

enum MyTokenType {
    case keyword
    case type
    case normal
    
    init(_ str: String) {
        if MyTokenType.keywords.contains(str) {
            self = .keyword
        } else if MyTokenType.types.contains(str) {
            self = .type
        } else {
            self = .normal
        }
    }
    
    static let keywords: [String] = [
        "var", "class", "func", "struct", "let", "init", "required", "case", "enum", "self", "return", "public"
    ]
    
    static let types: [String] = [
        "Bool", "bool", "Int", "String", "Double", "int", "double", "void", "self", "class_name", "var_name", "var_type", "key", "Data", "CodingKey", "ArrayList", "List", "boolean", "dynamic", "sub_type"
    ]
}

struct MyToken: Token {
    let type: MyTokenType
    let isEditorPlaceholder: Bool
    let isPlain: Bool
    let range: Range<String.Index>
}

class MyTheme: SyntaxColorTheme {
    static let allFont = NSFont(name: "Menlo", size: 14)!
    let font = MyTheme.allFont
    let backgroundColor = Color.white
    let lineNumbersStyle: LineNumbersStyle? = LineNumbersStyle(font: MyTheme.allFont, textColor: lineNumbersColor)
    let gutterStyle: GutterStyle = GutterStyle(backgroundColor: Color.white, minimumWidth: 32)
    
    private static var lineNumbersColor: Color {
        return Color.lightGray
    }
    
    func globalAttributes() -> [NSAttributedStringKey: Any] {
        var attributes = [NSAttributedStringKey: Any]()
        attributes[.font] = MyTheme.allFont
        attributes[.foregroundColor] = Color.black
        return attributes
    }
    
    func attributes(for token: Token) -> [NSAttributedStringKey: Any] {
        guard let myToken = token as? MyToken else { return [:] }
        
        var attributes = [NSAttributedStringKey: Any]()
        
        switch myToken.type {
        case .keyword:
            attributes[.foregroundColor] = Color.red
        case .type:
            attributes[.foregroundColor] = Color.blue
        case .normal:
            attributes[.foregroundColor] = Color.black
        }
        
        return attributes
    }
}
