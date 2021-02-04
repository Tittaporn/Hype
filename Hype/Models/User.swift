//
//  User.swift
//  Hype
//
//  Created by Lee McCormick on 2/3/21.
//  Copyright © 2021 RYAN GREENBURG. All rights reserved.
//

import CloudKit
import UIKit

struct UserStrings {
    static let recordTypeKey = "User"
    fileprivate static let usernameKey = "username"
    fileprivate static let bioKey = "bio"
    static let appleUserRefKey = "appleUserRef"
    fileprivate static let photoAssetKey = "photoAsset"
}

class User {
    var username: String
    var bio: String
    var recordID: CKRecord.ID
    var appleUserRef: CKRecord.Reference
    
    // User profile photo
    var profilePhoto: UIImage? {
        get { // Get Run code anytime you read property.
            guard let photoData = self.photoData else { return nil}
            return UIImage(data: photoData)
        } set {
            photoData = newValue?.jpegData(compressionQuality: 0.5)
        }
    }
    var photoData: Data?
    var photoAsset: CKAsset { // We are giving photoAsset the URL ==> the address
        get {
            let tempDirectory = NSTemporaryDirectory()
            let tempDirecotoryURL = URL(fileURLWithPath: tempDirectory)
            let fileURL = tempDirecotoryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
            do {
                try photoData?.write(to: fileURL)
            } catch {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
            return CKAsset(fileURL: fileURL)
        }
    }
    
    init(username: String, bio: String = "", recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), appleUserRef: CKRecord.Reference, profilePhoto: UIImage? = nil) {
        self.username = username
        self.bio = bio
        self.recordID = recordID
        self.appleUserRef = appleUserRef
        self.profilePhoto = profilePhoto
    }
}
// USING CKRecord to convert the data to USER TYPE And CKUSER in the cloud
// MARK: - Extension User
extension User {
    convenience init?(ckRecord: CKRecord) {
        guard let username = ckRecord[UserStrings.usernameKey] as? String,
              let appleUserRef = ckRecord[UserStrings.appleUserRefKey] as? CKRecord.Reference else { return nil}
        
        // profile Photo
        var foundPhoto: UIImage?
        if let photoAsset = ckRecord[UserStrings.photoAssetKey] as? CKAsset {
            do {
                let data = try Data(contentsOf: photoAsset.fileURL!)
                foundPhoto = UIImage(data: data)
            } catch {
                print("Could Not Transform Asset to Data")
            }
        }
        
        
        // translate to User to CkRecord
        self.init(username: username, recordID: ckRecord.recordID, appleUserRef: appleUserRef, profilePhoto: foundPhoto)
    }
}

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.recordID == rhs.recordID
    }
}

// MARK: - Extension CKRecord
extension CKRecord {
    convenience init(user: User) {
        self.init(recordType: UserStrings.recordTypeKey, recordID: user.recordID)
        
        setValuesForKeys([
            UserStrings.usernameKey : user.username,
            UserStrings.bioKey : user.bio,
            UserStrings.appleUserRefKey : user.appleUserRef,
            UserStrings.photoAssetKey : user.photoAsset
        ])
    }
}
