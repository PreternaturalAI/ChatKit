//
// Copyright (c) Vatsal Manot
//

import Swallow
@_spi(Internal) import SwiftUIX

public enum ChatItemActivityPhase: Hashable {
    case idle
    case sending
    case failed(AnyError)
    
    var error: AnyError? {
        guard case .failed(let error) = self else {
            return nil
        }
        
        return error
    }
    
    @_disfavoredOverload
    public static func failed(_ error: Swift.Error) -> Self {
        Self.failed(AnyError(erasing: error))
    }
}

extension View {
    public func activityPhaseOfLastItem(
        _ phase: ChatItemActivityPhase?
    ) -> some View {
        transformEnvironment(\._chatViewPreferences) {
            if let phase = phase, phase != .idle {
                $0.activityPhaseOfLastItem = phase
            } else {
                $0.activityPhaseOfLastItem = nil
            }
        }
    }
}
