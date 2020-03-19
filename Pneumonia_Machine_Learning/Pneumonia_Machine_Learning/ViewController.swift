//
//  ViewController.swift
//  Pneumonia_Machine_Learning
//
//  Created by Austin Heisey on 3/9/20.
//  Copyright © 2020 Austin Heisey. All rights reserved.
//

import UIKit
import Vision
import CoreML

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var myPhoto: UIImageView!
    @IBOutlet weak var ResultLabel: UILabel!
    @IBOutlet weak var ImagePicker: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        detectImageContent()


    }

    func detectImageContent() {
        ResultLabel.text = "Thinking"
        
        guard let model = try? VNCoreMLModel(for: PneumoniaImageClassifier().model) else {
            fatalError("Failed to load model")
        }
        
        // Create a vision request
        
        let request = VNCoreMLRequest(model: model) {[weak self] request, error in
            guard let results = request.results as? [VNClassificationObservation],
                let topResult = results.first
                else {
                    fatalError("Unexpected results")
            }
            
            // Update the Main UI Thread with our result
            DispatchQueue.main.async { [weak self] in
                self?.ResultLabel.text = "\(topResult.identifier) with \(Int(topResult.confidence * 100))% confidence"
            }
        }
        
        guard let ciImage = CIImage(image: self.myPhoto.image!)
            else { fatalError("Cant create CIImage from UIImage") }
        
        // Run the googlenetplaces classifier
        let handler = VNImageRequestHandler(ciImage: ciImage)
        DispatchQueue.global().async {
            do {
                try handler.perform([request])
            } catch {
                print(error)
            }
        }
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
                   let imagePicker = UIImagePickerController()
                   imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
                   imagePicker.allowsEditing = false
                   self.present(imagePicker, animated: true, completion: nil)
               }
    }
    
    
    @IBAction func pickImage(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    private func imagePickerControllerDidCancel(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            myPhoto.contentMode = .scaleToFill
            myPhoto.image = pickedImage
        }
        picker.dismiss(animated: true, completion: nil)
        
        detectImageContent()
    }
    
}


