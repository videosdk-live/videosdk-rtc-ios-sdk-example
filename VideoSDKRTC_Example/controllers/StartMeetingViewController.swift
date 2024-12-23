//
//  StartMeetingViewController.swift
//  VideoSDKRTC_Example
//
//  Created by Parth Asodariya on 11/01/23.
//

import UIKit
import AVFoundation
import VideoSDKRTC

class StartMeetingViewController: UIViewController {
    
    // MARK: - Properties
    let meetingVC = MeetingViewController()

    private var serverToken = ""
    var micEnabled: Bool = false
    var webCamEnabled: Bool = false
    
    // MARK: - Outlets
    
    @IBOutlet weak var viewCameraViewContainer: UIView!
    @IBOutlet weak var viewAudioButton: UIView!
    @IBOutlet weak var imgAudioButton: UIImageView!
    @IBOutlet weak var imgVideoButton: UIImageView!
    @IBOutlet weak var viewVideoButton: UIView!
    @IBOutlet weak var viewTestAudioVideoContainer: UIView!
    @IBOutlet weak var viewCreateAMeetingButton: UIView!
    @IBOutlet weak var viewJoinAMeetingButton: UIView!
    @IBOutlet weak var txtEnterNameField: UITextField!
    @IBOutlet weak var viewEnterNameFieldContainer: UIView!
    @IBOutlet weak var viewJoinAMeetingView: UIView!
    @IBOutlet weak var txtMeetingCodeField: UITextField!
    @IBOutlet weak var viewMeetingCodeFieldContainer: UIView!
    
    @IBOutlet weak var btnVideoEnableDisable: UIButton!
    @IBOutlet weak var btnAudioEnableDisable: UIButton!
    @IBOutlet weak var btnJoinMeeting: UIButton!
    @IBOutlet weak var btnCreateMeeting: UIButton!
    @IBOutlet weak var btnJoinAMeeting: UIButton!
    
    @IBOutlet weak var joinAMeetingStackView: UIStackView!
    @IBOutlet weak var initialOptionStackView: UIStackView!
    
    // MARK: Properties
    
    var isJoinMeetingAction = true
    var isRequestInProgress = false
    
    //Camera Capture requiered properties
    var videoDataOutput: AVCaptureVideoDataOutput!
    var videoDataOutputQueue: DispatchQueue!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var captureDevice: AVCaptureDevice!
    var rootLayer: CALayer!
    let session = AVCaptureSession()
    
    // MARK: - UI Elements
    let flipCameraButton = UIButton(type: .system)
    let switchAudioButton = UIButton(type: .system)

    @Published var valueOfVideoDevice: String? = "Front Camera"
    @Published var valueOfAudioDevice: String? = "Speaker"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        VideoSDK.getAudioPermission()
        self.requestNotificationAuthorization()
        self.serverToken = AUTH_TOKEN
        previewLayer.isHidden = !self.webCamEnabled

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        valueOfVideoDevice = "Front Camera"
        valueOfAudioDevice = "Speaker"
    }
    
    func prepareUI() {
        
        let attributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor : UIColor.gray
        ]
        
        txtEnterNameField.attributedPlaceholder = NSAttributedString(string: "Enter your name", attributes: attributes)
        txtMeetingCodeField.attributedPlaceholder = NSAttributedString(string: "Enter meeting code", attributes: attributes)
        txtEnterNameField.delegate = self
        txtMeetingCodeField.delegate = self
        txtMeetingCodeField.text = ""
        
        [viewCameraViewContainer, viewCreateAMeetingButton, viewJoinAMeetingButton, viewTestAudioVideoContainer].forEach {
            $0?.roundCorners(corners: [.allCorners], radius: 12.0)
        }
        
        viewTestAudioVideoContainer.layer.borderWidth = 1
        viewTestAudioVideoContainer.layer.borderColor = UIColor(named: "borderColor")?.cgColor
        
        [viewAudioButton, viewVideoButton].forEach{
            $0?.roundCorners(corners: [.allCorners], radius: 22.0)
        }
        
        [viewEnterNameFieldContainer, viewMeetingCodeFieldContainer, viewJoinAMeetingView].forEach{
            $0?.roundCorners(corners: [.allCorners], radius: 10.0)
        }
        
        setupAVCapture()
        configureCameraControls()
  
        updateVideoButton(status: self.webCamEnabled)
        updateAudioButton(status: self.micEnabled)
        
    }
    
    @IBAction func btnAudioEnableDisableTapped(_ sender: Any) {
        self.micEnabled = !self.micEnabled
        updateAudioButton(status: self.micEnabled)
    }
    
    @IBAction func btnVideoEnableDisableTapped(_ sender: Any) {
        self.webCamEnabled = !self.webCamEnabled
        updateVideoButton(status: self.webCamEnabled)
        previewLayer.isHidden = !self.webCamEnabled
    }
    
    @IBAction func btnJoinMeetingTapped(_ sender: Any) {
        self.initialOptionStackView.isHidden = true
        self.joinAMeetingStackView.isHidden = false
        self.isJoinMeetingAction = true
        
        self.txtMeetingCodeField.becomeFirstResponder()
    }
    
    @IBAction func btnCreateMeetingTapped(_ sender: Any) {
        self.initialOptionStackView.isHidden = true
        self.joinAMeetingStackView.isHidden = false
        self.viewMeetingCodeFieldContainer.isHidden = true
        self.isJoinMeetingAction = false
        self.txtEnterNameField.becomeFirstResponder()
    }
    
    
    @IBAction func btnJoinAMeetingTapped(_ sender: Any) {
        stopCamera()
            guard !isRequestInProgress else { return }
            isRequestInProgress = true
            
            defer {
                // Reset the flag after execution
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.isRequestInProgress = false
                }
            }
            if isJoinMeetingAction {
                guard let meetingID = txtMeetingCodeField.text, !meetingID.isEmpty else {
                    self.showAlert(title: "Meeting ID Required", message: "Please provide a meeting ID to start the meeting.")
                    txtMeetingCodeField.resignFirstResponder()
                    return
                }
                joinMeeting()
            } else {
                Utils.loaderShow(viewControler: self)
                joinRoom()
            }
        }
    
    // MARK: - Actions
   @objc private func flipCameraAction() {
        showCameraOptions()
    }

        
   @objc private func switchAudioAction() {
        getAudioDeviceList()
    }
    
    func showCameraOptions() {
        if webCamEnabled == true {
            
            
            let cameras = ["Front Camera", "Back Camera"] // Predefined options
            
            DispatchQueue.main.async { [weak self] in
                self?.showDeviceSelectionAlert(devices: cameras,
                                               deviceType: "Camera",
                                               selectedDevice: self?.valueOfVideoDevice) { selectedCamera in
                    self?.valueOfVideoDevice = selectedCamera
                    self?.setupAVCapture()
                    self?.startCamera()
                }
            }
        }
        else
        {
            showAlert(title: "VideoSDKExample", message: "Turn on Camera first", autoDismiss: true)
        }
    }

        // MARK: - Get Audio Device List
        func getAudioDeviceList() {
            let audioDevices = VideoSDK.getAudioDevices()
            showDeviceSelectionAlert(devices: audioDevices,
                                    deviceType: "Audio Device",
                                    selectedDevice: valueOfAudioDevice) { selectedAudioDevice in
                self.valueOfAudioDevice = selectedAudioDevice
            }

        }

        // MARK: - Show Device Selection Alert
    func showDeviceSelectionAlert(devices: [String], deviceType: String, selectedDevice: String?, completion: @escaping (String) -> Void) {
        let alertController = UIAlertController(title: "Select \(deviceType)", message: nil, preferredStyle: .actionSheet)
        
        for device in devices {
            let action = UIAlertAction(title: device, style: .default) { _ in
                completion(device)
            }
            action.setValue(device == selectedDevice, forKey: "checked")
            alertController.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }

    func configureCameraControls() {
        
        // Add Flip Camera Button
        flipCameraButton.setImage(UIImage(systemName: "camera.rotate"), for: .normal)
        flipCameraButton.tintColor = .systemBlue
        flipCameraButton.addTarget(self, action: #selector(flipCameraAction), for: .touchUpInside)
        flipCameraButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(flipCameraButton) // Add to the main view, outside of the preview container
        
        // Add Switch Audio Button
        switchAudioButton.setImage(UIImage(systemName: "speaker.wave.2"), for: .normal)
        switchAudioButton.tintColor = .systemBlue
        switchAudioButton.addTarget(self, action: #selector(switchAudioAction), for: .touchUpInside)
        switchAudioButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(switchAudioButton) // Add to the main view, outside of the preview container
        
        // Apply Auto Layout Constraints
        NSLayoutConstraint.activate([
            // Flip Camera Button Constraints (Outside of the preview container)
            flipCameraButton.leadingAnchor.constraint(equalTo: view.trailingAnchor, constant: -100),
            flipCameraButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            flipCameraButton.widthAnchor.constraint(equalToConstant: 40),
            flipCameraButton.heightAnchor.constraint(equalToConstant: 40),
            
            // Switch Audio Button Constraints (Outside of the preview container)
            switchAudioButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -19),
            switchAudioButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            switchAudioButton.widthAnchor.constraint(equalToConstant: 40),
            switchAudioButton.heightAnchor.constraint(equalToConstant: 40),
        ])
    }

    private func getSelectedCameraPosition() -> AVCaptureDevice.Position? {
        switch valueOfVideoDevice {
        case "Front Camera":
            return .front
        case "Back Camera":
            return .back
        default:
            return .front
        }
    }
    
    func updateAudioButton(status: Bool) {
        self.viewAudioButton.backgroundColor = status ? UIColor.white : UIColor.red
        self.imgAudioButton.image = status ? UIImage(systemName: "mic.fill") : UIImage(systemName: "mic.slash.fill")
        self.imgAudioButton.tintColor = status ? UIColor.black : UIColor.white
    }
    
    func updateVideoButton(status: Bool) {
        self.viewVideoButton.backgroundColor = status ? UIColor.white : UIColor.red
        self.imgVideoButton.image = status ? UIImage(systemName: "video.fill") : UIImage(systemName: "video.slash.fill")
        self.imgVideoButton.tintColor = status ? UIColor.black : UIColor.white
        self.viewCameraViewContainer.backgroundColor = status ? UIColor.clear : UIColor(named: "videoBackgroundColor")
        status ? self.startCamera() : self.stopCamera()
    }
    
    func joinRoom() {
            
            let urlString = "https://api.videosdk.live/v2/rooms"
            let session = URLSession.shared
            let url = URL(string: urlString)!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue(self.serverToken, forHTTPHeaderField: "Authorization")
            
            session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
                DispatchQueue.main.async {
                    Utils.loaderDismiss(viewControler: self)
                    if let data = data, let utf8Text = String(data: data, encoding: .utf8)
                    {
                        do{
                            let dataArray = try JSONDecoder().decode(RoomsStruct.self,from: data)
                            DispatchQueue.main.async {
                                self.txtMeetingCodeField.text = dataArray.roomID
                            }
                            self.joinMeeting()
                            print(dataArray)
                        } catch {
                            print("Error while creating a meeting: \(error)")
                            self.showToast(message: "Error while creating a meeting: \(error)", font: .systemFont(ofSize: 15.0))
                        }
                    }
                }
                
            }
            ).resume()
        }
    // MARK: - Actions
    
    func joinMeeting() {
        txtEnterNameField.resignFirstResponder()
        
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
            name: txtEnterNameField.text ?? "Guest",
            meetingId: txtMeetingCodeField.text ?? "",
            micEnabled: true,
            cameraEnabled: true,
            videoDevice: valueOfVideoDevice,     // Pass the selected video device
            audioDevice: valueOfAudioDevice      // Pass the selected audio device

        )
    }
    
}

extension StartMeetingViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if textField == txtMeetingCodeField {
            txtEnterNameField.becomeFirstResponder()
        }
        return true
    }
}


extension StartMeetingViewController: AVCaptureVideoDataOutputSampleBufferDelegate{
    
    func setupAVCapture() {
        session.stopRunning() // Stop the current session before reconfiguration
        
        // Remove all existing inputs and outputs
        session.inputs.forEach { session.removeInput($0) }
        session.outputs.forEach { session.removeOutput($0) }
        
        guard let facingMode = getSelectedCameraPosition() else { return }

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
        // Start the camera session on a background thread
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
        }
            [viewVideoButton, viewAudioButton].forEach {
                       viewCameraViewContainer.bringSubviewToFront($0)
        }
    }

    // clean up AVCapture
    func stopCamera(){
        if session.isRunning {
               session.stopRunning()
            previewLayer.isHidden = true
            updateVideoButton(status: false)
                
           }
    }
    
    func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: UNAuthorizationOptions.init(arrayLiteral: .alert, .badge, .sound)) { (success, error) in
            if let error = error {
                print("requestAuthorization error: ", error)
            }
        }
    }

}
