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
        
        guard let currentUser = UserController.sharedInstance.currentUser else { return completion(.failure(.noUserLoggedIn))}
        
        
        // add reference ==> SO WE NEED ==> UserController
        let reference = CKRecord.Reference(recordID: currentUser.recordID, action: .deleteSelf)
        
        // Create newHype
        let newHype = Hype(body: text, userReference: reference)
        
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
                    return completion(.failure(.ckError(error)))
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
                    return completion(.failure(.ckError(error)))
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
    // Result<> ==> is a Result Type Enum of 2 cases success or failure.
    func update(hype: Hype, completion: @escaping (Result<String,CloudKitError>) -> Void) {
        
        // <#T##[CKRecord]?#>
        let record = CKRecord(hype: hype)
        
        // <#T##[CKRecord.ID]?#> ==> NO NEEDED FOR DELETE
        let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        
        // Only specific on .changedKeys ==> Something to
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = { records, recordIDs, error in
            if let error = error {
                print("======== ERROR ========")
                print("Function: \(#function)")
                print("Error: \(error)")
                print("Description: \(error.localizedDescription)")
                print("======== ERROR ========")
                return completion(.failure(.ckError(error)))
            }
            
            // Find the first of records that we update it
            guard let record = records?.first else { return(completion(.failure(.unableToUnwrap))) }
            completion(.success("Successfully updated \(record.recordID.recordName) in CloudKit."))
        }
        publicDB.add(operation)
    }
    
    // MARK: - DELETE
    // completion == call back when those code is done, I will call you back, but you can do anything else while waiting for you.
    // @escaping // Not drop out the memory. Still keep in escaping before disappear.. Call back later point in time
    func delete(hype: Hype, completion: @escaping (Result<String, CloudKitError>) -> Void) {
        
        // [hype.recordID] ==> hype that we want to delete, no need to save, so ==> recordsToSave: nil
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [hype.recordID])
        
        // .userInteractive ==> prioritise it, speed it up.
        operation.qualityOfService = .userInteractive
        
        // we are running the block after operation changed.
        // {} not autocompleted.
        operation.modifyRecordsCompletionBlock = { records, recordIDs, error in
            if let error = error {
                print("======== ERROR ========")
                print("Function: \(#function)")
                print("Error: \(error)")
                print("Description: \(error.localizedDescription)")
                print("======== ERROR ========")
                return completion(.failure(.ckError(error)))
            }
            
            // unwrap recordID, received the first recordIDs to delete
            guard let recordID = recordIDs?.first else { return completion(.failure(.unableToUnwrap))}
            // completion with String to be sure we are deleting the hype with specific recordID
            completion(.success("Successfully deleted a hype with the record id: \(recordID.recordName)"))
        }
        
        // STEP 1 :: publicOrPrivateOrSharedDB.add(operation to delete to update)
        // This is we can delete the whole array and use it for updating 
        publicDB.add(operation)
        
        /*
         // Allow you to delete 1 object at a time. ==> one single id at a time.
         publicDB.delete(withRecordID: <#T##CKRecord.ID#>, completionHandler: <#T##(CKRecord.ID?, Error?) -> Void#>)
         */
    }
    
    func subscribeForRomoteNotifications(completion: @escaping (Bool) -> Void ) {
        
        let allHypesPredicate = NSPredicate(value: true)
        
        // Query Subscription ??? .firesOnRecordUpdate ???
        let subscription = CKQuerySubscription(recordType: HypeStrings.recordTypeKey, predicate: allHypesPredicate, options: .firesOnRecordUpdate)
        
        // Set notification property to keep the hype in the cloud.
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.title = "HYPE! A HYPE IS IN!"
        notificationInfo.alertBody = "Can't get enough HYPES!"
        notificationInfo.soundName = "default"
        notificationInfo.shouldBadge = true
        subscription.notificationInfo = notificationInfo
        
        publicDB.save(subscription) { (_, error) in
            if let error = error {
                print("======== ERROR ========")
                print("Function: \(#function)")
                print("Error: \(error)")
                print("Description: \(error.localizedDescription)")
                print("======== ERROR ========")
                return completion(false)
            }
            completion(true)
        }
    }
}


/* NOTE
 
 Delivering notifications with CloudKit push messages: CKQuerySubscription
 https://www.hackingwithswift.com/read/33/8/delivering-notifications-with-cloudkit-push-messages-cksubscript
 
 NSOperation
 
 NSOperationQueue
 NSOperationQueue regulates the concurrent execution of operations. It acts as a priority queue, such that operations are executed in a roughly First-In-First-Out manner, with higher-priority (NSOperation.queuePriority) ones getting to jump ahead of lower-priority ones. NSOperationQueue can also limit the maximum number of concurrent operations to be executed at any given moment, using the maxConcurrentOperationCount property.
 
 When to Use Grand Central Dispatch
 Dispatch queues, groups, semaphores, sources, and barriers comprise an essential set of concurrency primitives, on top of which all of the system frameworks are built.
 
 For one-off computation, or simply speeding up an existing method, it will often be more convenient to use a lightweight GCD dispatch than employ NSOperation.
 
 When to Use NSOperation
 NSOperation can be scheduled with a set of dependencies at a particular queue priority and quality of service. Unlike a block scheduled on a GCD queue, an NSOperation can be cancelled and have its operational state queried. And by subclassing, NSOperation can associate the result of its work on itself for future reference.
 
 https://nshipster.com/nsoperation/
 
 
 //______________________________________________________________________________________
 */
