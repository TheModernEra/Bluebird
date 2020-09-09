//
//  ViewController.swift
//  Bluebird
//
//  Created by Bennett Rosenthal on 8/20/20.
//  Copyright © 2020 ModernEra. All rights reserved.
//

import Cocoa
import Foundation
import Alamofire
import SSZipArchive

class ViewController: NSViewController {
    // universal variables
    let usernameFilePath = NSString(string: "~").expandingTildeInPath
    var gameSelected = "Pavlov"
    
    // pavlov variables
    var pavlovURL = "placeholder"
    var pavlovOBBName = "placeholder"
    var pavlovAPKName = "placeholder"
    var pavlovBuildName = "placeholder"
    
    // contractors variables
    var contractorsURL = "placeholder"
    var contractorsOBBName = "placeholder"
    var contractorsAPKName = "placeholder"
    var contractorsBuildName = "placeholder"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.downloadProgressIndicator.isHidden = true
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBOutlet weak var selectionLabel: NSTextField!
    @IBOutlet weak var gameSelectionDropdown: NSPopUpButtonCell!
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var uninstallButton: NSButton!
    @IBOutlet weak var downloadProgressIndicator: NSProgressIndicator!
    
    @IBAction func gameSelectionDropdownChanged(_ sender: Any) {
        gameSelected = gameSelectionDropdown.titleOfSelectedItem!
        selectionLabel.stringValue = ("What do you want to do with " + gameSelected + "?")
    }
    
    @IBAction func goButtonPressed(_ sender: Any) {
        do {
            // defines array from txt file
            let txtPath: String = "\(self.usernameFilePath)/Downloads/upsiopts.txt"
            let txtFile = try String(contentsOfFile: txtPath)
            let txtArray: [String] = txtFile.components(separatedBy: "\n")
            let separator = "END\r"
            let array = txtArray.split(separator: separator)
            
            // creates Contractors Array
            let contractorsArray = Array(array[0])
            // gets necessary variables for contractors
            
            // gets Contractors URL
            let firstContractURL = contractorsArray.firstIndex(where: {$0.hasPrefix("DOWNLOADFROM=") })!
            let secondContractURL = contractorsArray[firstContractURL]
            let thirdContractURL = secondContractURL.replacingOccurrences(of: "DOWNLOADFROM=", with: "")
            contractorsURL = thirdContractURL.replacingOccurrences(of: "\r", with: "")
            print("")
            print(contractorsURL)
            
            // gets Contractors OBB file name
            let firstContractOBB = contractorsArray.firstIndex(where: {$0.hasPrefix("OBB=") })!
            let secondContractOBB = contractorsArray[firstContractOBB]
            let thirdContractOBB = secondContractOBB.replacingOccurrences(of: "OBB=", with: "")
            contractorsOBBName = thirdContractOBB.replacingOccurrences(of: "\r", with: "")
            print("")
            print(contractorsOBBName)
            
            // gets Contractors APK file name
            let firstContractAPK = contractorsArray.firstIndex(where: {$0.hasPrefix("APK=") })!
            let secondContractAPK = contractorsArray[firstContractAPK]
            let thirdContractAPK = secondContractAPK.replacingOccurrences(of: "APK=", with: "")
            contractorsAPKName = thirdContractAPK.replacingOccurrences(of: "\r", with: "")
            print("")
            print(contractorsAPKName)
            
            // gets Contractors folder name
            let firstContractName = contractorsArray.firstIndex(where: {$0.hasPrefix("ZIPNAME=") })!
            let secondContractName = contractorsArray[firstContractName]
            let thirdContractName = secondContractName.replacingOccurrences(of: "ZIPNAME=", with: "")
            let fourthContractName = thirdContractName.replacingOccurrences(of: ".zip", with: "")
            contractorsBuildName = fourthContractName.replacingOccurrences(of: "\r", with: "")
            print("")
            print(contractorsBuildName)
            
            // creates Pavlov Array
            let pavlovArray = Array(array[1])
            // gets necessary variables for pavlov
            
            // URL for pavlov
            let firstPavlovURL = pavlovArray.firstIndex(where: { $0.hasPrefix("DOWNLOADFROM=") })!
            let secondPavlovURL = pavlovArray[firstPavlovURL]
            let thirdPavlovURL = secondPavlovURL.replacingOccurrences(of: "DOWNLOADFROM=", with: "")
            pavlovURL = thirdPavlovURL.replacingOccurrences(of: "\r", with: "")
            
            // OBB file name
            let firstOBBName = pavlovArray.firstIndex(where: {$0.hasPrefix("OBB=")})!
            let secondOBBName = pavlovArray[firstOBBName]
            let thirdOBBName = secondOBBName.replacingOccurrences(of: "OBB=", with: "")
            pavlovOBBName = thirdOBBName.replacingOccurrences(of: "\r", with: "")
            
            // current build name
            let firstBuildName = pavlovArray.firstIndex(where: {$0.hasPrefix("ZIPNAME=")})!
            let secondBuildName = pavlovArray[firstBuildName]
            let thirdBuildName = secondBuildName.replacingOccurrences(of: "ZIPNAME=", with: "")
            let fourthBuildName = thirdBuildName.replacingOccurrences(of: ".zip", with: "")
            pavlovBuildName = fourthBuildName.replacingOccurrences(of: "\r", with: "")
            
            // APK file name
            let firstAPKName = pavlovArray.firstIndex(where: {$0.hasPrefix("APK=")})!
            let secondAPKName = pavlovArray[firstAPKName]
            let thirdAPKName = secondAPKName.replacingOccurrences(of: "APK=", with: "")
            pavlovAPKName = thirdAPKName.replacingOccurrences(of: "\r", with: "")
            
            // creates Hi-Bow Array
            let hibowArray = Array(array[2])
        }
        catch {
            print(error)
        }
        
        if gameSelected == "Contractors" {
            statusLabel.stringValue = "Downloading latest version of Contractors..."
            self.downloadProgressIndicator.isHidden = false
            let destination: DownloadRequest.Destination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent("\(self.contractorsBuildName).zip")
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
                    }

            AF.download(contractorsURL, to: destination).downloadProgress { progress in
                    self.downloadProgressIndicator.doubleValue = (progress.fractionCompleted * 100)
            }.response { response in
                debugPrint(response)

                if response.error == nil, let imagePath = response.fileURL?.path {
                    self.statusLabel.stringValue = "Download Complete!"
                    self.downloadProgressIndicator.isHidden = true
        }
    }
    
    var amount = 0
     func uninstallButtonPressed(_ sender: Any) {
        amount += 1
        if amount == 1 {
            uninstallButton.title = "Are you sure?"
        }
        print(amount)
        if amount == 2 {
            uninstallButton.title = "Uninstalling..."
        }
    }
}
}
}
