//
//  AddStreamOutputiewController.swift
//  VideoSDKRTC_Example
//
//  Created by Parth Asodariya on 07/02/23.
//

import UIKit
import VideoSDKRTC

private let cellIdentifier = "AddStreamTableViewCell"

class AddStreamOutputiewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var startStreamButton: UIButton!
    
    private var numberOfStreams = 1
    private var cells: [AddStreamTableViewCell] = []
    
    /// Callback
    var onStart: (([LivestreamOutput]) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    @IBAction func addStreamTapped(_ sender: Any) {
        addStreamRow()
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func startStreamTapped(_ sender: Any) {
        var outputs: [LivestreamOutput] = []
        
        for cell in cells {
            if let url = cell.urlTextField.text, !url.isEmpty, let streamKey = cell.streamKeyTextField.text, !streamKey.isEmpty {
                let output = LivestreamOutput(url: url, streamKey: streamKey)
                outputs.append(output)
            }
        }
        
        dismiss(animated: true) {
            self.onStart?(outputs)
        }
    }
}

extension AddStreamOutputiewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        numberOfStreams
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let addStreamCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! AddStreamTableViewCell
        
        if !cells.contains(addStreamCell) {
            cells.append(addStreamCell)
        }
        
        return addStreamCell
    }
}

extension AddStreamOutputiewController {
    
    func addStreamRow() {
        let indexPath = IndexPath(row: numberOfStreams, section: 0)
        numberOfStreams += 1
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
}
