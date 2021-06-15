//
//  SignInViewController.swift
//  MSIT - Notifier
//
//  Created by Abhishek Sansanwal on 28/05/21.
//  Copyright © 2021 Verved. All rights reserved.
//

import UIKit
import GoogleSignIn
import GoogleAPIClientForREST
import GTMSessionFetcher
import MobileCoreServices


class SignInViewController: UIViewController, UIDocumentPickerDelegate {
    
    let googleDriveService = GTLRDriveService()
    var googleUser: GIDGoogleUser?
    var imagePicker = UIImagePickerController()
    var documentURL: URL = URL(string: "https://duckduckgo.com/")!
    
    @IBOutlet weak var driveFolderLinkField: UITextField!
    
    @IBOutlet weak var fileSelectStatus: UILabel!
    @IBOutlet weak var signButton: UIButton!
    @IBOutlet weak var renameFileField: UITextField!
    
    @IBAction func uploadButtonPressed(_ sender: Any) {
        
        let folderLink = driveFolderLinkField.text!
        
        let index = folderLink.index(folderLink.firstIndex(of: "f")!, offsetBy: 7)
        
        let range = folderLink.index(after: index)..<folderLink.endIndex
        
        let folderID = "\(folderLink[range])"
        
        
        
        upload(folderID, fileName: renameFileField.text!, fileURL: documentURL, MIMEType: "application/pdf") { (string, error) in
            print("string\(string), error\(error)")
        }
        
    }
    
    @IBAction func apiButtonPressed(_ sender: Any) {
        
        let documentPicker = UIDocumentPickerViewController(documentTypes: [String(kUTTypeText),String(kUTTypeContent),String(kUTTypeItem),String(kUTTypeData)], in: .import)
                documentPicker.delegate = self
                self.present(documentPicker, animated: true)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        fileSelectStatus.text = urls.first!.absoluteString
        documentURL = urls.first!.absoluteURL
    
       }
    
    private func upload(_ folderID: String, fileName: String, fileURL: URL, MIMEType: String, onCompleted: ((String?, Error?) -> ())?) {
        let file = GTLRDrive_File()
        file.name = fileName
        file.parents = [folderID]
        
        let params = GTLRUploadParameters(fileURL: fileURL, mimeType: MIMEType)
        googleDriveService.uploadProgressBlock = { _, totalBytesUploaded, totalBytesExpectedToUpload in
            print("PERCENTAGE PROGRESS OF UPLOAD!!!")
            print(totalBytesUploaded/totalBytesExpectedToUpload * 100)
            }
        
        let query = GTLRDriveQuery_FilesCreate.query(withObject: file, uploadParameters: params)
        query.fields = "id"
        
        self.googleDriveService.executeQuery(query, completionHandler: { (ticket, file, error) in
            onCompleted?((file as? GTLRDrive_File)?.identifier, error)
        })
    }
    
    
    @IBAction func buttonPressed(_ sender: Any) {
        if signButton.titleLabel?.text == "Sign In" {
            print("FIRST TIME USER = \(googleUser?.profile.email)")
            print("Signing in")
            GIDSignIn.sharedInstance()?.signIn()
            print("Signed in")
            signButton.setTitle("Sign Out", for: .normal)
        }
        else {
            signButton.setTitle("Sign In", for: .normal)
            print("FIRST TIME USER = \(googleUser?.profile.email)")
            GIDSignIn.sharedInstance()?.signOut()
            print("FIRST TIME USER = \(googleUser?.profile.email)")
        }
    }
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("FIRST TIME USER = \(googleUser?.profile.email)")
        
        if GIDSignIn.sharedInstance()?.currentUser != nil {
            signButton.setTitle("Sign Out", for: .normal)
        }
        
        GIDSignIn.sharedInstance()?.scopes = [kGTLRAuthScopeDrive]
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        
        print("FIRST TIME USER = \(googleUser?.profile.email)")
    }
   
}

extension SignInViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        // A nil error indicates a successful login
        if error == nil {
            // Include authorization headers/values with each Drive API request.
            self.googleDriveService.authorizer = user.authentication.fetcherAuthorizer()
            self.googleUser = user
        } else {
            self.googleDriveService.authorizer = nil
            self.googleUser = nil
        }
        // ...
    }
}

