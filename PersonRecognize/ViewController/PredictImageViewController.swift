//
//  PredictImageViewController.swift
//  PersonRez
//
//  Created by Hồ Sĩ Tuấn on 11/09/2020.
//  Copyright © 2020 Hồ Sĩ Tuấn. All rights reserved.
//

import UIKit
import AVFoundation
import FaceCropper
import MBProgressHUD

class PredictImageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var mainImg: UIImageView!
    @IBOutlet weak var face1: UIImageView!
    @IBOutlet weak var face2: UIImageView!
    @IBOutlet weak var nameFace2: UILabel!
    @IBOutlet weak var nameFace1: UILabel!
    
    var corner:CGFloat = 35
    override func viewDidLoad() {
        super.viewDidLoad()
        clearData()
    }
    

    @IBAction func tapTakePhoto(_ sender: UIButton) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("Camera is not available.")
            return
        }
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.cameraFlashMode = UIImagePickerController.CameraFlashMode.off
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        clearData()
        present(imagePicker, animated: true, completion: nil)
    }
    
    func clearData() {
        face2.image = nil
        face2.image = nil
        nameFace1.text = ""
        nameFace2.text = ""
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let image = info[.editedImage] as? UIImage {
            print("this is image")
            self.mainImg.image = image
            
            image.face.crop { [self] res in
                switch res {
                case .success(let faces):
                    self.face1.image = faces[0]
                    self.face1.layer.cornerRadius = self.corner
                    let result = model.predict(image: faces[0].resized(smallestSide: 227)!)
                    let confidence = result.1! * 100
                    print(result)
                    if confidence >= 50 {
                        self.nameFace1.text = "\(userDict[result.0!]!): \(confidence.rounded() )%"
                    }
                    else {
                        self.nameFace1.text = "Unknown"
                    }
                    
                    if faces.count == 2 {
                        self.face2.image = faces[1]
                        self.face2.layer.cornerRadius = self.corner
                        let result = model.predict(image: faces[1])
                        let confidence = result.1! * 100
                        if confidence >= 560 {
                            self.nameFace2.text = "\(userDict[result.0!]!): \(confidence)%"
                        }
                        else {
                            self.nameFace2.text = "Unknown"
                        }
                    }
                case .notFound:
                    self.showDialog(message: "Not found any face!")
                case .failure(let error):
                    print("Error crop face: \(error)")
                }
            }
        }
    }
}