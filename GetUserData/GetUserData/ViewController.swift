//
//  ViewController.swift
//  GetUserData
//
//  Created by Teacher on 20.04.2021.
//

import UIKit
import PhotosUI

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,
                      PHPickerViewControllerDelegate, CLLocationManagerDelegate {

    private let imageView: UIImageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(imageView)
        imageView.contentMode = .scaleAspectFill

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap))
        view.addGestureRecognizer(tapGestureRecognizer)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        imageView.frame = view.bounds
    }

    @objc private func tap() {
//        showImagePicker()
//        showPHPicker()
        requestGeoLocation()
    }

    // MARK: - Image picker

    func showImagePicker() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .camera
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.editedImage] as? UIImage else { return }

        imageView.image = image
    }

    // MARK: - PHPicker

    func showPHPicker() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 3
        configuration.filter = .images
        let phPicker = PHPickerViewController(configuration: configuration)
        phPicker.delegate = self
        present(phPicker, animated: true)
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        results.enumerated().forEach { index, result in
            result.itemProvider.loadObject(ofClass: UIImage.self) { reading, error in
                if let error = error {
                    print("Error occured: \(error)")
                } else if let image = reading as? UIImage {
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(index * 3)) {
                        self.imageView.image = image
                    }
                }
            }
        }
    }

    // MARK: - Geolocation

    private var locationManager: CLLocationManager?

    private func requestGeoLocation() {
        let locationManager = CLLocationManager()
        self.locationManager = locationManager
        locationManager.delegate = self
        locationManager.desiredAccuracy = 300
        switch locationManager.authorizationStatus {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .authorizedAlways, .authorizedWhenInUse:
                locationManager.requestLocation()
            case .denied, .restricted:
                break
            @unknown default:
                break
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
            case .authorizedAlways, .authorizedWhenInUse:
                manager.requestLocation()
            default:
                break
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error)")
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last else { return }

        print("Your location is: \(lastLocation.coordinate)")
    }
}

