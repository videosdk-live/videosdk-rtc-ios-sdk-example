//
//  StartViewController.swift
//  VideoSDK_Example
//
//  Created by VideoSDK Team on 13/09/21.
//  Copyright © 2021 Zujo Tech Pvt Ltd. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {

    // MARK: - Properties
    
    private var serverToken = ""
    
    // MARK: - Outlets
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var meetingIdTextField: UITextField!
    @IBOutlet weak var copyMeetingIdButton: UIButton!
    @IBOutlet weak var nameDescriptionLabel: UILabel!
    @IBOutlet weak var startMeetingButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        
        self.serverToken = AUTH_TOKEN
    }
    
    // MARK: - Actions
    
    @IBAction func startMeetingButtonTapped(_ sender: Any) {
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
    
    @IBAction func copyMeetingIdButtonTapped(_ sender: Any) {
        guard let meetingId = meetingIdTextField.text, !meetingId.isEmpty else { return }
        let meetingLink = "https://call.zujonow.com/meeting/\(meetingId)"
        
        UIPasteboard.general.string = meetingLink
        self.showAlert(title: "Link Copied", message: nil, autoDismiss: true)
    }
    
    // MARK: - Navigation

    func startMeeting() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "StartMeeting", sender: nil)
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
            micEnabled: true,
            cameraEnabled: true
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
        
        nameDescriptionLabel.text = "Your name will help everyone identify you in the meeting"
        nameDescriptionLabel.textColor = UIColor.darkGray
        nameDescriptionLabel.font = UIFont.systemFont(ofSize: 13)
    }
}
