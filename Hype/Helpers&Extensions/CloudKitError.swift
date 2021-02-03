//
//  CloudKitError.swift
//  Hype
//
//  Created by Lee McCormick on 2/1/21.
//  Copyright © 2021 RYAN GREENBURG. All rights reserved.
//

import Foundation

enum CloudKitError: LocalizedError {
    case ckError(Error)
    case unableToUnwrap
    case unexpectedRecordsFound
    case noUserLoggedIn
    
    var errorDescription: String {
        switch self {
        case .ckError(let error):
            return error.localizedDescription
        case .unableToUnwrap:
            return "Unable to get this Hype...That is not very hype."
        case .unexpectedRecordsFound:
            return "Unexpected records returned"
        case .noUserLoggedIn:
            return "no User logged In. "
        }
    }
}
