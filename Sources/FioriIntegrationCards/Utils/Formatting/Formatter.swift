import Foundation
import JavaScriptCore

/**
 A universal formatter being able to evaluate JavaScript function call to invoke formatters for currency, date and time, float, integer, percent and unit of measurement
 [List of formatters and expected data format](https://ui5.sap.com/test-resources/sap/ui/integration/demokit/cardExplorer/webapp/index.html#/learn/formatters) in integration cards documentation
 */
class Formatter {
    static let shared = Formatter()

    private var context = JSContext()
    private var resourceLoader = ResourceLoader()

    /// load a bundle for the formatters of the sap.ui.integration library of OpenUI5 into a JavaScriptContext
    private init() {
        guard let formatterResourcePath = Bundle.module.path(forResource: "formatter", ofType: "js") else {
            fatalError("Unable to read resource files.")
        }

        do {
            self.context?.setObject(ResourceLoader.self, forKeyedSubscript: "ResourceLoader" as NSString)
            let formatter = try String(contentsOfFile: formatterResourcePath, encoding: String.Encoding.utf8)
            _ = self.context?.evaluateScript(formatter)
        } catch (let error) {
            fatalError("Error while processing script file: \(error)")
        }
    }

    /**
     evaluates a JavaScript command to invoke one of the formatters in the format` namespace.
     See [here](https://ui5.sap.com/test-resources/sap/ui/integration/demokit/cardExplorer/webapp/index.html#/learn/formatters)  for more details

     ### Usage Example: ###
     ````
     print(Formatter.shared.execute(script: "format.percent(0.50)"))
     ````
    - Parameter script: representing an expression for a formatter available in the `format` namespace.
    - Returns: formatted value or 'undefined' in string format
    */

    func eval(script: String) -> String? {
        let result = self.context?.evaluateScript(script)
        return result?.toString()
    }
}

@objc protocol ResourceLoaderJS: JSExport {
    /// native function available in JavaScript
    /// - Parameter resourcePath: full-specified, e.g. resources/sap/ui/core/cldr/en.json
    static func loadAsset(_ resourcePath: String) -> String
}

/// native object available in JavaScript to load resources from bundle
fileprivate class ResourceLoader: NSObject, ResourceLoaderJS {
    static func loadAsset(_ resourcePath: String) -> String {
        do {
            guard let filename = resourcePath.components(separatedBy: ".").first?.components(separatedBy: "/").last else { return ""}
            guard let filetype = resourcePath.components(separatedBy: ".").last else { return ""}
            guard let resourcePath = Bundle.module.path(forResource: filename, ofType: filetype) else {
                fatalError("Unable to read resource files.")
            }
            let resource = try String(contentsOfFile: resourcePath, encoding: String.Encoding.utf8)
            return resource
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
