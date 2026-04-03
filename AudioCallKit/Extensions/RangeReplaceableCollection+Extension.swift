//
//  Copyright (c) 2011-2026, Voximplant, Inc. All rights reserved.
//

extension RangeReplaceableCollection {
    @discardableResult
    mutating func removeFirst(where predicate: @escaping (Element) throws -> Bool) rethrows -> Element? {
        guard let index = try firstIndex(where: predicate) else { return nil }
        return remove(at: index)
    }
}
