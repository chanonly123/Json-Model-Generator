//
//  ViewController.swift
//  JsonToModel
//
//  Created by Chandan on 05/11/18.
//  Copyright © 2018 Chandan. All rights reserved.
//

import Cocoa
import SavannaKit

class ViewController: NSViewController {
    @IBOutlet var tvCode: SyntaxTextView!
    @IBOutlet var tvJsonString: SyntaxTextView!
    @IBOutlet var tvTemplateString: SyntaxTextView!
    @IBOutlet var tfError: NSTextField!
    @IBOutlet var cbType: NSComboBox!
    
    let lexer = MyLexer()
    
    var converter = TemplateConverter(t: "", js: "")
    var caseTypeClass: CaseType = .upperCamel
    var caseTypeVar: CaseType = .camel
    var converterType: Moldable = ObjectMapper()
    
    let arrConverterTypes: [ConverterType] = [.objMapper, .gloss]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tvCode.delegate = self
        tvCode.scrollView.drawsBackground = true
        tvCode.theme = MyTheme()
        
        converter.completion = completion
        
        tvJsonString.delegate = self
        tvJsonString.scrollView.drawsBackground = true
        tvJsonString.theme = MyTheme()
        tvJsonString.text =
            """
                    {
                    "success": true,
                    "data": {
                    "voice_opinions": [
                    {
                    "createdAt": 1541413168000,
                    "updateAt": 1541413168000,
                    "id": 246,
                    "unique_id": "uo-5edc608309257fde",
                    "user_id": 614,
                    "hot_topic_id": 8,
                    "vote": 0,
                    "audio_id": 234,
                    "status": 1,
                    "counter_opinions": [
                    {
                    "createdAt": 1541413168000,
                    "updateAt": 1541413168000,
                    "id": 246,
                    "unique_id": "uo-5edc608309257fde",
                    "user_id": 614,
                    "hot_topic_id": 8,
                    "vote": 0,
                    "audio_id": 234,
                    "status": 1
                    }
                    ]
                    }
                    ]
                    },
                    "code": 200
                    }
            """
        
        tvTemplateString.text = """
class {class_name} {

    <loop>var {var_name}: {var_type}</loop>

    required init?(map: Map) {}
    
    func mapping(map: Map) {
        <loop>{var_name} <- map["{key}"]</loop>
    }
}
"""
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    func processJson(jsonString: String, type: Moldable) {
        self.converter.caseTypeClass = self.caseTypeClass
        self.converter.caseTypeVar = self.caseTypeVar
        self.converter.jsonString = jsonString
        self.converter.template = tvTemplateString.text
        //self.converter.libType = type
        /*self.converter.rooClassName = self.classRoot
        self.converter.classPrefix = self.classPrefix
        self.converter.classSuffix = self.classSuffix
        self.converter.varPrefix = self.varPrefix
        self.converter.varSuffix = self.varSuffix*/
        self.converter.convert()
    }
    
    var processIndex = 0
    lazy var completion: ((ConversionResult)->Void) = { [weak self, index = processIndex] result in
        guard let `self` = self, self.processIndex == index else { return }
        switch result {
        case .success(let text):
            self.tvCode.text = "\(text)"
            self.tfError.isHidden = true
            self.tvCode.isHidden = false
        case .failed(let error):
            self.tfError.stringValue = error.localizedDescription
            self.tfError.isHidden = false
            self.tvCode.isHidden = true
        }
    }
    
    @IBAction func radioClassChanged(_ sender: NSButton) {
        sender.state = .on
        sender.superview?.subviews.filter({ $0 !== sender }).forEach({ ($0 as? NSButton)?.state = .off })
        if sender.tag == 0 {
            caseTypeClass = .none
        } else if sender.tag == 1 {
            caseTypeClass = .upperCamel
        } else if sender.tag == 2 {
            caseTypeClass = .lowerSnake
        }
        processJson()
    }
    
    @IBAction func radioVarChanged(_ sender: NSButton) {
        sender.state = .on
        sender.superview?.subviews.filter({ $0 !== sender }).forEach({ ($0 as? NSButton)?.state = .off })
        if sender.tag == 0 {
            caseTypeVar = .none
        } else if sender.tag == 1 {
            caseTypeVar = .camel
        } else if sender.tag == 2 {
            caseTypeVar = .lowerSnake
        }
        processJson()
    }
        
    func processJson() {
        let text = tvJsonString.text
        processJson(jsonString: text, type: converterType)
    }
    
    @IBAction func actionTypeChange() {
        
    }
}

extension ViewController: SyntaxTextViewDelegate {
    func didChangeText(_ syntaxTextView: SyntaxTextView) {
        if syntaxTextView === tvJsonString {
            processJson()
        }
    }
    
    func didChangeSelectedRange(_ syntaxTextView: SyntaxTextView, selectedRange: NSRange) {
    }
    
    func lexerForSource(_ source: String) -> Lexer {
        return lexer
    }
}

enum ConverterType: String {
    case objMapper = "Objective Mapper", gloss = "Gloss"
    var converter: Moldable {
        switch self {
        case .objMapper:
            return ObjectMapper()
        case .gloss:
            return Gloss()
        }
    }
}
