//
//  ViewController.swift
//  JSONModelGenerator
//
//  Created by Evgeniy on 27.04.18.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import Cocoa

public typealias JSONObject = [String: Any]

public enum ElementType {
    case string(String)
}

public final class WorkerNew {

    // MARK: - Interface

    public func parse(_ object: JSONObject) -> [String] {
        var properties: [String] = []

        for key in object.keys {
            let element = object[key]!

            let property = parse(element: element, name: key)
            properties.append(property)
        }

        return properties
    }

    // MARK: - Internal

    private func parse(element: Any, name: String) -> String {
        if element is String {
            return makeString(for: name)
        }
        if element is [Any] {
            return makeArray(element as! [Any], for: name)
        }

        return "not yet! [\(name)]"
    }

    private func makeArray(_ array: [Any], for name: String) -> String {
        guard !array.isEmpty else { return makeEmptyArray(for: name) }
        let element = array[0]

        if element is JSONObject {
            let model = parse(element as! JSONObject)
            log.debug(model)
        }

        return "array not yet!"
    }

    private func makeEmptyArray(for name: String) -> String {
        return "let \(name): [Any]"
    }

    private func makeString(for name: String) -> String {
        return "let \(name): String"
    }
}

public final class Worker {

    // MARK: - Interface

    // TODO: parse tries parse object, then parseArray

    public func parse() {
        let path = "file://" + FileManager.default.currentDirectoryPath + "/Model.json"
        guard let url = URL(string: path),
            let content = try? Data(contentsOf: url),
            let object = try? JSONSerialization.jsonObject(with: content, options: []),
            let json = object as? JSONObject else { return }

        let w = WorkerNew()
        w.parse(json)
        return;

        var properties: [String] = []

        for key in json.keys {
            let element = json[key]!
            let type = process(element)
            let property = buildProperty(name: key, type: type)

            properties.append(property)
        }

        log.debug(properties)
    }

    // MARK: - Internal

    private func buildProperty(name: String, type: String) -> String {
        return "let \(name): \(type)"
    }

    private func process(_ element: Any) -> String {
        if element is Array<Any> {
            return processArray(element as! [Any])
        }
        if element is String {
            return processString(element as! String)
        }

        return "unknown"
    }

    private func processArray(_ array: Array<Any>) -> String {
        if array.isEmpty {
            let returnType = [Any].self
            log.debug("return - \(returnType)")

            return "\(returnType)"
        }
        let element = array[0]

        if element is JSONObject {
            processArrayObject(element as! JSONObject)
        }

        return "unknown"
    }

    private func processArrayObject(_ object: JSONObject) {
        for key in object.keys {
            let element = object[key]
            let t = element as? Int
        }
    }

    private func processString(_ str: String) -> String {
        return "\(String.self)"
    }
}

final class ViewController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        testWorker()
    }

    private func testWorker() {
        let worker = Worker()
        worker.parse()
    }
}
