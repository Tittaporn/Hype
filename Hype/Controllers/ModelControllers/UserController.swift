//
//  UserController.swift
//  Hype
//
//  Created by Lee McCormick on 2/3/21.
//  Copyright © 2021 RYAN GREENBURG. All rights reserved.
//

import CloudKit

class UserController {
    // MARK: - Properties
    static let sharedInstance = UserController()
    var currentUser: User?
    let publicDB = CKContainer.default().publicCloudDatabase
    
    // MARK: - CRUD Methods
    // CREATE
    func createUserWith(_ username: String, completion: @escaping (Result<User?, UserError>) -> Void) {
        // Every apple account have a reference, we are grabbing thier appleIDrefernce.
        // We need to get the appleID reference in order to create the user
        fetchAppleUserRefernce { (result) in
            switch result {
            case .success(let reference):
                guard let reference = reference else { return completion(.failure(.noUserLoggedIn))}
                let newUser = User(username: username, appleUserRef: reference)
                let record = CKRecord(user: newUser)
                self.publicDB.save(record) { (record, error) in
                    if let error = error {
                        return completion(.failure(.ckError(error)))
                    }
                    guard let record = record else {return completion(.failure(.unexpectedRecordsFound))}
                    guard let savedUser = User(ckRecord: record) else {return completion(.failure(.cloudNotUpwrap))}
                    print("Create User: \(record.recordID.recordName)")
                    completion(.success(savedUser))
                }
            case .failure(let error) :
                print(error.localizedDescription)
            }
        }
    }
    
    
    func fetchUer(completion: @escaping (Result<User?, UserError>) -> Void) {
        fetchAppleUserRefernce { (result) in
            switch result {
            case .success(let reference):
                guard let reference = reference else { return completion(.failure(.noUserLoggedIn))}
                let predicate = NSPredicate(format: "%K == %@", argumentArray: [UserStrings.appleUserRefKey, reference])
                let query = CKQuery(recordType: UserStrings.recordTypeKey, predicate: predicate)
                self.publicDB.perform(query, inZoneWith: nil) { (records, error) in
                    if let error = error {
                        return completion(.failure(.ckError(error)))
                    }
                    guard let record = records?.first else { return completion(.failure(.unexpectedRecordsFound))}
                    guard let foundUser = User(ckRecord: record) else { return completion(.failure(.cloudNotUpwrap))}
                    
                    print("Fetched user: \(record.recordID.recordName)")
                    completion(.success(foundUser))
                }
            case .failure(let error):
                print(error.errorDescription)
            }
        }
    }
    
    
    // READ
    // private ==> preventing ???
    private func fetchAppleUserRefernce(completion: @escaping (Result<CKRecord.Reference?, UserError>) -> Void) {
        // Using the default().fetchUserRecordID to fetch
        CKContainer.default().fetchUserRecordID { (recordID, error) in
            if let error = error {
                completion(.failure(.ckError(error)))
            }
            
            // if we have recordID
            if let recordID = recordID {
                // action: .deleteSelf ==> we are not deleting the record of user, just something in apple???
                let reference = CKRecord.Reference(recordID: recordID, action: .deleteSelf)
                completion(.success(reference)) // Then return the reference ==> fetchAppleUserRefernce
            }
        }
    }
    
    // UPDATE
    
    // DELETE
}

/* NOTE
 CKRecord_Reference_Action.deleteSelf
 The delete action for referenced records. Deleting a record also deletes any records containing CKReference objects that point to that record. The deletion of the additional records may trigger a cascade deletion of more records. The deletions are asynchronous in the default zone and immediate in a custom zone.
 //______________________________________________________________________________________
 
 https://nshipster.com/nspredicate/
 NSPredicate is a Foundation class that specifies how data should be fetched or filtered. Its query language, which is like a cross between a SQL WHERE clause and a regular expression, provides an expressive, natural language interface to define logical conditions on which a collection is searched.
 
 */
