//
//  Entry+Convenience.swift
//  TheJournal
//
//  Created by Austin Potts on 9/21/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData


extension Entry {
    
    var entryRepresentation: EntryRepresentation? {
        guard let title = title,
        let note = note,
            let identifier = identifier?.uuidString else {return nil}
        return EntryRepresentation(identifier: identifier, note: note, title: title)
    }
    
    
    convenience init(title: String, note: String, identifier: UUID = UUID(), context: NSManagedObjectContext) {
        
        self.init(context: context)
        
        self.title = title
        self.note = note
        self.identifier = identifier
        
    }
    
    @discardableResult convenience init?(entryRepresentation: EntryRepresentation, context: NSManagedObjectContext) {
        guard let identifier = UUID(uuidString: entryRepresentation.identifier) else {return nil}
        
        self.init(title: entryRepresentation.title, note: entryRepresentation.note, identifier: identifier, context: context)
    }
    
    
    
    
}
