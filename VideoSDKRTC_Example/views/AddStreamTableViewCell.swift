//
//  AddStreamTableViewCell.swift
//  VideoSDKRTC_Example
//
//  Created by Parth Asodariya on 07/02/23.
//

import Foundation

import UIKit

class AddStreamTableViewCell: UITableViewCell {

    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var streamKeyTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        [urlTextField, streamKeyTextField].forEach {
            $0?.delegate = self
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension AddStreamTableViewCell: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
