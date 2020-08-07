//
//  DefaultHeader.swift
//  AnyCodable
//
//  Created by Stan Stadelman on 3/18/20.
//

import Foundation

public struct DefaultHeader: Decodable, Hashable {
    public let type: String?
    public let title: String
    public let subTitle: String?
    public let actions: [Action]?
    public let icon: Icon?
    public let status: Status?
}

extension DefaultHeader: Equatable {
    public static func == (lhs: DefaultHeader, rhs: DefaultHeader) -> Bool {
        return lhs.type == rhs.type &&
            lhs.title == rhs.title &&
            lhs.subTitle == rhs.subTitle &&
            lhs.actions == rhs.actions &&
            lhs.icon == rhs.icon &&
            lhs.status == rhs.status
    }
}

extension DefaultHeader: Placeholding {
    public func replacingPlaceholders(withValuesIn object: Any) -> DefaultHeader {
        let _type        = type?.replacingPlaceholders(withValuesIn: object)
        let _title       = title.replacingPlaceholders(withValuesIn: object)
        let _subTitle    = subTitle?.replacingPlaceholders(withValuesIn: object)
        let _actions     = actions /// TODO:  implement replacingPlaceholders for `actions`
        let _icon        = icon?.replacingPlaceholders(withValuesIn: object)
        let _status      = status
        return DefaultHeader(type: _type, title: _title, subTitle: _subTitle, actions: _actions, icon: _icon, status: _status)
    }
}
