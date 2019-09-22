//
//  AddJournalViewController.swift
//  TheJournal
//
//  Created by Austin Potts on 9/21/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class AddJournalViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var noteTextView: UITextView!
    
    var entryController: EntryController?
    var entry: Entry?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func save(_ sender: Any) {
        
        guard let title = titleTextField.text,
        let note = noteTextView.text,
            !title.isEmpty else {return}
        
        if let entry = entry{
            entryController?.updateEntry(entry: entry, with: title, note: note)
        } else {
            entryController?.createEntry(with: title, note: note)
        }
        
        navigationController?.popViewController(animated: true)
        
    }
    
    func updateViews() {
        title = entry?.title ?? "Create Entry"
        
        titleTextField.text = entry?.title
        noteTextView.text = entry?.note
    }

}
