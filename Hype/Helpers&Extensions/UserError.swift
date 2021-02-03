//
//  UserError.swift
//  Hype
//
//  Created by Lee McCormick on 2/3/21.
//  Copyright © 2021 RYAN GREENBURG. All rights reserved.
//

import Foundation

enum UserError: Error {
    case ckError(Error)
    case cloudNotUpwrap
    case unexpectedRecordsFound
    case noUserLoggedIn
    
    var errorDescription: String {
        switch self {
        case .ckError(let error):
            return error.localizedDescription
        case .cloudNotUpwrap:
            return "Could not upwrap the User data."
        case .unexpectedRecordsFound:
            return "Unexpected User records found. Got back different data that we thought we would."
        case .noUserLoggedIn:
            return "No user loogged In, Check current user!"
        }
    }
}
