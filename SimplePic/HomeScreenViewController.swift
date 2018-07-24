//
//  HomeScreenViewController.swift
//  SimplePic
//
//  Created by Alex Busol on 7/24/18.
//  Copyright © 2018 Alex Busol. All rights reserved.
//

import UIKit
import Parse

private let reuseIdentifier = "Cell"

class HomeScreenViewController: UICollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = PFUser.current()?.username?.uppercased() //showing the current user's username in the navbar
        

    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath) as! HeaderView //making connection to the header view
        
        //MARK: - 1. Populate user's profile with info from the database
        //retrieving each of the column's info using the column key
        header.fullNameLabel.text = (PFUser.current()?.object(forKey: "FullName") as? String)?.uppercased() //getting current user's full name from the database
        
        header.websiteTextField.text = PFUser.current()?.object(forKey: "website") as? String
        header.websiteTextField.sizeToFit()
        header.bioLabel.text = PFUser.current()?.object(forKey: "Bio") as? String
        header.bioLabel.sizeToFit() //making sure that the textview size matches the website length
        let currentAvatar = PFUser.current()?.object(forKey: "avatar") as! PFFile
        currentAvatar.getDataInBackground { (data, error) -> Void in
            header.userImage.image = UIImage(data: data!)
        }
        header.profileActionButton.setTitle("Edit Profile", for: UIControlState())
        
        //MARK: - 2. Count the number of posts, followers, and following
        return header
    }
/*
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
    
        return cell
    }
*/
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
