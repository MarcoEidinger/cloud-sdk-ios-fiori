import Foundation
import SourceryRuntime

// MARK: - Public API

public extension Type {
    /**
     Declares additional 'non-model' `ViewBuilder` generic types
     Follows list of `componentProperties.templateParameterDecls`
     ```
     struct AcmeComponent<Title: View, /* starts here => */ AcmeView: View, ...
     ```
     */
    var add_view_builder_paramsTemplateParameterDecls: [String] {
        resolvedAnnotations("add_view_builder_params").map { "\($0.capitalizingFirst()): View" }
    }
}

extension Type {
    func viewBuilderProperties(in context: [String: Type]) -> [(name: String, type: String)] {
        let componentProperties = flattenedComponentProperties(contextType: context).map { (name: $0.name, type: $0.name.capitalizingFirst()) }
        let addViewBuilderProperties = resolvedAnnotations("add_view_builder_params").map { (name: $0, type: $0.capitalizingFirst()) }
        return [componentProperties, addViewBuilderProperties].flatMap { $0 }
    }
}

public extension Type {
    var componentName: String {
        name.replacingOccurrences(of: "Model", with: "")
    }

    var componentNameAsPropertyDecl: String {
        self.componentName.lowercasingFirst()
    }

    func flattenedComponentProperties(contextType: [String: Type]) -> [Variable] {
        inheritedTypes.compactMap { contextType[$0] }.flatMap { $0.allVariables.reversed() }
    }

    // add_view_builder_params are no Swift properties and therefore `Variable` property values are faked and cannot be relied on other than `name`
    var addViewBuilderParamsAsVariables: [Variable] {
        self.resolvedAnnotations("add_view_builder_params").map {
            Variable(name: $0, typeName: TypeName("String?"), type: nil, accessLevel: (read: SourceryRuntime.AccessLevel.public, write: SourceryRuntime.AccessLevel.public), isComputed: false, isStatic: false, defaultValue: nil, attributes: [:], annotations: [:], definedInTypeName: nil)
        }
    }

    func resolvedAnnotations(_ name: String) -> [String] {
        if let string = self.annotations[name] as? String {
            return [string]
        } else if let array = self.annotations[name] as? [String] {
            return array
        } else {
            return []
        }
    }
    
    var add_view_builder_paramsViewBuilderPropertyDecls: [String] {
        self.resolvedAnnotations("add_view_builder_params")
            .map { "let _\($0): \($0.capitalizingFirst())" }
    }
    
    var add_view_builder_paramsViewBuilderInitParams: [String] {
        self.resolvedAnnotations("add_view_builder_params")
            .map { "@ViewBuilder \($0): @escaping () -> \($0.capitalizingFirst())" }
    }

    func add_view_builder_params_extensionInitParamWhereEmptyView(scenario: [Variable]) -> [String] {
        self.addViewBuilderParamsAsVariables.extensionInitParamWhereEmptyView(scenario: scenario)
    }

    var add_view_builder_paramsViewBuilderInitParamAssignment: [String] {
        self.resolvedAnnotations("add_view_builder_params")
            .map { "self._\($0) = \($0)()" }
    }

    func optionalPropertySequences(includingAddViewBuilderParams: Bool = true) -> [[Variable]] {
        var sequences: [[Variable]] = []
        var optionalProperties = self.allVariables.filter { $0.isRepresentableByView }.filter { $0.isOptional }
        if includingAddViewBuilderParams {
            optionalProperties.append(contentsOf: self.addViewBuilderParamsAsVariables)
        }
        guard optionalProperties.count > 0 else { return [] }
        for i in 1 ..< optionalProperties.count {
            sequences.append(contentsOf: optionalProperties.combinations(ofCount: i).map { $0 })
        }
        return sequences
    }
    
    var add_view_builder_paramsResolvedViewModifierChain: [String] {
        self.resolvedAnnotations("add_view_builder_params")
            .map {
                """
                var \($0): some View {
                        _\($0)
                    }
                """
            }
    }
    
    var add_view_builder_paramsExtensionModelInitParamsChaining: [String] {
        self.resolvedAnnotations("add_view_builder_params")
            .map { "\($0): \($0)" }
    }

    func add_view_builder_params_extensionInitParamAssignmentWhereEmptyView(scenario: [Variable]) -> [String] {
        self.addViewBuilderParamsAsVariables.extensionInitParamAssignmentWhereEmptyView(scenario: scenario)
    }
    
    var add_env_propsDecls: [String] {
        self.resolvedAnnotations("add_env_props")
            .map { "@Environment(\\.\($0)) var \($0)" }
    }

    func add_public_propsDecls(indent level: Int) -> String {
        self.resolvedAnnotations("add_public_props")
            .map { "public let \($0)" }.joined(separator: carriageRet(level))
    }

    // Not used when Style/Configuration is not adopted
    var componentStyleName: String {
        "\(self.componentName)tStyle"
    }

    // Not used when Style/Configuration is not adopted
    var componentStyleNameAsPropertyDecl: String {
        self.componentStyleName.lowercasingFirst()
    }

    // Not used when Style/Configuration is not adopted
    var stylePropertyDecl: String {
        "@Environment(\\.\(self.componentNameAsPropertyDecl)Style) var style: Any\(self.componentStyleName)"
    }

    // Not used when Style/Configuration is not adopted
    var componentStyleConfigurationName: String {
        "\(self.componentStyleName)Configuration"
    }

    // Not used when Style/Configuration is not adopted
    var fioriComponentStyleName: String {
        "Fiori\(self.componentStyleName)"
    }

    // Not used when Style/Configuration is not adopted
    var fioriLayoutRouterName: String {
        "Fiori\(self.componentName)LayoutRouter"
    }

//    public var usage: String {
//        "\(componentName) \(componentProperties.usage)"
//    }
//
//    public var acmeUsage: String {
//        "\(componentName) \(componentProperties.acmeUsage)"
//    }

    func fioriStyleImplEnumDecl(componentProperties: [Variable]) -> String {
        """
        extension Fiori {
            enum \(self.componentName) {
                \(componentProperties.typealiasViewModifierDecls)

                // TODO: - substitute type-specific ViewModifier for EmptyModifier
                /*
                    // replace `typealias Subtitle = EmptyModifier` with:

                    struct Subtitle: ViewModifier {
                        func body(content: Content) -> some View {
                            content
                                .font(.body)
                                .foregroundColor(.preferredColor(.primary3))
                        }
                    }
                */
                \(componentProperties.staticViewModifierPropertyDecls)
                \(componentProperties.staticViewModifierCumulativePropertyDecls)
            }
        }
        """
    }

    /// get methods of a type as variables (i.e. closures)
    internal var closureProperties: [Variable] {
        var closureProperties: [Variable] = []

        for method in self.methods {
            let name = "\(method.name.components(separatedBy: "(").first ?? method.selectorName)"

            let parameterListAsString: String = method.parameters.map { "\($0.typeName)" }.joined(separator: ",")
            let typeName = TypeName("((\(parameterListAsString)) -> \(method.returnTypeName))?")

            var convertionAnnotations = method.annotations
            convertionAnnotations["originalMethod"] = method

            let v = Variable(name: name, typeName: typeName, type: Type(), accessLevel: (read: SourceryRuntime.AccessLevel(rawValue: method.accessLevel)!, write: SourceryRuntime.AccessLevel(rawValue: method.accessLevel)!), isComputed: true, isStatic: method.isStatic, defaultValue: nil, attributes: [:], annotations: convertionAnnotations, definedInTypeName: method.definedInTypeName)
            closureProperties.append(v)
        }

        return closureProperties
    }

    internal func closureProperties(contextType: [String: Type]) -> [Variable] {
        inheritedTypes.compactMap { contextType[$0] }.flatMap { $0.allMethods }.map { (method) -> Variable in

            let name = "\(method.name.components(separatedBy: "(").first ?? method.selectorName)"

            let parameterListAsString: String = method.parameters.map { "\($0.typeName)" }.joined(separator: ",")
            let typeName = TypeName("((\(parameterListAsString)) -> \(method.returnTypeName))?")

            var convertionAnnotations = method.annotations
            convertionAnnotations["originalMethod"] = method

            return Variable(name: name, typeName: typeName, type: Type(), accessLevel: (read: SourceryRuntime.AccessLevel(rawValue: method.accessLevel)!, write: SourceryRuntime.AccessLevel(rawValue: method.accessLevel)!), isComputed: true, isStatic: method.isStatic, defaultValue: nil, attributes: [:], annotations: convertionAnnotations, definedInTypeName: method.definedInTypeName)
        }
    }
}

extension Type {
    var virtualPropertyDecls: [String] {
        let virtualProps: [String] = self.annotations.filter { $0.key.contains("virtualProp") }.map { $0.value as? String ?? "" }
        return virtualProps
    }
}

extension Type {
    /**
     Formatted assignments (single or multi property components) for initializer which takes optional content.

     Type to be expected of a ViewModel (e.g. ContactItemModel) conforming to primitive components (e.g. TitleComponent) or other ViewModels (e.g. ActivityItemsModel)

     Uses `ViewBuilder.buildEither` to account for nil content injected via this API
     ```
     init( /* ... */ ) { // starts here =>

        // primitive components
        self._title = { Text(title) }()
        self._subtitle = { subtitle != nil ?
            ViewBuilder.buildEither(first: Text(subtitle!)) :
            ViewBuilder.buildEither(second: EmptyView())
        }()

        // ..

        // composite components
        if (actionItems != nil || didSelectClosure != nil) {
            self._actionItems =  ViewBuilder.buildEither(first: ActivityItems(actionItems: actionItems,didSelectClosure: didSelectClosure))
        } else {
            self._actionItems = ViewBuilder.buildEither(second: EmptyView())
        }
     ```
     */
    var extensionModelInitParamsAssignments: [String] {
        var statements: [String] = []

        let context = ProcessInfo().context!
        let contextType = context.type
        let allTypes = context.types

        let inheritedTypeDefs = inheritedTypes.compactMap { contextType[$0] }.compactMap { $0 }
        let viewModelsWhichWillBeBacked = inheritedTypeDefs.filter { $0.annotations["backingComponent"] != nil || $0.inheritedTypes.inheritedTypes(contextType: contextType).containsAnnotation(name: "backingComponent") }
        let singlePropTypes = inheritedTypeDefs.filter { viewModelsWhichWillBeBacked.contains($0) == false }
        let props = singlePropTypes.flatMap { $0.allVariables }

        statements.append(contentsOf: props.extensionModelInitParamsAssignments)

        statements.append(contentsOf: self.extensionModelInitParamsAssignments(for: viewModelsWhichWillBeBacked, contextType: contextType, allTypes: allTypes))

        return statements
    }

    func extensionModelInitParamsAssignments(for viewModelsWhichWillBeBacked: [Type], contextType: [String: Type], allTypes: Types) -> [String] {
        var statements: [String] = []

        let componentTypesWhichWillBeBacked = viewModelsWhichWillBeBacked.map { (model) -> Type in
            allTypes.protocols.filter { $0.name == model.inheritedTypes.first! }.first!
        }

        let backingViewNames = componentTypesWhichWillBeBacked.map { $0.annotations["backingComponent"] as! String }

        for (idx, componentType) in componentTypesWhichWillBeBacked.enumerated() {
            guard let name = componentType.variables.first else { continue }

            let regularProperties = componentType.variables
            let closureProperties = componentType.closureProperties
            let properties = regularProperties + closureProperties
            let propertyNames = properties.map { $0.trimmedName }
            let nilCheckPropertyNames = properties.compactMap {
                ($0.isOptional || $0.annotations["bindingPropertyOptional"] != nil) && $0.annotations["no_nil_check"] == nil ?
                    $0.trimmedName : nil
            }

            let statement = ViewModelIntParamAssignmentOfViewModel(targetPropertyName: name.trimmedName, instantiatableModelName: viewModelsWhichWillBeBacked[idx].name, instantiatableViewName: backingViewNames[idx], initParameterNames: propertyNames, initParameterValues: propertyNames, nilCheckParameterNames: nilCheckPropertyNames)
            statements.append(statement.text)
        }

        return statements
    }
}

private struct ViewModelIntParamAssignmentOfViewModel {
    var targetPropertyName: String
    var instantiatableModelName: String
    var instantiatableViewName: String
    var initParameterNames: [String]
    var initParameterValues: [String]
    var nilCheckParameterNames: [String]

    var initParameters: String {
        var targets: [String] = []
        for (idx, param) in self.initParameterNames.enumerated() {
            targets.append("\(param): \(self.initParameterValues[idx])")
        }
        return targets.joined(separator: ",")
    }

    var methodArgumentsNilCheck: String {
        var targets: [String] = []
        for param in self.nilCheckParameterNames {
            targets.append("\(param) != nil")
        }
        return targets.joined(separator: " || ")
    }

    var text: String {
        """
        // handle \(self.instantiatableModelName)
                if (\(self.methodArgumentsNilCheck)) {
                    self._\(self.targetPropertyName) = ViewBuilder.buildEither(first: \(self.instantiatableViewName)(\(self.initParameters)))
                } else {
                    self._\(self.targetPropertyName) = ViewBuilder.buildEither(second: EmptyView())
                }
        """
    }
}

extension Array where Element: Type {
    func containsAnnotation(name: String) -> Bool {
        !self.filter { !$0.resolvedAnnotations(name).isEmpty }.isEmpty
    }
}

extension Array where Element == String {
    func inheritedTypes(contextType: [String: Type]) -> [Type] {
        self.compactMap { contextType[$0] }.compactMap { $0 }
    }
}

extension Type {
    var availableAttribute: String? {
        guard let content = resolvedAnnotations("availableAttributeContent").first else { return nil }
        return "@available(\(content))"
    }

    var isObservableObjectConform: Bool {
        let context = ProcessInfo().context!
        let contextType = context.type

        if inheritedTypes.contains("ObservableObject") {
            return true
        } else if inheritedTypes.count > 0 {
            let inheritedTypeDefs = inheritedTypes.compactMap { contextType[$0] }.compactMap { $0 }
            let results = inheritedTypeDefs.map { aType in
                aType.isObservableObjectConform
            }
            if results.contains(true) {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
}
