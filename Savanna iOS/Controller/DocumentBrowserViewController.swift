//
//  DocumentBrowserViewController.swift
//  test
//
//  Created by Louis D'hauwe on 17/02/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import UIKit

class DocumentBrowserViewController: UIDocumentBrowserViewController, UIDocumentBrowserViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
        delegate = self
        
        allowsDocumentCreation = true
        allowsPickingMultipleItems = false
        
        // Update the style of the UIDocumentBrowserViewController
		browserUserInterfaceStyle = .dark
        // view.tintColor = .white
		
		// Makes sure everything is initialized
		let _ = DocumentManager.shared
    }
    
    
    // MARK: UIDocumentBrowserViewControllerDelegate
    
	func documentBrowser(_ controller: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
		let newDocumentURL: URL? = nil
		
		//		let url = URL(fileURLWithPath: "Untitled.txt")
		
		let newName = DocumentManager.shared.availableFileName(forProposedName: "Untitled")
		
		guard let url = DocumentManager.shared.cacheUrl(for: newName) else {
			importHandler(nil, .none)
			return
		}
		
		let doc = CubDocument(fileURL: url)
		doc.text = ""
		
		doc.save(to: url, for: .forCreating) { (c) in
			
			doc.close(completionHandler: { (c1) in
				
				importHandler(url, .move)
				
			})
			
		}
		
		
		// Set the URL for the new document here. Optionally, you can present a template chooser before calling the importHandler.
		// Make sure the importHandler is always called, even if the user cancels the creation request.
		//        if newDocumentURL != nil {
		//            importHandler(newDocumentURL, .move)
		//        } else {
		//            importHandler(nil, .none)
		//        }
	}
	
	func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentURLs documentURLs: [URL]) {
		guard let sourceURL = documentURLs.first else { return }
		
		// Present the Document View Controller for the first document that was picked.
		// If you support picking multiple items, make sure you handle them all.
		presentDocument(at: sourceURL)
	}
	
	func documentBrowser(_ controller: UIDocumentBrowserViewController, didImportDocumentAt sourceURL: URL, toDestinationURL destinationURL: URL) {
		// Present the Document View Controller for the new newly created document
		presentDocument(at: destinationURL)
	}
	
	func documentBrowser(_ controller: UIDocumentBrowserViewController, failedToImportDocumentAt documentURL: URL, error: Error?) {
		// Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
	}
	
	// MARK: Document Presentation
	
	var transitionController: UIDocumentBrowserTransitionController?
	
	func presentDocument(at documentURL: URL) {
		
		let savannaDoc: SavannaDocument
		
		if documentURL.pathExtension.lowercased() == "cub" {
			let document = CubDocument(fileURL: documentURL)

			savannaDoc = .cub(document)
			
		} else if documentURL.pathExtension.lowercased() == "prideland" {

			let document = PridelandDocument(fileURL: documentURL)
			
			savannaDoc = .prideland(document)
			
		} else {
			showErrorAlert()
			return
		}
		
		let storyBoard = UIStoryboard(name: "Main", bundle: nil)
		let documentViewController = storyBoard.instantiateViewController(withIdentifier: "DocumentViewController") as! DocumentViewController
		documentViewController.document = savannaDoc
		documentViewController.title = documentURL.lastPathComponent
		
		
		transitionController = self.transitionController(forDocumentURL: documentURL)
		transitionController?.targetView = documentViewController.sourceTextView
		
		documentViewController.title = documentURL.lastPathComponent
		
		let navCon = UINavigationController(rootViewController: documentViewController)
		navCon.navigationBar.barStyle = .black
		navCon.navigationBar.isTranslucent = false
		navCon.navigationBar.barTintColor = .navBarColor
		
		navCon.transitioningDelegate = self
		
		present(navCon, animated: true, completion: nil)
	}
	
}

extension DocumentBrowserViewController: UIViewControllerTransitioningDelegate {
	
	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return transitionController
	}
	
	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return transitionController
	}
	
}
