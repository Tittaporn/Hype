//
//  Hype.swift
//  Hype
//
//  Created by Lee McCormick on 2/1/21.
//  Copyright © 2021 RYAN GREENBURG. All rights reserved.
//

import CloudKit //CloudKit import Foundation upter the hood

// MARK: - HypeStrings
struct HypeStrings { // Structs ==> Create the new copy. Going to store in many places in the memory. Struct Do Not need init because it is automatically created under the hood.
    static let recordTypeKey = "Hype"
    
    //  fileprivate Only accessible in this swift file
    //  static makes accessible outside the struct
    fileprivate static let bodyKey = "body"
    fileprivate static let timestampKey = "timestamp"
}

// MARK: - Hype Model
class Hype { // Classes ==> References only 1 location in the memory.
    var body: String
    var timestamp: Date
    
    // add CKrecord for delete and update function
    let recordID: CKRecord.ID // ==> is a CKRecord.ID
    // CKRecord.ID If CKRecord.ID is already UUID based, why do we have to initialize it with recordName: UUID().uuidString?  Or is that just for demonstration purposes that you can put in a custom value? YES..
    
    
    // uuidString 36 hex numbers random.
    init(body: String, timestamp: Date = Date(), recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)){
        self.body = body
        self.timestamp = timestamp
        self.recordID = recordID
    }
}

// MARK: - CKRecord
// ==> CKRecord is our data packages that store on the cloud, so users can use in many devices to access it. It is 3 types ==> public, private and shared.
extension CKRecord {
    convenience init(hype: Hype) {
        // What Type of record is ck record going to be ?? Here is the Hype type.
        // recordID: hype.recordID ===> Create init for recordID using hype.recordID
        self.init(recordType: HypeStrings.recordTypeKey, recordID: hype.recordID) //To avoid the loose string >> Create the String in the struct HypeStrings.
        
        self.setValuesForKeys([
            //          Key     : Value from the Hype body of String
            HypeStrings.bodyKey : hype.body,
            HypeStrings.timestampKey : hype.timestamp
        ])
    }
}

// MARK: - Extension Hype to convert Hype to CKRecord
// Create Hype from CKRecord // Create One convenience location to transfer/convert the hype and ckRecord
extension Hype {
    // convenience init? need to guard if it is not nil.
    convenience init?(ckRecord: CKRecord) {
        // Make Sure we get body and timestamp from Dictionary
        // grard to make sure that the value are not nil
        guard let body = ckRecord[HypeStrings.bodyKey] as? String,
              let timestamp = ckRecord[HypeStrings.timestampKey] as? Date else { return nil}
        
        // After the upwrap using the timestamp here.
        // self is Hype // Go to Hype then run Hype.init
        // add CKRecord.ID
        self.init(body: body, timestamp: timestamp, recordID: ckRecord.recordID)
    }
}
// Using ckRecord to create Hype
// let newHype = Hype(ckRecord: <#T##CKRecord#>)

/* NOTE CKRecord
 
 A collection of key-value pairs that store your app’s data.
 Records are the fundamental objects that manage data in CloudKit. You can define any number of record types for your app, with each record type corresponding to a different type of information. Within a record type, you then define one or more fields, each with a name and a value. Records can contain simple data types, such as strings and numbers, or more complex types, such as geographic locations or pointers to other records.
 
 An important step in using CloudKit is defining the record types your app supports. A new record object doesn’t contain any keys or values. During development, you can add new keys and values at any time. The first time you set a value for a key and save the record, the server associates that type with the key for all records of the same type. The CKRecord class doesn’t impose these type constraints or do any local validation of a record’s contents. CloudKit enforces these constraints when you save the records.
 
 https://developer.apple.com/documentation/cloudkit/ckrecord
 
 //______________________________________________________________________________________
 
 
 CK Record is Dictionary === "Key": "Value"
 CloudKit store CKRecord. CloudKit don't not store hype.
 Therefore to save and fetch the data needed trun, fetch data in Dictionary(CK) form in the cloud.
 
 /* Dictionary Key : Value
 
 var superHeroDictionary: [String : String] = [
 "Ironman" : "Yellow & Red",
 "Hulk" : "Green",
 "Spider" : "Red & Blue",
 "Hawkeye" : "Black"
 ]
 
 print(superHeroDictionary["Hulk"])
 // print out == optional(Green)
 
 print(superHeroDictionary["Ironman"])
 // print out == optional(Yellow & Red)
 
 print(superHeroDictionary["Ironmammmmmmmmmn"])
 // print out == nil
 
 print(superHeroDictionary["Green"]) //Can not subscript by Value.
 // print out == nil
 
 */
 //______________________________________________________________________________________
 
 let ckRecord : [String: Any]
 
 //______________________________________________________________________________________
 
 https://developer.apple.com/library/archive/documentation/DataManagement/Conceptual/CloudKitQuickStart/Introduction/Introduction.html#//apple_ref/doc/uid/TP40014987-CH1-SW1
 */
