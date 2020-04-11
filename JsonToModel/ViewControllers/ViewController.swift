//
//  ViewController.swift
//  JsonToModel
//
//  Created by Chandan on 05/11/18.
//  Copyright © 2018 Chandan. All rights reserved.
//

import Cocoa
import SavannaKit

class ViewController: NSViewController, NSWindowDelegate {
    @IBOutlet var tvCode: SyntaxTextView!
    @IBOutlet var tvJsonString: SyntaxTextView!
    @IBOutlet var tvTemplateString: SyntaxTextView!
    @IBOutlet var tfError: NSTextField!
    @IBOutlet weak var popUpConverter: NSPopUpButton!
    @IBOutlet weak var btnEdit: NSButton!
    @IBOutlet weak var segVarname: NSSegmentedControl!
    
    weak static var viewc: ViewController?
    
    static let lexer = MyLexer()
    
    lazy var converter = TemplateConverter(t: TemplateBean(n: "", t: "", l: .Swift, isUser: false), js: "")
    var caseTypeClass: CaseType = .upperCamel
    var caseTypeVar: CaseType = .camel
    
    let systemTypes: [TemplateBean] = TemplateList.createInitialList()
    var allTypes: [TemplateBean] = []
    
    var selected: TemplateBean? {
        didSet {
            self.tvTemplateString.text = (selected?.template ?? "")
            self.btnEdit.isHidden = !(selected?.isUser ?? false)
        }
    }
    
    lazy var appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ViewController.viewc = self
    
        tvCode.delegate = self
        tvCode.scrollView.drawsBackground = true
        tvCode.theme = MyTheme()
        
        converter.completion = completion
        
        segVarname.selectedSegment = 1
        
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
        
        reloadTemplates()
        processJson()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.delegate = self
        view.window?.title = "JSON to Model (v\(appVersion ?? "-"))"
    }
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        NSApplication.shared.terminate(self)
        return true
    }
    
    func reloadTemplates(select: Int = 0) {
        var fromUser = LocalVars.savedTemplates?.list ?? []
        fromUser.sort(by: { $0.date < $1.date })
        allTypes.removeAll()
        allTypes.insert(contentsOf: systemTypes, at: 0)
        allTypes.insert(contentsOf: fromUser, at: 0)
        
        popUpConverter.removeAllItems()
        popUpConverter.addItems(withTitles: allTypes.map({ "\($0.name) | \($0.language.rawValue)\($0.isUser ? " | User" : "")" }))
        popUpConverter.selectItem(at: select)
        selected = allTypes[select]
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
        
    func processJson() {
        guard let selected = self.selected else { return }
        let text = tvJsonString.text
        self.converter.caseTypeClass = self.caseTypeClass
        self.converter.caseTypeVar = self.caseTypeVar
        self.converter.template = selected
        self.converter.jsonString = text
        self.converter.templateString = tvTemplateString.text
        self.converter.convert()
    }
    
    @IBAction func converterTypeChanged(_ btn: NSPopUpButton) {
        selected = allTypes[popUpConverter.indexOfSelectedItem]
        processJson()
    }

    @IBAction func actionHelp(_ sender: Any) {
        if let viewc = storyboard?.instantiateController(withIdentifier: .init("HelpVC")) as? HelpVC {
            presentViewControllerAsModalWindow(viewc)
        }
    }
    
    @IBAction func actionNewTemplate(_ sender: Any) {
        if let viewc = storyboard?.instantiateController(withIdentifier: .init("NewTemplateVC")) as? NewTemplateVC {
            viewc.didCreate = { [weak self] in
                self?.reloadTemplates()
            }
            presentViewControllerAsSheet(viewc)
        }
    }
    
    @IBAction func actionEdit(_ sender: Any) {
        if let viewc = storyboard?.instantiateController(withIdentifier: .init("NewTemplateVC")) as? NewTemplateVC {
            let selectedIndex = popUpConverter.indexOfSelectedItem
            viewc.inputTemplate = selected
            viewc.didUpdate = { [weak self] in
                self?.reloadTemplates(select: selectedIndex)
            }
            viewc.didDelete = { [weak self] in
                self?.reloadTemplates()
            }
            presentViewControllerAsSheet(viewc)
        }
    }
    
    @IBAction func actionSegChange(_ sender: Any) {
        switch segVarname.selectedSegment {
        case 0: caseTypeVar = .none
        case 1: caseTypeVar = .camel
        case 2: caseTypeVar = .lowerSnake
        default: break
        }
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
        return ViewController.lexer
    }
}
