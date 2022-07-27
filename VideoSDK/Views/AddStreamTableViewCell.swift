//
//  AddStreamTableViewCell.swift
//  VideoSDK_Example
//
//  Created by VideoSDK Team on 19/10/21.
//  Copyright © 2021 Zujo Tech Pvt Ltd. All rights reserved.
//

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
