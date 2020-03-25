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
    @IBOutlet weak var popUpConverter: NSPopUpButton!
    
    let lexer = MyLexer()
    
    lazy var converter = TemplateConverter(t: arrConverterTypes[0], js: "")
    var caseTypeClass: CaseType = .upperCamel
    var caseTypeVar: CaseType = .camel
    
    let arrConverterTypes: [TemplateBean] = TemplateList.createInitialList()
    
    var selected: TemplateBean? {
        didSet {
            self.tvTemplateString.text = selected?.template ?? ""
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tvCode.delegate = self
        tvCode.scrollView.drawsBackground = true
        tvCode.theme = MyTheme()
        
        converter.completion = completion
        
        popUpConverter.removeAllItems()
        popUpConverter.addItems(withTitles: arrConverterTypes.map({ $0.name }))

        tvTemplateString.delegate = self
        tvTemplateString.scrollView.drawsBackground = true
        tvTemplateString.theme = MyTheme()
        
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
        
        selected = arrConverterTypes[0]
        processJson()
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
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
        guard let selected = self.selected else { return }
        let text = tvJsonString.text
        self.converter.caseTypeClass = self.caseTypeClass
        self.converter.caseTypeVar = self.caseTypeVar
        self.converter.jsonString = text
        self.converter.template = selected
        self.converter.template.template = tvTemplateString.text
        self.converter.convert()
    }
    
    @IBAction func converterTypeChanged(_ btn: NSPopUpButton) {
        selected = arrConverterTypes[btn.indexOfSelectedItem]
        processJson()
    }
}

extension ViewController: SyntaxTextViewDelegate {
    func didChangeText(_ syntaxTextView: SyntaxTextView) {
        if syntaxTextView === tvJsonString || syntaxTextView === tvTemplateString {
            processJson()
        }
    }
    
    func didChangeSelectedRange(_ syntaxTextView: SyntaxTextView, selectedRange: NSRange) {}
    
    func lexerForSource(_ source: String) -> Lexer {
        return lexer
    }
}
