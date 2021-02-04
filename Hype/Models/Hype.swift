//
//  Hype.swift
//  Hype
//
//  Created by Lee McCormick on 2/1/21.
//  Copyright © 2021 RYAN GREENBURG. All rights reserved.
//

import CloudKit //CloudKit import Foundation upter the hood
import UIKit

// MARK: - HypeStrings
struct HypeStrings { // Structs ==> Create the new copy. Going to store in many places in the memory. Struct Do Not need init because it is automatically created under the hood.
    static let recordTypeKey = "Hype"
    
    //  fileprivate Only accessible in this swift file
    //  static makes accessible outside the struct
    fileprivate static let bodyKey = "body"
    fileprivate static let timestampKey = "timestamp"
    
    // add anoter string for ckReference
    fileprivate static let userReferenceKey = "userReference"
    
    // add this for the photo
    fileprivate static let photoAssetKey = "photoAsset"
}

// MARK: - Hype Model
class Hype { // Classes ==> References only 1 location in the memory.
    var body: String
    var timestamp: Date
    
    // add CKrecord for delete and update function
    let recordID: CKRecord.ID // ==> is a CKRecord.ID
    // CKRecord.ID If CKRecord.ID is already UUID based, why do we have to initialize it with recordName: UUID().uuidString?  Or is that just for demonstration purposes that you can put in a custom value? YES..
    
    // add variable string for ckReference
    var userReference: CKRecord.Reference? //We are pushing update to the app, we are now adding new data, but the old data in the cloud do not have userReference, that why ? optional
    
    // add User for Photo
    var user: User?
    var hypePhoto: UIImage? {
        get { // GET run when ever you assign something to this property
            // Go get the photo Data
            guard let photoData = self.photoData else { return nil }
            return UIImage(data: photoData)
        } set { // newValue? ==> Part of get set
            // saving space in dataBase 0.5
            // And Set the photoData to HypePhoto
            photoData = newValue?.jpegData(compressionQuality: 0.5)
        }
    }
    
    var photoData: Data? // if we have photoData then create hyoePhoto then Using photoData to create photoAsset to the save in the cloud
    
    // We can have photoAsset.., soundAsset...
    var photoAsset: CKAsset? { // Require for large amount of the CKAsset, Only Work with Could kit
        get {
            // Without this guard, unable to create Hypes without photos
            guard photoData != nil else { return nil}
            let tempDirectory = NSTemporaryDirectory()
            let tempDirectoryURL = URL(fileURLWithPath: tempDirectory)
            
            // place to save it in the cloud
            let fileURL = tempDirectoryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
            
            // When do we use do try, catch, anytime you see throw, we have to use do try catch
            // try might be using somewhere else.. with out do {..} catch {...}
            // try .. do {..} catch {...}
            // write those data in the cloud
            do {
                try photoData?.write(to: fileURL)
            } catch {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
            return CKAsset(fileURL: fileURL)
        }
    }
    
    // uuidString 36 hex numbers random.
    init(body: String, timestamp: Date = Date(), recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), userReference: CKRecord.Reference?, hypePhoto: UIImage?){
        self.body = body
        self.timestamp = timestamp
        self.recordID = recordID
        self.userReference = userReference
        self.hypePhoto = hypePhoto
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
        
        // PS. You can not set the nil value for the key
        if let  reference = hype.userReference {
            setValue(reference, forKey: HypeStrings.userReferenceKey)
        }
        
        if hype.photoAsset != nil {
            setValue(hype.photoAsset, forKey: HypeStrings.photoAssetKey)
        }
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
        
        // add userRef
        let userReference = ckRecord[HypeStrings.userReferenceKey] as? CKRecord.Reference
        
        // add photo
        var foundPhoto: UIImage?
        
        // if foundPhoto is nil.... then don't run this block
        if let photoAsset = ckRecord[HypeStrings.photoAssetKey] as? CKAsset {
            do {
                let data = try Data(contentsOf: photoAsset.fileURL!) //! make your app crash if value is nil.
                foundPhoto = UIImage(data: data)
            } catch {
                print("Could Not Transform Asset to Data")
            }
        }
        
        // After the upwrap using the timestamp here.
        // self is Hype // Go to Hype then run Hype.init
        // add CKRecord.ID
        self.init(body: body, timestamp: timestamp, recordID: ckRecord.recordID, userReference: userReference, hypePhoto: foundPhoto)
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
