//
//  ViewProfileViewController.swift
//  Tuta
//
//  Created by Alex Li on 11/16/19.
//  Copyright © 2019 Zhen Duan. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import Firebase

class ViewProfileViewController: UIViewController{
    let dc = DataController()
    var user : TutaUser = TutaUser()
    var post : [String:Any]!
    
//    let userID = Auth.auth().currentUser?.uid
    
    var userID = "cT524ItOQzUKXXRWjkWwHeMPGhJ2"
    var imgUrl = ""
    var imagePicker = UIImagePickerController()
    var imageData = Data()
    let defaultProfile = Bundle.main.path(forResource: "stu-1", ofType: "jpg")

    @IBOutlet weak var ViewNameLabel: UILabel!
    
    @IBOutlet weak var ViewGenderLabel: UILabel!
    
    @IBOutlet weak var ViewRatingLabel: UILabel!
    
    @IBOutlet weak var ViewNumberRateLabel: UILabel!
    
    @IBOutlet weak var ViewEmailLabel: UILabel!
    
    @IBOutlet weak var ViewPhoneNumberLabel: UILabel!
    
    @IBOutlet weak var ViewDescriptionTextView: UITextView!
    
    @IBOutlet weak var ViewCoursesTakenLabel: UILabel!
    @IBOutlet weak var ViewPhotoImageView: UIImageView!
    @IBOutlet weak var RequestButton: UIButton!
    
    @IBAction func RequestButtonClicked(_ sender: Any) {
        RequestButton.isEnabled = false
        var event : Event = Event(eventID: "eventID", studentID: self.user.uid, tutorID: post?["creatorID"] as! String, time: post?["time"] as! String, date: post?["date"] as! String,course: post?["course"] as! String, status: "requested")
        dc.uploadEventToCloud(event: event)
    }
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dc.delegate = self
        userID = (post["creatorID"]as? String)!
        dc.getUserFromCloud(userID: self.userID){(e) in self.user = (e)
            
            self.ViewNameLabel.text = self.user.name
            self.ViewEmailLabel.text = self.user.email
            self.ViewGenderLabel.text = self.user.gender
            self.ViewPhoneNumberLabel.text = self.user.phone
            self.ViewDescriptionTextView.text = self.user.description
            self.ViewRatingLabel.text = "rating: " + String(self.user.rate)
            self.ViewNumberRateLabel.text =  String(self.user.numRate) + " rates"
            
            
            var courses : String = ""
            for item in self.user.courseTaken{
                courses = courses + item + " "
            }
            self.ViewCoursesTakenLabel.text = courses
            
        }
        imgUrl = self.user.url
        print("*********")
        print(imgUrl)
        if(imgUrl == ""){}
        else{
            imageData = try!Data(contentsOf: URL(string:imgUrl) ??  URL(fileURLWithPath: defaultProfile!))
            self.ViewPhotoImageView.image = UIImage(data : imageData)
        }
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
    }
    

    
}

extension ViewProfileViewController: ProfileDelegate {


    func didReceiveData(_ user: TutaUser) {
        self.user = user
        print("did receieve: " + self.user.description)
        ViewDescriptionTextView.text = self.user.description
        self.ViewPhoneNumberLabel.text = user.phone
        imgUrl = self.user.url
        if(imgUrl == ""){}
        else{
        imageData = try!Data(contentsOf: URL(string:imgUrl) ??  URL(fileURLWithPath: defaultProfile!))
        self.ViewPhotoImageView.image = UIImage(data : imageData)
        }
        self.ViewPhotoImageView.image = UIImage(data : imageData)
        self.ViewRatingLabel.text = "rating: " + String(self.user.rate)
        self.ViewNumberRateLabel.text =  String(self.user.numRate) + " rates"
        var courses : String = ""
        for item in self.user.courseTaken{
            courses = courses + item + " "
        }
        ViewCoursesTakenLabel.text = courses
//        print("did updated " + DescriptionText.text!)
    }

}
extension ViewProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

     func imagePickerController( _ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            ViewPhotoImageView.contentMode = .scaleAspectFit
            ViewPhotoImageView.image = pickedImage
        }
        
        picker.dismiss(animated: true, completion: nil)
         if ViewPhotoImageView.image != nil{
            dc.uploadProfilePic(img1: ViewPhotoImageView.image!, user: self.user){(url) in
                 self.imgUrl = (url)}
            print(self.imgUrl)
            print("upload a picture")
         }
    }
    
     func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

}
