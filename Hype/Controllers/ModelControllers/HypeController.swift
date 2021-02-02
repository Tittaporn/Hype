//
//  HypeController.swift
//  Hype
//
//  Created by Lee McCormick on 2/1/21.
//  Copyright © 2021 RYAN GREENBURG. All rights reserved.
//

import CloudKit //Needed to import Cloudkit to work with Hype

class HypeController {
    
    // MARK: - Properties
    // Shared Instance
    static let shared = HypeController()
    // S.O.T.
    var hypes: [Hype] = []
    
    // .publicCloudDatabase because twitter app. If entry app use .privateCloudDatabase
    let publicDB = CKContainer.default().publicCloudDatabase
    
    // MARK: - CRUD Methods
    // MARK: - CREATE
    func createHype(with text: String, completion: @escaping (Result<String, CloudKitError>) -> Void) {
        // Create newHype
        let newHype = Hype(body: text)
        
        // Convert newHype to CKRecord Type
        let hypeRecord = CKRecord(hype: newHype)
        
        // save Something CKRecord using this line
        // Wating to the hype Going through the process to get saved the the cloud
        publicDB.save(hypeRecord) { (record, error) in
            
            // Using DispatchQueue Here because we want to put it in the main thread
            DispatchQueue.main.async {
                if let error = error {
                    print("======== ERROR ========")
                    print("Function: \(#function)")
                    print("Error: \(error)")
                    print("Description: \(error.localizedDescription)")
                    print("======== ERROR ========")
                    return completion(.failure(.ckError))
                }
                
                // upwarp the record , and saveHype from the record. Make sure we have record
                guard let record = record,
                      // savedHype from the CKRecord
                      let savedHype = Hype(ckRecord: record) else { return completion(.failure(.unableToUnwrap))}
                // We appended it after we make sure the hype get saved in the cloud
                self.hypes.append(savedHype)
                completion(.success("Successfully save a Hype."))
            }
        }
    }
    
    // MARK: - READ
    func fetchAllHypes(completion: @escaping (Result<String, CloudKitError>) -> Void) {
        
        // Using this predicate to set all hypes record.
        let fetchAllPredicates = NSPredicate(value: true)
        
        // Using Magic Strings to prevent mistake
        // recordTypeKey = "Hype"
        // This qurey is going to search in CKRecord in recordType == "Hype"
        let query = CKQuery(recordType: HypeStrings.recordTypeKey, predicate: fetchAllPredicates)
        
        // To fetch the Hypes using inZoneWith ==> by query
        // inZoneWith: nil ==> For now we are using nil
        // quary ==> to filter to info we needed.
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print("======== ERROR ========")
                    print("Function: \(#function)")
                    print("Error: \(error)")
                    print("Description: \(error.localizedDescription)")
                    print("======== ERROR ========")
                    return completion(.failure(.ckError))
                }
                
                guard let records = records else { return completion(.failure(.unableToUnwrap))}
                
                /* Using compactMap instead of for in loop
                 for record in records {
                 let hype = Hype(ckRecord: record)
                 hypes.append(hype)
                 }
                 */
                
                // $0  == each ckRecord >> for iterating through each record
                let fetchedHypes = records.compactMap { Hype(ckRecord: $0) }
                // append(contentsOf: ...) ==> To append the array of something to somthing
                //self.hypes.append(contentsOf: fetchedHypes)
                self.hypes = fetchedHypes
                completion(.success("Successfully fetched all hypes."))
            }
            
        }
    }
    
    // MARK: - UPDATE
    
    // MARK: - DELETE
}
