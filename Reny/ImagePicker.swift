//
//  ImagePicker.swift
//
//
//  Created by Nat-Serrano on 8/16/22.
//
import SwiftUI
import PhotosUI

struct ImagePicker: UIViewControllerRepresentable {

    //@ObservedObject var imageController: ImageController
    @Binding var pickerResult: [UIImage]
    
    //to dismiss image picker selection...interesting is in the view model
    @Binding var showImagePicker: Bool
    
    //var configuration: PHPickerConfiguration
    
//    init(showImagePicker: Binding<Bool>) {
//        configuration = PHPickerConfiguration()
//        //I can change this to multiple to sleect more images
//        configuration.selectionLimit = 15
//        configuration.filter = .images
//
//        //self.imageController = imageController
//        //this is related to the binding var to dismiss sheet when pic is selected...what is the _?
//        self._showImagePicker = showImagePicker
//    }
    
    //methords to access ImagePicker using UIKIT UIViewcontrollerrepresentable
    //This method is used for creating the UIViewController we want to present
    func makeUIViewController(context: Context) -> PHPickerViewController {
//        let controller = PHPickerViewController(configuration: configuration)
//        controller.delegate = context.coordinator
//        return controller
        
        var configuration = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        configuration.filter = .images // filter only to images
        if #available(iOS 15, *) {
            configuration.selection = .ordered //number selection
        }
        configuration.selectionLimit = 10 // ignore limit
        
        let controller = PHPickerViewController(configuration: configuration)
        controller.delegate = context.coordinator
        return controller
    }
    
    //This method updates the UIViewController to the latest configuration every time it gets called
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        //empty on purpose
    }
    
    //This method initializes a Coordinator that serves as a kind of a servant for handling delegate and data source patterns and user inputs. We will talk about this in more detail later.
    func makeCoordinator() -> Coordinator {
        //calling the class below
        Coordinator(self)
    }
    
}

//subclass contains the necessary function our phpicker needs to retrieve the selected photo
class Coordinator: PHPickerViewControllerDelegate {
    
    private let parent: ImagePicker
    
    init(_ parent: ImagePicker) {
        self.parent = parent
    }
    
    func pickerOriginal(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
//        let itemProvider = results.first?.itemProvider
//
//        if let itemProvider = itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
//            itemProvider.loadObject(ofClass: UIImage.self) { image, error in
//                if let image = image as? UIImage {
////                    DispatchQueue.main.async {
////                        self.parent.imageController.unprocessedImage = image
////                    }
//                }
//            }
//        }
        
        var processedResults = [UIImage]()
        var leftToLoad = results.count
        let checkFinished = { [weak self] in
            leftToLoad -= 1
            if leftToLoad == 0 {
                    self?.parent.pickerResult = processedResults
                    self?.parent.showImagePicker = false
               
            }
        }
        
        for image in results {
            if image.itemProvider.canLoadObject(ofClass: UIImage.self) {
                image.itemProvider.loadObject(ofClass: UIImage.self) { newImage, error in
                    if let error = error {
                        print("Can't load image \(error.localizedDescription)")
                    } else if let image = newImage as? UIImage {
                        processedResults.append(image)
                    }
                    checkFinished()
                }
            } else {
                print("Can't load asset")
                checkFinished()
            }
        }
        
        //to dismiss the sheet
        parent.showImagePicker = false
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true, completion: nil)
            
            for result in results {
                
                result.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { (object, error) in

                    if let image = object as? UIImage {
                        DispatchQueue.main.async {
                            //let imv = self.newImageView(image: image)
                            self.parent.pickerResult.append(image)
//                            self.scrollView.addSubview(imv)
//                            self.view.setNeedsLayout()
                        }
                    }
                })
            }
        
        self.parent.showImagePicker = false
        
        
        }
}
