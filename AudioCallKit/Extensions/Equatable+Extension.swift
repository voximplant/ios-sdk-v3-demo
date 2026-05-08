//
//  Copyright (c) 2011-2026, Voximplant, Inc. All rights reserved.
//

extension Equatable {
    func isOneOf(_ theFollowing: Self...) -> Bool {
        return theFollowing.contains(self)
    }
}
