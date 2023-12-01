import UIKit
import AVFoundation
import Photos
import CoreMotion



class cameraViewController : UIViewController,AVCapturePhotoCaptureDelegate,UIGestureRecognizerDelegate {

var cameraView : UIView!
var captureButton: UIButton!
var cameraSwitchButton: UIButton!
var flashModeButton: UIButton!
var backCamera: AVCaptureDevice!
var currentCamera: AVCaptureDevice!
var ultraWideCamera: AVCaptureDevice!
let captureSession = AVCaptureSession()
var stillImageOutput: AVCapturePhotoOutput!
var previewLayer: AVCaptureVideoPreviewLayer!
var currentZoomFactor: CGFloat = 1.0
var maxZoomFactor: CGFloat = 5.0
var zoomStep: CGFloat = 1.0
var currentFlashMode: AVCaptureDevice.FlashMode = .auto // set flash mode on auto
var isFlashOn: Bool = false
var focusPoint = CGPoint(x: 0.5, y: 0.5)
var boxView: UIView!
var exposureSlider: UISlider!
var currentExposureBias: Float?
var currentFocusLevel: Float = 0.0
var motionManager: CMMotionManager!
var yawAngle: Double = 0.0
var aspectControll : UISegmentedControl! // segment controll for select a aspect ratio
var currentAspectRatio: AVCaptureSession.Preset = .photo // set default aspet ratio on capture session
    var currentExposureValue: Float = 0.0
var timerButton : UIButton!
var timerDuration: TimeInterval = 0
var timerLabel: UILabel!
var timer : Timer?

var styleButton : UIButton!
var levelView: UIView!
var tolerance : CGFloat = 4.0
var straightAngle: CGFloat =  0.0

var wideControll : UISegmentedControl!
var switchButton : UIButton!
var homeButton : UIButton!
   
//var previousSliderValue: Float = 0.0
var gridOverlayView: UIView!
    




override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationController?.navigationItem.hidesBackButton = true

 
   

     
       
    setupCameraView()
    setupCamera()
    setupButtons()
    setupBoxView()
    setupExposureSlider()
    setupGestures()
    setupMotionManager()
    setupLevelView()
    gridOverlayView = UIView()
    gridOverlayView.backgroundColor = UIColor.clear
    gridOverlayView.isUserInteractionEnabled = false // Make sure it doesn't interfere with user interactions

    // Customize grid line appearance
    let gridLineWidth: CGFloat = 0.5
    let gridColor = UIColor.white.withAlphaComponent(0.5)

    // Add vertical grid lines
    for i in 1...3 {
        let verticalLine = UIView()
        verticalLine.backgroundColor = gridColor
        verticalLine.frame = CGRect(x: cameraView.frame.width / 3 * CGFloat(i), y: 0, width: gridLineWidth, height: cameraView.frame.height)
        gridOverlayView.addSubview(verticalLine)
    }

    // Add horizontal grid lines
    for i in 1...3 {
        let horizontalLine = UIView()
        horizontalLine.backgroundColor = gridColor
        horizontalLine.frame = CGRect(x: 0, y: cameraView.frame.height / 3 * CGFloat(i), width: cameraView.frame.width, height: gridLineWidth)
        gridOverlayView.addSubview(horizontalLine)
    }

    // Add the grid overlay view to the camera view
    cameraView.addSubview(gridOverlayView)

    // Set up constraints
    gridOverlayView.translatesAutoresizingMaskIntoConstraints = false
   
       
}
    
 
    







override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)

    coordinator.animate(alongsideTransition: { _ in
        self.previewLayer?.connection?.videoOrientation = self.currentVideoOrientation()
        self.previewLayer?.frame = self.cameraView.bounds
    }, completion: nil)
}


override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      captureSession.startRunning()
    
   // self.navigationController?.navigationItem.hidesBackButton = true
  }

  override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      captureSession.stopRunning()
  }

 func toggleButtonsVisibility(_ shouldHide: Bool) {
    DispatchQueue.main.async {
     
        self.flashModeButton?.isHidden = shouldHide
        self.aspectControll?.isHidden = shouldHide
        self.timerButton?.isHidden = shouldHide
        self.timerLabel?.isHidden = shouldHide
        self.styleButton?.isHidden = shouldHide
        self.wideControll?.isHidden = shouldHide
    }
}
   

func setupLevelView() {
    levelView = UIView(frame: CGRect(x: 0, y: 0, width: cameraView.frame.width, height: 2))
    levelView.backgroundColor = UIColor.red
 cameraView.addSubview(levelView)
    levelView.translatesAutoresizingMaskIntoConstraints = false
    
 

    // Adding center constraints for the levelView
  NSLayoutConstraint.activate([
        levelView.centerXAnchor.constraint(equalTo: cameraView.centerXAnchor),
        levelView.centerYAnchor.constraint(equalTo: cameraView.centerYAnchor),
        levelView.widthAnchor.constraint(equalTo: cameraView.widthAnchor, multiplier: 1.0),
        levelView.heightAnchor.constraint(equalToConstant: 2)
    ])
}
  
    func setupCameraView() {
        cameraView = UIView()
    

      
     cameraView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cameraView)
      NSLayoutConstraint.activate([
            cameraView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cameraView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cameraView.topAnchor.constraint(equalTo: view.topAnchor),
            cameraView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }


    func setupCamera() {
   // captureSession = AVCaptureSession()
     //  captureSession.sessionPreset = currentAspectRatio
    
        guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
        self.backCamera = backCamera

        guard let ultraWideCamera = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) else { return }
        self.ultraWideCamera = ultraWideCamera

       currentCamera = backCamera
        
        do {
            let input = try AVCaptureDeviceInput( device: currentCamera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            
            stillImageOutput = AVCapturePhotoOutput() // Initialize it as an AVCapturePhotoOutput
            if captureSession.canAddOutput(stillImageOutput) { // Unwrap the optional
                captureSession.addOutput(stillImageOutput)
            }
            
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.videoGravity = .resizeAspectFill
            previewLayer.frame = cameraView.bounds
    
     
          cameraView.layer.addSublayer(self.previewLayer)
     


            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()
            }
        } catch {
            print("Error setting up camera: \(error)")
        }
        
    }
    
    @objc func wideAngleValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            // Switch to wide-angle camera
            switchCamera(to: backCamera)
        } else {
            // Switch to ultra-wide-angle camera
            switchCamera(to: ultraWideCamera)
        }
    }

    func switchCamera(to newCamera: AVCaptureDevice) {
        captureSession.beginConfiguration()
        
        // Remove the existing input
        guard let currentInput = captureSession.inputs.first as? AVCaptureDeviceInput else { return }
        captureSession.removeInput(currentInput)
        
        // Add the input for the new camera
        do {
            let newInput = try AVCaptureDeviceInput(device: newCamera)
            if captureSession.canAddInput(newInput) {
                captureSession.addInput(newInput)
                currentCamera = newCamera
            } else {
                print("Could not add input for the new camera.")
            }
        } catch {
            print("Error setting up the input for the new camera: \(error)")
        }
        
        captureSession.commitConfiguration()
    }

        
    func updateCountdownLabel(_ secondsRemaining: Int) {
        DispatchQueue.main.async {
            self.timerLabel.text = "\(secondsRemaining)s"
        }
    }
    
    @objc func switchCameraButtonTapped(_ sender: UIButton) {
        frontback()
    }
    
    
        func frontback() {
            
            guard let currentCameraInput = captureSession.inputs.first as? AVCaptureDeviceInput else {
                print("Unable to access the camera.")
                return
            }
            
         var  newCamera: AVCaptureDevice?
            var newCameraPosition: AVCaptureDevice.Position = .unspecified
            
            if currentCameraInput.device.position == .back {
                newCameraPosition = .front
                wideControll.isHidden = true
            } else {
                newCameraPosition = .back
                wideControll.isHidden = false
            }
            
            if let newCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newCameraPosition) {
                newCamera = newCameraDevice
            } else {
                print("Failed to get the new camera.")
                return
            }

            
            if let newCamera = newCamera {
                do {
                    let newInput = try AVCaptureDeviceInput(device: newCamera)
                    
                    captureSession.beginConfiguration()
                    captureSession.removeInput(currentCameraInput)
                    
                    if captureSession.canAddInput(newInput) {
                        captureSession.addInput(newInput)
                    } else {
                        captureSession.addInput(currentCameraInput)
                    }
                    
                    captureSession.commitConfiguration()
                    currentZoomFactor = 1.0
                    updateZoomFactor(currentZoomFactor)
                } catch {
                    print("Error switching camera: \(error)")
                }
            }
        }
        
        func startCountdown(duration: TimeInterval) {
            timerDuration = duration
            var secondsRemaining = Int(duration)
            updateCountdownLabel(secondsRemaining)
            
            timer?.invalidate() // Invalidate any existing timers
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
                guard let self = self else { return }
                
                secondsRemaining -= 1
                updateCountdownLabel(secondsRemaining)
                
                if secondsRemaining <= 0 {
                    timer.invalidate() // Stop the timer when the countdown is complete
                    capturePhoto(self.timerButton) // Call your capture photo function here
                }
            }
        }
    
    // Function to stop the countdown timer
    func stopCountdown() {
        timer?.invalidate()
        timerLabel.text = " "
        timerDuration = 0
    }
    func setSquareAspectRatio() {
        let previewLayerHeight = UIScreen.main.bounds.width
        let yOffset = (UIScreen.main.bounds.height - previewLayerHeight) / 2.0
        previewLayer.frame = CGRect(x: 0, y: yOffset, width: UIScreen.main.bounds.width, height: previewLayerHeight)
    }
    
    func changeAspectRatio(preset: AVCaptureSession.Preset) {
        captureSession.beginConfiguration()
        captureSession.sessionPreset = preset
        captureSession.commitConfiguration()

        // Adjust the preview layer frame based on the new aspect ratio
        DispatchQueue.main.async {
            let previewLayerHeight: CGFloat
            let yOffset: CGFloat

            switch preset {
            case .photo: // 4:3
                previewLayerHeight = UIScreen.main.bounds.width * 4 / 3
                yOffset = (UIScreen.main.bounds.height - previewLayerHeight) / 2.0

            case .high: // 16:9
                previewLayerHeight = UIScreen.main.bounds.width * 16 / 9
                yOffset = (UIScreen.main.bounds.height - previewLayerHeight) / 2.0

            default:
                return
            }

            self.previewLayer.frame = CGRect(x: 0, y: yOffset, width: UIScreen.main.bounds.width, height: previewLayerHeight)
        }
    }
    @objc func segmentControllValueChanged(_ sender: UISegmentedControl) {
        
       // resetPreviewFrame()
        
        switch aspectControll?.selectedSegmentIndex {
            
        case 0:
            changeAspectRatio(preset: .photo)
        case 1:
           // currentAspectRatio = .hd4K3840x2160
            changeAspectRatio(preset: .high)
        case 2:
            
          //  changeAspectRatio(preset: .square)
       setSquareAspectRatio()
        //applySquareCropPreview()
        default:
            break
        }
       
    }
    

      func applySquareCropPreview() {
            // Calculate the square frame for your preview layer
            let squareSize = min(cameraView.bounds.width, view.bounds.height)
            let xOffset = (cameraView.bounds.width - squareSize) / 2
            let yOffset = (cameraView.bounds.height - squareSize) / 2
            let squareFrame = CGRect(x: xOffset, y: yOffset, width: squareSize, height: squareSize)
            
            // Apply square crop to the preview
            // previewLayer.videoGravity = .resizeAspectFill
            previewLayer.frame = squareFrame
            
        }




    func updateLevelView() {
        guard let motion = motionManager.deviceMotion else {return}
        let attitude = motion.attitude
        let roll = attitude.roll * 180.0 / .pi // convert roll to degrees

        //calculate the device's yaw angle relative to reference vector
        let referenceVector =  CGVector(dx: 0, dy: -1)
        let deviceTopVector = CGVector(dx: CGFloat(cos(-attitude.yaw)), dy: CGFloat(sin(-attitude.yaw)))

        let angle = atan2(deviceTopVector.dy, deviceTopVector.dx) - atan2(referenceVector.dy, referenceVector.dx)
        var angleInDegrees = angle * 180.0 / .pi
        if angleInDegrees < 0 {
            angleInDegrees += 360.0
        }

        //convert roll to radians for rotation
        let rotationAngle = CGFloat(roll) * .pi / 180

        // apply the rotation to the level view
        levelView?.transform = CGAffineTransform(rotationAngle: rotationAngle)

        // Print the frame and bounds values for debugging
      //  print("Level view frame: \(levelView.frame)")
        //print("Level view bounds: \(levelView.bounds)")
        
        let tolerance: CGFloat = 3.0 // Tolerance value for checking center and straight
        let _: CGFloat = 0.0 // Assuming 0 degrees is straight

        if abs(levelView.center.x - view.center.x) <= tolerance && abs(levelView.center.y - view.center.y) <= tolerance && abs(roll) <= tolerance {
            levelView.backgroundColor = .green
           // levelView.isHidden = true// If centered and straight, set to white
        } else {
            levelView.backgroundColor = .red
           // levelView.isHidden = false
           // Otherwise, set to red
        }
  //  print("angle of level view: \(angleInDegrees)")

    }
 
    
    @objc func timerButtonTapped(_ sender: UIButton) {
        // Toggle between off, 3s, and 10s timer modes
        switch timerDuration {
        case 0:
            timerDuration = 3
            sender.setTitle("3s", for: .normal)
            
        case 3:
            timerDuration = 10
            sender.setTitle("10s", for: .normal)
            
        case 10:
            timerDuration = 0
            sender.setTitle("Off", for: .normal)
            
        default:
            break
        }
        
    }
  
  
    
    
    
    func currentVideoOrientation() -> AVCaptureVideoOrientation {
        let orientation = UIDevice.current.orientation
        switch orientation {
        case .portrait:
            return .portrait
        case .landscapeLeft:
            return .landscapeRight
        case .landscapeRight:
            return .landscapeLeft
        case .portraitUpsideDown:
            return .portraitUpsideDown
        default:
            return .portrait
        }
    }
   


    func setupMotionManager() {
        motionManager = CMMotionManager()
      //  motionManager.deviceMotionUpdateInterval = 0.1 // Adjust as needed
        
        if motionManager.isDeviceMotionAvailable {
            motionManager.startDeviceMotionUpdates(to: .main) { [weak self] (motion, error) in
                guard let self = self, let motion = motion else { return }
                
                let attitude = motion.attitude
                _ = attitude.roll * 180.0 / .pi
                _ = attitude.pitch * 180.0 / .pi
                _ = attitude.yaw * 180.0 / .pi
                
                // Calculate the angle between the device's top vector and a reference vector
                let referenceVector = CGVector(dx: 0, dy: -1) // For example, pointing upwards
                let deviceTopVector = CGVector(dx: CGFloat(cos(-attitude.yaw)), dy: CGFloat(sin(-attitude.yaw)))
                let angle = atan2(deviceTopVector.dy, deviceTopVector.dx) - atan2(referenceVector.dy, referenceVector.dx)
                
                // Convert the angle to the range of 0 to 359 degrees
                var angleInDegrees = angle * 180.0 / .pi
                if angleInDegrees < 0 {
                    angleInDegrees += 360.0
                }
                
                self.updateLevelView()
                
                // Store the angle value for further use
                self.yawAngle = angleInDegrees
            }
        } else {
            print("Device motion data is not available.")
        }
    }
   

    @objc func handlePinchGesture(_ recognizer: UIPinchGestureRecognizer) {
        guard AVCaptureDevice.default(for: .video) != nil else {
            print("Unable to access the camera.")
            return
        }
        
        if recognizer.state == .changed {
            var zoomFactor = recognizer.scale * currentZoomFactor
            zoomFactor = max(1.0, min(zoomFactor, maxZoomFactor))
            _ = round(zoomFactor / zoomStep) * zoomStep
            updateZoomFactor(zoomFactor)
        }
    }
    
  
    
    
    @objc func capturePhoto(_ sender: UIButton) {
        // Check if the timer is set and start the countdown
        if timerDuration > 0 {
            // Disable the capture button during the countdown
            captureButton.isEnabled = false
            
            // Start the countdown timer
            var countdown = timerDuration
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                countdown -= 1
                if countdown <= 0 {
                    // Capture the photo when the countdown reaches 0
                    self.captureImage()
                    timer.invalidate() // Stop the timer
                    // Reset the capture button title and enable the button
                    DispatchQueue.main.async {
                        
                        self.captureButton.isEnabled = true
                        
                        self.timerLabel.isHidden = true
                    }
                } else {
                    // Update the capture button title to show the countdown
                    self.updateCountdownLabel(Int(countdown))
                }
            }
            // Display the countdown label
            // Start the timer immediately
            timerLabel.isHidden = false
            timer?.fire()

        }
         else {
            // If no timer is set, capture the photo immediately
            captureImage()
        }
    }

    

     @objc func captureImage() {
      let settings = AVCapturePhotoSettings()
       if isFlashOn {
            settings.flashMode = .on
        } else {
            settings.flashMode = .off
        }


       
         stillImageOutput?.capturePhoto(with: settings, delegate: self)
        _ = motionManager.deviceMotion?.attitude.yaw ?? 0.0
    }
    

    
    @objc func flashButtonPressed(_ sender: UIButton) {
      isFlashOn = !isFlashOn
        //  toggleFlash()
        
        // Change button title based on flash state
        let image = isFlashOn ? "bolt.fill" : "bolt.slash.fill"
        flashModeButton.setImage(UIImage(systemName: image)?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation() else {
            print("Error getting photo data.")
            return
        }
        
        if let image = UIImage(data: imageData) {
            savePhotoToLibrary(image)
            
       
        }
    }
    
    
    func savePhotoToLibrary(_ image: UIImage) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                print("Photo library access not authorized.")
                return
            }
            
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            } completionHandler: { [self] success, error in
                if let error = error {
                    print("Error saving photo to library: \(error)")
                } else {
                    print("Photo saved to library successfully.")
                    print("Zoom Level: \(self.currentZoomFactor)")
                    print("Exposure Value: \(currentExposureValue)")
                    print("Focus Level: \(currentFocusLevel)")
                    print ("Flash mode :\(currentFlashMode)")
                 //   print("Current Aspect Ratio :\(currentAspectRatio)")
                  
                    
                
                    let jsonDict: [String: Any] = [
                                       "Zoom Level": self.currentZoomFactor,
                                       "Exposure Value": self.currentExposureBias ?? 0.0,
                                       "Focus Level": self.currentFocusLevel,
                                     //  "Final Angle Of Picture": finalAngle,
                                       //"Current Aspect Ratio": currentAspectRatio
                                   ]
                                   
                                   // Convert the dictionary to JSON data
                                   if let jsonData = try? JSONSerialization.data(withJSONObject: jsonDict, options: []) {
                                       if let jsonString = String(data: jsonData, encoding: .utf8) {
                                           print("JSON String: \(jsonString)")
                                        
                      }
                   }
                }
            }
        }
    }

  
    
    
    func updateZoomFactor(_ zoomFactor: CGFloat) {
        currentZoomFactor = zoomFactor
        
        guard let activeCamera = AVCaptureDevice.default(for: .video) else {
            print("Unable to access the camera.")
            return
        }
        
        do {
            try activeCamera.lockForConfiguration()
            defer { activeCamera.unlockForConfiguration() }
            
            // Check if the active camera supports zooming
            if activeCamera.position == .front {
                // Front camera zoom factor may have limitations, so set the zoom factor to 1.0
                activeCamera.videoZoomFactor = 1.0
            } else if activeCamera.activeFormat.videoMaxZoomFactor > 1.0 {
                let maxZoomFactor = min(maxZoomFactor, activeCamera.activeFormat.videoMaxZoomFactor)
                let scaledZoomFactor = max(1.0, min(zoomFactor, maxZoomFactor))
                
                activeCamera.videoZoomFactor = scaledZoomFactor
            } else {
                print("Zoom is not supported for the active camera.")
            }
        } catch {
            print("Error updating zoom factor: \(error)")
        }
    }
    

    @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
            let point = recognizer.location(in: cameraView)
            showFocusBox(at: point)
            updateFocus(at: point,isCloseDepth: true)
            // Check if the tap is on the right side of the focus box
            _ = boxView.frame.origin.x + boxView.frame.size.width / 2
           
        }
    }
  

    
    func updateCustomFocusAndExposure(at point: CGPoint) {
        guard let backCamera = AVCaptureDevice.default(for: .video) else {
            print("Unable to access the camera.")
            return
        }
        
        do {
            try backCamera.lockForConfiguration()
            defer { backCamera.unlockForConfiguration() }
            
            // Convert the point from the camera view's coordinate system to the preview layer's coordinate system
            let convertedPoint = previewLayer.captureDevicePointConverted(fromLayerPoint: point)
            
            // Update the custom focus and exposure points
            if backCamera.isFocusModeSupported(.autoFocus) && backCamera.isFocusPointOfInterestSupported {
                backCamera.focusMode = .autoFocus
                backCamera.focusPointOfInterest = convertedPoint
            }
            
            if backCamera.isExposureModeSupported(.autoExpose) && backCamera.isExposurePointOfInterestSupported {
                backCamera.exposureMode = .autoExpose
                backCamera.exposurePointOfInterest = convertedPoint
            }
        } catch {
            print("Error updating custom focus and exposure: \(error)")
        }
    }
    
  
    func showFocusBox(at point: CGPoint) {
        _ = previewLayer.captureDevicePointConverted(fromLayerPoint: point)
        
        // Calculate the rect for the focus box centered at the given point
        let boxSize: CGFloat = 100.0
        let boxRect = CGRect(x: point.x - boxSize / 2, y: point.y - boxSize / 2, width: boxSize, height: boxSize)
        
        // Update the box view's position and show it
        boxView.frame = boxRect
        boxView.isHidden = false
        
        // Hide the box after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.boxView.isHidden = true
        }
    }
    @objc func exposureSliderValueChanged(_ slider: UISlider) {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        
        do {
            try device.lockForConfiguration()
            let exposureValue = slider.value
            let minExposure = device.minExposureTargetBias
            let maxExposure = device.maxExposureTargetBias
            let newExposure = min(max(exposureValue, minExposure), maxExposure)
            
            device.setExposureTargetBias(newExposure, completionHandler: nil)
            currentExposureValue = newExposure
            device.unlockForConfiguration()
        } catch {
            print(error.localizedDescription)
        }
    }
    
 
    func calculateFocusLevel(_ focusValue:  Float, for device: AVCaptureDevice) -> Float{
        let maxFocusValue = device.maxExposureTargetBias
        let minFocusValue = device.minExposureTargetBias
        return (focusValue - minFocusValue) / (maxFocusValue - minFocusValue)
    }
    
    func updateFocus(at point: CGPoint, isCloseDepth: Bool = false) {
        guard let backCamera = AVCaptureDevice.default(for: .video) else {
            print("Unable to access the camera.")
            return
        }
        
        do {
            try backCamera.lockForConfiguration()
            defer { backCamera.unlockForConfiguration() }
            
            let convertedPoint = previewLayer.captureDevicePointConverted(fromLayerPoint: point)
            
            if backCamera.isFocusPointOfInterestSupported {
                backCamera.focusPointOfInterest = convertedPoint
            }
            
            if backCamera.isFocusModeSupported(.continuousAutoFocus) {
                backCamera.focusMode = isCloseDepth ? .autoFocus : .continuousAutoFocus
                
                currentFocusLevel = calculateFocusLevel(backCamera.exposureTargetBias, for: backCamera)
            }
        } catch {
            print("Error updating focus: \(error)")
        }
    }
   
        
    
    func updateExposure2(_ value: Float) {
        if let backCamera = AVCaptureDevice.default(for: .video) {
            do {
                try backCamera.lockForConfiguration()

                // Calculate the relative exposure target bias within the valid range
                let minExposure = backCamera.minExposureTargetBias
                let maxExposure = backCamera.maxExposureTargetBias

                // Clamp the value to the valid range
                let clampedValue = min(maxExposure, max(minExposure, value))

                let relativeExposureValue = minExposure + (maxExposure - minExposure) * clampedValue

                // Set the exposure bias
                backCamera.setExposureTargetBias(relativeExposureValue) { _ in
                    // Ensure UI updates are performed on the main thread
                    DispatchQueue.main.async {
                        // Handle UI updates or perform any other actions related to exposure value
                    }
                }

                backCamera.unlockForConfiguration()
            } catch {
                print("Error updating exposure configuration: \(error)")
            }
        }
    }

            
        func setupButtons() {
            //CaptureButton
            let symbolconfig = UIImage.SymbolConfiguration(pointSize: 40)
            let cameraImage = UIImage(systemName: "circle.circle.fill", withConfiguration: symbolconfig)?
            .withTintColor(.white, renderingMode: .alwaysOriginal)
            captureButton = UIButton(type: .system) // Use custom button type
            captureButton.setImage(cameraImage, for: .normal)
       
            captureButton.translatesAutoresizingMaskIntoConstraints = false
           
       
            captureButton.addTarget(self, action: #selector(capturePhoto(_:)), for: .touchUpInside)
            view.addSubview(captureButton)
            
            
            //CameraSwitch
            
            let cameraswitchImage = UIImage(systemName: "arrow.triangle.2.circlepath.camera")?.withTintColor(.white, renderingMode: .alwaysOriginal)
            cameraSwitchButton = UIButton(type: .system)
            cameraSwitchButton.setImage(cameraswitchImage, for: .normal)
            cameraSwitchButton.translatesAutoresizingMaskIntoConstraints = false
            cameraSwitchButton.setTitleColor(.white, for: .normal)
            cameraSwitchButton.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
         
          
            cameraSwitchButton.addTarget(self, action: #selector(switchCameraButtonTapped(_:)), for: .touchUpInside)
            view.addSubview(cameraSwitchButton)
            
            
            //FlashMode
            let flashimage = UIImage(systemName: "bolt.slash.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal)
            flashModeButton = UIButton(type: .system)
            flashModeButton.setImage(flashimage, for: .normal)
            flashModeButton.translatesAutoresizingMaskIntoConstraints = false
            flashModeButton.setTitleColor(.white, for: .normal)
            flashModeButton.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            flashModeButton.addTarget(self, action: #selector(flashButtonPressed(_:)), for: .touchUpInside)
            view.addSubview(flashModeButton)
            
            
            
            aspectControll = UISegmentedControl(items: ["4:3","16:9","1:1"])
            aspectControll.frame = CGRect(x: 50, y: 100, width: 300, height: 40)
            aspectControll.selectedSegmentIndex = 1
            aspectControll.clipsToBounds = true
            aspectControll.layer.masksToBounds = true
            aspectControll.layer.borderColor = UIColor.white.cgColor
            aspectControll.addTarget(self, action: #selector(segmentControllValueChanged(_:)), for: .valueChanged)
            aspectControll.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(aspectControll)
            
           
            let timerimage = UIImage(systemName: "gauge.with.needle")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        
            timerButton = UIButton(type: .system)
            timerButton.setImage(timerimage, for: .normal)
            timerButton.translatesAutoresizingMaskIntoConstraints = false
            timerButton.transform = CGAffineTransform(scaleX: 1, y: 1)
            timerButton.addTarget(self, action: #selector(timerButtonTapped(_: )), for: .touchUpInside)
            view.addSubview(timerButton)
            
            
            timerLabel = UILabel()
            timerLabel.translatesAutoresizingMaskIntoConstraints = false
            timerLabel.text = ""
            timerLabel.textColor = .white
            timerLabel.textAlignment = .center
            timerLabel.font = UIFont.systemFont(ofSize: 24)
            view.addSubview(timerLabel)

            
            
          
            
            
            wideControll = UISegmentedControl(items: ["1x", "0.5"])
            wideControll.translatesAutoresizingMaskIntoConstraints = false
            wideControll.selectedSegmentIndex = 0 // Select the default segment
            wideControll.addTarget(self, action: #selector(wideAngleValueChanged(_:)), for: .valueChanged)
            view.addSubview(wideControll)
            
            
         
         
               
            
      
            
            NSLayoutConstraint.activate([
                captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                captureButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
               // captureButton.widthAnchor.constraint(equalToConstant: captureButtonWidth),
                captureButton.heightAnchor.constraint(equalTo: captureButton.widthAnchor),
                
         
                 flashModeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20), // Align to the right edge
                 flashModeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 60), // Align the top with cameraSwitchButton's top
                 flashModeButton.widthAnchor.constraint(equalToConstant: 50),
                 flashModeButton.heightAnchor.constraint(equalToConstant: 50),
                
         

                
                  aspectControll.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                  aspectControll.centerYAnchor.constraint(equalTo: view.bottomAnchor,constant: -130 ),
                
                
                 cameraSwitchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20), // 20 points from the right edge
              cameraSwitchButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),   // 20 points from the bottom edge
             cameraSwitchButton.widthAnchor.constraint(equalToConstant: 80), // Set the desired width
               cameraSwitchButton.heightAnchor.constraint(equalToConstant: 40),
                //cameraSwitchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
          //  cameraSwitchButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                
             timerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -300),
               timerButton.bottomAnchor.constraint(equalTo: cameraSwitchButton.bottomAnchor),
              timerButton.widthAnchor.constraint(equalToConstant: 50),
         timerButton.heightAnchor.constraint(equalToConstant: 50),
               timerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
       timerLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                
      
        
                  wideControll.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                  wideControll.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -185)

                
            ])
            
            
        }
        
        func setupBoxView() {
            
            boxView = UIView()
            boxView.translatesAutoresizingMaskIntoConstraints = false
            boxView.layer.borderWidth = 2.0
            boxView.layer.borderColor = UIColor.yellow.cgColor
            boxView.isHidden = true
            view.addSubview(boxView)
            
        }
        
    func setupExposureSlider( ) {
            exposureSlider = UISlider()
            exposureSlider.translatesAutoresizingMaskIntoConstraints = false
            exposureSlider.minimumValue = -5.0 // Set the minimum exposure value you want
            exposureSlider.maximumValue = 5.0// Set the maximum exposure value you want
      
            exposureSlider.value = 0.0 // Set the initial exposure value
            exposureSlider.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            exposureSlider.addTarget(self, action: #selector(exposureSliderValueChanged(_:)), for: .valueChanged)
            exposureSlider.minimumTrackTintColor = .yellow
            exposureSlider.maximumTrackTintColor = .white
            view.addSubview(exposureSlider)
            
            let thumbImage = UIImage(systemName: "sun.max.fill" )?.withTintColor(.yellow, renderingMode: .alwaysOriginal)
        
               let thumbSize = CGSize(width: 40, height: 40)
               
               // Resize the thumb image
               let resizedThumbImage = thumbImage?.resize(targetSize: thumbSize)
               
               // Set the thumb image for the slider
               exposureSlider.setThumbImage(resizedThumbImage, for: .normal)

      
     
      
            
                NSLayoutConstraint.activate([
                    
                           exposureSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                           exposureSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                           exposureSlider.bottomAnchor.constraint(equalTo: view.topAnchor, constant: 120),
                           exposureSlider.heightAnchor.constraint(equalToConstant: 40.0) // Set the desired height of the slider

            ])
            
          view.bringSubviewToFront(exposureSlider)
        }
        
        
        
        
        func setupGestures() {

            let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
          view.addGestureRecognizer(pinchGesture)
            pinchGesture.delegate = self
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
           view.addGestureRecognizer(tapGesture)
            tapGesture.delegate = self
         view.isUserInteractionEnabled = true
        

            
            
        }
    }
extension UIImage {
    func resize(targetSize: CGSize) -> UIImage {
        let size = self.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let newSize = widthRatio > heightRatio ?
            CGSize(width: size.width * heightRatio, height: size.height * heightRatio) :
            CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? self
    }
}

