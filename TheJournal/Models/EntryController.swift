//
//  EntryController.swift
//  TheJournal
//
//  Created by Austin Potts on 9/21/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData


enum HTTPMethod: String{
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
}

class EntryController {
    
    let fireBaseURL = URL(string: "https://journal-74562.firebaseio.com/")!
    
    func put(entry: Entry, completion: @escaping()-> Void = {} ) {
        
        let identifier = entry.identifier ?? UUID()
        entry.identifier = identifier
        
         let requestURL = fireBaseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.put.rawValue
        
        guard let representation = entry.entryRepresentation else {
            NSLog("Error")
            completion()
            return
        }
        
        do {
           request.httpBody = try JSONEncoder().encode(representation)
        } catch {
            NSLog("Error encoding task: \(error)")
            completion()
            return
        }
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error{
                NSLog("Error putting task: \(error)")
                completion()
                return
            }
            completion()
            }.resume()
        
        
    }
    
    
    
    func fetchEntryFromServer(completion: @escaping()-> Void = {}){
        
        let requestURL = fireBaseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            
            if let error = error{
                NSLog("error fetching tasks: \(error)")
                completion()
            }
            
            guard let data = data else{
                NSLog("Error getting data task:")
                completion()
                return
            }
            
            do{
                let decoder = JSONDecoder()
                
                let entryRepresentation = Array(try decoder.decode([String: EntryRepresentation].self, from: data).values)
            
                self.update(with: entryRepresentation)
            } catch {
                NSLog("Error decoding: \(error)")
            }
        
        
        
       }.resume()
        
    }
        
        
        func update(with representations: [EntryRepresentation]){
            
            
            let identifiersToFetch = representations.compactMap({ UUID(uuidString: $0.identifier)})
            
            let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, representations))
            
            //Make a mutable copy of Dictionary above
            var entryToCreate = representationsByID
            
            
            let context = CoreDataStack.share.container.newBackgroundContext()
            context.performAndWait {
                
                
                
                do {
                    
                    let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
                    //Name of Attibute
                    fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
                    
                    //Which of these tasks already exist in core data?
                    let exisitingEntry = try context.fetch(fetchRequest)
                    
                    //Which need to be updated? Which need to be put into core data?
                    for entry in exisitingEntry {
                        guard let identifier = entry.identifier,
                            // This gets the task representation that corresponds to the task from Core Data
                            let representation = representationsByID[identifier] else{return}
                        
                         entry.title = representation.title
                         entry.note = representation.note
                        
                        entryToCreate.removeValue(forKey: identifier)
                        
                    }
                    //Take these tasks that arent in core data and create
                    for representation in entryToCreate.values{
                        Entry(entryRepresentation: representation, context: context)
                    }
                    
                    CoreDataStack.share.save(context: context)
                    
                } catch {
                    NSLog("Error fetching tasks from persistent store: \(error)")
                }
            }
            
            
        }
        
        
        //CRUD
        
    @discardableResult func createEntry(with title: String, note: String) -> Entry {
        let entry = Entry(title: title, note: note, context: CoreDataStack.share.mainContext)
        
        put(entry: entry)
        CoreDataStack.share.save()
        
        return entry
    }
    
    
    
    func updateEntry(entry: Entry, with title: String, note: String){
        
        entry.title = title
        entry.note = note
        
        put(entry: entry)
        CoreDataStack.share.save()
        
    }
    
    func delete(entry: Entry){
        
        CoreDataStack.share.mainContext.delete(entry)
        CoreDataStack.share.save()
        
    }
    
    
    

    
    
    
    
}
