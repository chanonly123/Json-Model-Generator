//
//  ViewController.swift
//  JsonToModel
//
//  Created by Chandan on 05/11/18.
//  Copyright © 2018 Chandan. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTextViewDelegate {
    @IBOutlet var tvCode: NSTextView!
    @IBOutlet var tvJsonString: NSTextView!
    @IBOutlet var tfError: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        tvJsonString.delegate = self
        tvJsonString.isAutomaticQuoteSubstitutionEnabled = false
        tvJsonString.enabledTextCheckingTypes = 0

        tvJsonString.string =
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
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }

    var converter: Converter?
    func textDidChange(_ notification: Notification) {
        let text = tvJsonString.string
        processJson(jsonString: text, type: Gloss())
    }

    func processJson(jsonString: String, type: Moldable) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async { [weak self] in
            guard let `self` = self else { return }
            self.converter = Converter()
            self.converter?.convertToDictionary(text: jsonString, type: type, handler: { [weak self] text, error in
                guard let `self` = self else { return }
                print("Result generated")
                if let text = text {
                    self.tvCode.string = "\(text)"
                    self.tfError.isHidden = true
                    self.tvCode.isHidden = false
                } else if let error = error {
                    self.tfError.stringValue = error
                    self.tfError.isHidden = false
                    self.tvCode.isHidden = true
                }
            })
        }
    }
}

class Converter {
    private var queue: [[String: Any?]] = []
    private var classNames: [String] = []

    private var type: Moldable!
    private var handler: ((String?, String?) -> Void)?
    private var finalString: String = ""

    func convertToDictionary(text: String, type: Moldable, handler: @escaping ((String?, String?) -> Void)) {
        self.handler = handler
        self.type = type
        if let data = text.data(using: .utf8) {
            do {
                if let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    queue.append(dict)
                    dictToClass()
                } else {
                    callHandler(text: nil, error: "Error converting to Dictionary")
                }
            } catch {
                print(error.localizedDescription)
                callHandler(text: nil, error: error.localizedDescription)
            }
        } else {
            callHandler(text: nil, error: "Error converting to Data")
        }
    }

    private func dictToClass() {
        if let dict = queue.popLast() {
            let className = classNames.popLast() ?? "Root"
            var string = type.classLine(name: className) + newL
            for key in dict.keys {
                if let value = dict[key] {
                    if value is Int {
                        string += tab + type.varDecLine(name: key, type: "Int") + newL
                    } else if value is Double {
                        string += tab + type.varDecLine(name: key, type: "Double") + newL
                    } else if value is Bool {
                        string += tab + type.varDecLine(name: key, type: "Bool") + newL
                    } else if value is String {
                        string += tab + type.varDecLine(name: key, type: "String") + newL
                    } else if value is NSArray {
                        let array: NSArray = value as! NSArray
                        if array.filter({ $0 is Int }).count == array.count {
                            string += tab + type.varDecLine(name: key, type: "[Int]") + newL
                        } else if array.filter({ $0 is Double }).count == array.count {
                            string += tab + type.varDecLine(name: key, type: "[Double]") + newL
                        } else if array.filter({ $0 is Bool }).count == array.count {
                            string += tab + type.varDecLine(name: key, type: "[Bool]") + newL
                        } else if array.filter({ $0 is [String: Any?] }).count == array.count {
                            let className = key.toCamel
                            string += tab + type.varDecLine(name: key, type: "[\(className)]") + newL
                            queue.append(array.firstObject as! [String: Any?])
                            classNames.append(className)
                        } else {
                            string += tab + type.varDecLine(name: key, type: "[NSArray]") + newL
                        }
                    } else if value is [String: Any?] {
                        let className = key.toCamel
                        string += tab + type.varDecLine(name: key, type: "[\(className)]") + newL
                        queue.append(value as! [String: Any?])
                        classNames.append(className)
                    }
                }
            }

            if let funcLine = type.decodeFuncLine() {
                string += newL + tab + funcLine + newL
                for key in dict.keys {
                    string += tab + tab + type.decodeLine(name: key, key: key)! + newL
                }
                string += tab + "}" + newL // end of func
            }
            string += "}" + newL + newL // end of class
            finalString += string
        }
        if queue.count > 0 {
            dictToClass()
        } else {
            callHandler(text: finalString, error: nil)
        }
    }

    private func callHandler(text: String?, error: String?) {
        DispatchQueue.main.async { [weak self] in
            self?.handler?(text, error)
        }
    }

    let newL = "\n"
    let tab = "    "
}

extension String {
    var toCamel: String {
        return split(separator: "_").reduce(into: "", { $0 += $1.capitalized })
    }
}

protocol Moldable {
    func importLine() -> String
    func classLine(name: String) -> String
    func varDecLine(name: String, type: String) -> String
    func decodeFuncLine() -> String?
    func decodeLine(name: String, key: String) -> String?
    func encodeFuncLine() -> String?
    func encodeLine(name: String, key: String) -> String?
}
