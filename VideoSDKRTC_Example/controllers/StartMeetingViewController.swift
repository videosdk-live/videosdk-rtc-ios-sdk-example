//
//  StartMeetingViewController.swift
//  VideoSDKRTC_Example
//
//  Created by Parth Asodariya on 11/01/23.
//

import UIKit
import AVFoundation

class StartMeetingViewController: UIViewController {
    
    // MARK: - Properties
    
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
    
    //Camera Capture requiered properties
    var videoDataOutput: AVCaptureVideoDataOutput!
    var videoDataOutputQueue: DispatchQueue!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var captureDevice: AVCaptureDevice!
    var rootLayer: CALayer!
    let session = AVCaptureSession()

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        
        self.serverToken = AUTH_TOKEN
    }
    
    func prepareUI() {
        
        let attributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor : UIColor.gray
        ]
        
        txtEnterNameField.attributedPlaceholder = NSAttributedString(string: "Enter your name", attributes: attributes)
        txtMeetingCodeField.attributedPlaceholder = NSAttributedString(string: "Enter meeting code", attributes: attributes)
        txtEnterNameField.delegate = self
        txtMeetingCodeField.delegate = self
        txtMeetingCodeField.text = "kqlm-udpj-45d3"
        
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
        if isJoinMeetingAction {
            // Join meeting
            if((txtMeetingCodeField.text ?? "").isEmpty){
                self.showAlert(title: "Meeting id Required", message: "Please provide meeting id to start the meeting.")
                txtMeetingCodeField.resignFirstResponder()
            } else {
                joinMeeting()
            }
        } else {
            // Create meeting
            Utils.loaderShow(viewControler: self)
            joinRoom()
        }
    }
    
    // MARK: - Custom Function
    
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
                    print("UTF =>=>\(utf8Text)") // original server data as UTF8 string
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
//            self.dismiss(animated: true)
            self.dismiss(animated: true) {
                self.performSegue(withIdentifier: "StartMeeting", sender: nil)
            }
        }
        
            //let meetingViewController = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "MeetingViewController") as? MeetingViewController
            
//            let meetingViewController = self.storyboard?.instantiateViewController(withIdentifier: "MeetingViewController") as? MeetingViewController
//
//            meetingViewController?.meetingData = MeetingData(
//                token: self.serverToken,
//                name: self.txtEnterNameField.text ?? "Guest",
//                meetingId: self.txtMeetingCodeField.text ?? "",
//                micEnabled: true,
//                cameraEnabled: true
//            )
//            self.navigationController?.pushViewController(meetingViewController!, animated: true)
//            guard let navigation = storyboard.destination as? UINavigationController,
//                  let meetingViewController = navigation.topViewController as? MeetingViewController else {
//                      return
//                  }
//            meetingViewController.meetingData = MeetingData(
//                token: serverToken,
//                name: txtEnterNameField.text ?? "Guest",
//                meetingId: txtMeetingCodeField.text ?? "",
//                micEnabled: true,
//                cameraEnabled: true
//            )
            //self.performSegue(withIdentifier: "StartMeeting", sender: nil)
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
            cameraEnabled: true
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
     func setupAVCapture(){
        session.sessionPreset = AVCaptureSession.Preset.vga640x480
        guard let device = AVCaptureDevice
        .default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: .video, position: AVCaptureDevice.Position.front)
         else { return }
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
        session.startRunning()
        [viewVideoButton, viewAudioButton].forEach {
            self.viewCameraViewContainer.bringSubviewToFront($0)
        }
    }

    // clean up AVCapture
    func stopCamera(){
        session.stopRunning()
    }

}
