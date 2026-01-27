//
//  StartViewController.swift
//  VideoSDK_Example
//
//  Created by VideoSDK Team on 13/09/21.
//  Copyright © 2021 Zujo Tech Pvt Ltd. All rights reserved.
//

import AVFoundation
import UIKit
import VideoSDKRTC
import FirebaseCrashlytics

class StartViewController: UIViewController, AVAudioRecorderDelegate {
    
    // MARK: - Properties
    
    private var serverToken = ""
    var selectedMeetingMode: Mode = .SEND_AND_RECV
    var micEnabled: Bool = false
    var webCamEnabled: Bool = false
    var cameraPosition: AVCaptureDevice.Position = .front
    var deviceType: AVCaptureDevice.DeviceType = .builtInWideAngleCamera
    
    // MARK: - Outlets
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var meetingIdTextField: UITextField!
    @IBOutlet weak var copyMeetingIdButton: UIButton!
    @IBOutlet weak var nameDescriptionLabel: UILabel!
    @IBOutlet weak var startMeetingButton: UIButton!
    
    @IBOutlet weak var viewCameraViewContainer: UIView!
    
    @IBOutlet var viewVideoButton: UIView!
    @IBOutlet weak var imgVideoButton: UIImageView!
    @IBOutlet weak var btnVideoEnableDisable: UIButton!

    @IBOutlet weak var viewAudioButton: UIView!
    @IBOutlet weak var imgAudioButton: UIImageView!
    @IBOutlet weak var btnAudioEnableDisable: UIButton!
    @IBOutlet weak var createMeetingButton: UIButton!
    
    // New: Mode selection button
    @IBOutlet weak var modeButton: UIButton!
    
    //Camera Capture requiered properties
    var videoDataOutput: AVCaptureVideoDataOutput!
    var videoDataOutputQueue: DispatchQueue!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var captureDevice: AVCaptureDevice!
    var rootLayer: CALayer!
    let session = AVCaptureSession()
    var audioRecorder: AVAudioRecorder?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Crashlytics.crashlytics().setCustomValue("iOS", forKey: "platform")
        Crashlytics.crashlytics().setCustomValue("2.5.1", forKey: "sdk_version")
        
        setupUI()
        
        requestMicrophonePermission()
        
        self.serverToken = AUTH_TOKEN
        
        setupAudioSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopCamera()
        stopRecording()
    }

    // MARK: - Actions
    func joinMeeting() {
        nameTextField.resignFirstResponder()
        
        if !serverToken.isEmpty {
            // use provided token for the meeting
            self.startMeeting()
        }
        else if !AUTH_URL.isEmpty {
            // get auth token from server
            APIService.getToken { result in
                if case .success(let token) = result {
                    self.serverToken = token
                    self.startMeeting()
                }
            }
        }
        else {
            // show error popup
            self.showAlert(title: "Auth Token Required", message: "Please provide auth token to start the meeting.")
        }
    }
    
    
    // MARK: - Actions
    
    @IBAction func startMeetingButtonTapped(_ sender: Any) {
        if((meetingIdTextField.text ?? "").isEmpty){
            self.showAlert(title: "Meeting id Required", message: "Please provide meeting id to start the meeting.")
            meetingIdTextField.resignFirstResponder()
        } else {
            joinMeeting()
        }
    }
    
    @IBAction func copyMeetingIdButtonTapped(_ sender: Any) {
        guard let meetingId = meetingIdTextField.text, !meetingId.isEmpty else { return }
//        let meetingLink = "https://call.zujonow.com/meeting/\(meetingId)"
        let meetingLink = "\(meetingId)"
        
        UIPasteboard.general.string = meetingLink
        self.showAlert(title: "Link Copied", message: nil, autoDismiss: true)
    }
    
    @IBAction func onClickCreateMeeting(_ sender: UIButton) {
        APIService.createMeeting(token: AUTH_TOKEN) { result in
            if case .success(let meetingId) = result {
                self.meetingIdTextField.text = meetingId
                self.joinMeeting()
            } else if case .failure(let error) = result {
                self.showAlert(title: "Error while create meeting", message: "Create meeting failed :: \(error.localizedDescription)")
            } else {
                self.showAlert(title: "Create Meeting Failed", message: "Something went wrong!")
            }
        }
    }
    
    @IBAction func btnAudioEnableDisableTapped(_ sender: Any) {
        self.micEnabled = !self.micEnabled
        updateAudioButton(status: self.micEnabled)
    }

    @IBAction func btnVideoEnableDisableTapped(_ sender: Any) {
        self.webCamEnabled = !self.webCamEnabled
        updateVideoButton(status: self.webCamEnabled)
    }
    
    // New: Mode selection action
    @IBAction func modeButtonTapped(_ sender: UIButton) {
        let options: [(title: String, mode: Mode)] = [
            ("SEND_AND_RECV", .SEND_AND_RECV),
            ("RECV_ONLY", .RECV_ONLY),
            ("SIGNALLING_ONLY", .SIGNALLING_ONLY)
        ]
        
        let alert = UIAlertController(title: "Select Mode", message: nil, preferredStyle: .actionSheet)
        if let popover = alert.popoverPresentationController {
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
        }
        
        for option in options {
            let action = UIAlertAction(title: option.title, style: .default) { _ in
                self.selectedMeetingMode = option.mode
                self.updateModeButtonTitle()
            }
            if option.mode == selectedMeetingMode {
                action.setValue(true, forKey: "checked")
            }
            alert.addAction(action)
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    func updateVideoButton(status: Bool) {
        self.viewVideoButton.backgroundColor =
            status ? UIColor.white : UIColor.red
        self.imgVideoButton.image =
            status
            ? UIImage(systemName: "video.fill")
            : UIImage(systemName: "video.slash.fill")
        self.imgVideoButton.tintColor = status ? UIColor.black : UIColor.white
        self.viewCameraViewContainer.backgroundColor =
            status ? UIColor.clear : UIColor(named: "videoBackgroundColor")
        status ? self.startCamera() : self.stopCamera()
    }

    func updateAudioButton(status: Bool) {
        self.viewAudioButton.backgroundColor =
            status ? UIColor.white : UIColor.red
        self.imgAudioButton.image =
            status
            ? UIImage(systemName: "mic.fill")
            : UIImage(systemName: "mic.slash.fill")
        self.imgAudioButton.tintColor = status ? UIColor.black : UIColor.white
        DispatchQueue.global(qos: .userInitiated).async {
            if status {
                DispatchQueue.main.async {
                    self.startRecording()
                }
            } else {
                self.stopRecording()
            }
        }
    }
    
    private func updateModeButtonTitle() {
        let title: String
        switch selectedMeetingMode {
        case .SEND_AND_RECV: title = "Mode: SEND_AND_RECV"
        case .RECV_ONLY: title = "Mode: RECV_ONLY"
        case .SIGNALLING_ONLY: title = "Mode: SIGNALLING_ONLY"
        @unknown default: title = "Mode"
        }
        modeButton.setTitle(title, for: .normal)
    }
    
    // MARK: - Navigation
    
    func startMeeting() {
        DispatchQueue.main.async {
            self.dismiss(animated: true) {
                self.performSegue(withIdentifier: "StartMeeting", sender: nil)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let navigation = segue.destination as? UINavigationController,
              let meetingViewController = navigation.topViewController as? MeetingViewController else {
                  return
              }
        
        meetingViewController.meetingData = MeetingData(
            token: serverToken,
            name: nameTextField.text ?? "Guest",
            meetingId: meetingIdTextField.text ?? "",
            micEnabled: micEnabled,
            cameraEnabled: webCamEnabled,
            mode: selectedMeetingMode
        )
    }
}

extension StartViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if textField == nameTextField {
            meetingIdTextField.becomeFirstResponder()
        }
        return true
    }
}

extension StartViewController {
    
    func setupUI() {
        let attributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor : UIColor.gray
        ]
        
        nameTextField.attributedPlaceholder = NSAttributedString(string: "Enter Your Name", attributes: attributes)
        meetingIdTextField.attributedPlaceholder = NSAttributedString(string: "Enter Meeting ID", attributes: attributes)
        meetingIdTextField.text = ""
        
        nameTextField.text = ""
        
        copyMeetingIdButton.layer.borderWidth = 0.8
        copyMeetingIdButton.layer.borderColor = UIColor.darkGray.cgColor
        copyMeetingIdButton.layer.cornerRadius = 5
        copyMeetingIdButton.tintColor = UIColor.white
        
        [nameTextField, meetingIdTextField].forEach {
            $0?.layer.cornerRadius = 5
            $0?.layer.borderColor = UIColor.darkGray.cgColor
            $0?.layer.borderWidth = 0.8
            $0?.textColor = UIColor.white
            $0?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        }
        startMeetingButton.layer.cornerRadius = 5
        createMeetingButton.layer.cornerRadius = 5
        
        [viewAudioButton, viewVideoButton].forEach {
            $0?.roundCorners(corners: [.allCorners], radius: 22.0)
        }
        updateVideoButton(status: self.webCamEnabled)
        updateAudioButton(status: self.micEnabled)
        
        nameDescriptionLabel.text = "Your name will help everyone identify you in the meeting"
        nameDescriptionLabel.textColor = UIColor.darkGray
        nameDescriptionLabel.font = UIFont.systemFont(ofSize: 13)
        
        // Mode button styling
        modeButton.layer.cornerRadius = 5
        modeButton.layer.borderWidth = 0.8
        modeButton.layer.borderColor = UIColor.darkGray.cgColor
        modeButton.setTitleColor(.white, for: .normal)
        updateModeButtonTitle()
        
        setupAVCapture()
    }
    
    func requestMicrophonePermission() {
        AVAudioSession.sharedInstance().requestRecordPermission() { [weak self] allowed in
            DispatchQueue.main.async {
                if allowed {
                    print("Microphone access granted.")
                    self?.setupAudioRecorder()
                } else {
                    print("Microphone access denied. Cannot record.")
                }
            }
        }
    }
}

extension StartViewController: AVCaptureVideoDataOutputSampleBufferDelegate{
    
    func setupAVCapture() {
        session.stopRunning() // Stop the current session before reconfiguration
        
        // Remove all existing inputs and outputs
        session.inputs.forEach { session.removeInput($0) }
        session.outputs.forEach { session.removeOutput($0) }
        
        let facingMode = AVCaptureDevice.Position.front

        guard let device = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: facingMode
        ) else {
            return
        }

        captureDevice = device
        beginSession()
    }

    func beginSession(){
        var deviceInput: AVCaptureDeviceInput!
        do {
            deviceInput = try AVCaptureDeviceInput(device: captureDevice)
            guard deviceInput != nil else {
                print("error: cant get deviceInput")
                return
            }

            if self.session.canAddInput(deviceInput){
                self.session.addInput(deviceInput)
            }

            videoDataOutput = AVCaptureVideoDataOutput()
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            videoDataOutputQueue = DispatchQueue(label: "VideoDataOutputQueue")
            videoDataOutput.setSampleBufferDelegate(self, queue: self.videoDataOutputQueue)

            if session.canAddOutput(self.videoDataOutput){
                session.addOutput(self.videoDataOutput)
            }

            videoDataOutput.connection(with: .video)?.isEnabled = true

            previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
            previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            
            previewLayer.frame = viewCameraViewContainer.bounds
            previewLayer.cornerRadius = 12.0
            self.viewCameraViewContainer.layer.addSublayer(self.previewLayer)
        } catch let error as NSError {
            deviceInput = nil
            print("error: \(error.localizedDescription)")
        }
    }
    
    func startCamera() {
        guard !session.isRunning else {
            // ensure preview visible and on top
            DispatchQueue.main.async {
                self.previewLayer.isHidden = false
                [self.viewVideoButton, self.viewAudioButton].forEach {
                    self.viewCameraViewContainer.bringSubviewToFront($0)
                }
            }
            return
        }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            self.session.startRunning()
            DispatchQueue.main.async {
                self.previewLayer.isHidden = false
                [self.viewVideoButton, self.viewAudioButton].forEach {
                    self.viewCameraViewContainer.bringSubviewToFront($0)
                }
            }
        }
    }

    // clean up AVCapture
    func stopCamera(){
        if session.isRunning {
            session.stopRunning()
        }
        // Just hide the preview layer; do NOT call updateVideoButton here (avoids recursion)
        previewLayer?.isHidden = true
    }

    func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(
                .record,
                mode: .default,
                options: .allowBluetooth
            )
            try audioSession.setActive(true)
        } catch {
            print(
                "Failed to set up audio session: \(error.localizedDescription)"
            )
        }
    }

    func getTemporaryRecordingURL() -> URL {
        // Creates a unique temporary file URL each time
        let filename = UUID().uuidString + ".caf"
        return FileManager.default.temporaryDirectory.appendingPathComponent(
            filename
        )
    }

    func setupAudioRecorder() {
        let audioURL = getTemporaryRecordingURL()

        // Define recording settings
        let settings = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),  // Use uncompressed audio for speed
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
        ]

        do {
            audioRecorder = try AVAudioRecorder(
                url: audioURL,
                settings: settings
            )
            audioRecorder?.delegate = self
            audioRecorder?.prepareToRecord()  // Optimize recording hardware
        } catch {
            print(
                "Failed to set up audio recorder: \(error.localizedDescription)"
            )
        }
    }

    func startRecording() {
        if audioRecorder == nil {
            setupAudioRecorder()
        }
        audioRecorder?.record()
        // Optional: Update UI (e.g., disable start button, enable stop button)
    }

    func stopRecording() {
        audioRecorder?.stop()
        // The recorded file exists until we explicitly delete it
        if let url = audioRecorder?.url {
            deleteRecording(at: url)
        }
        audioRecorder = nil
    }

    func deleteRecording(at url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print(
                "Failed to delete temporary file: \(error.localizedDescription)"
            )
        }
    }

}

extension StartViewController {

    func stopSession() {
        if session.isRunning {
            session.stopRunning()
        }
    }

    func startSession() {
        DispatchQueue.global(qos: .background).async {
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }

    }

    func resetSession() {
        session.beginConfiguration()
        session.inputs.forEach { session.removeInput($0) }
        session.outputs.forEach { session.removeOutput($0) }
        session.commitConfiguration()
    }

    func AudioButtonLongPressed() {
        let longPressGesture = UILongPressGestureRecognizer(
            target: self,
            action: #selector(handleAudioLongPress(_:))
        )
        btnAudioEnableDisable.addGestureRecognizer(longPressGesture)
    }

    @objc func handleAudioLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            showAudioList()
        }
    }

    func showAudioList() {

        let devices = VideoSDK.getAudioDevices()
        let optionMenu = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )
        for device in devices {
            let action = UIAlertAction(title: device, style: .default) {
                handler in

            }
            optionMenu.addAction(action)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        optionMenu.addAction(cancelAction)

        present(optionMenu, animated: true, completion: nil)

    }

    func VideoButtonLongPressed() {
        let longPressGesture = UILongPressGestureRecognizer(
            target: self,
            action: #selector(handleVideoLongPress(_:))
        )
        btnVideoEnableDisable.addGestureRecognizer(longPressGesture)
    }

    @objc func handleVideoLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            showVideoList()
        }
    }

    func showVideoList() {

        let devices = VideoSDK.getCameras()
        let optionMenu = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )
        for device in devices {
            let action = UIAlertAction(title: device, style: .default) {
                UIAlertAction in
                self.handleVideoChange(device: device)
            }
            optionMenu.addAction(action)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        optionMenu.addAction(cancelAction)

        present(optionMenu, animated: true, completion: nil)
    }

    func handleVideoChange(device: String) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            self.stopCamera()

            self.cameraPosition =
                device.lowercased().contains("back") ? .back : .front

            DispatchQueue.main.async {
                self.setupAVCapture()
                self.startCamera()
            }
        }
    }

}
