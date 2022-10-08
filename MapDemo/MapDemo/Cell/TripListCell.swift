//
//  TripListCell.swift
//  MapDemo
//
//  Created by Milan on 08/10/22.
//

import UIKit

class TripListCell: UITableViewCell {

    @IBOutlet weak var lblTripNum: UILabel!
    @IBOutlet weak var lblTripStart: UILabel!
    @IBOutlet weak var lblTripEnd: UILabel!
    @IBOutlet weak var lblTripKms: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configData(model: Trip) {
        lblTripStart.text = "Started: \(model.startTime ?? "")"
        lblTripEnd.text = "Ended: \(model.endTime ?? "")"
        lblTripKms.text = "KMs: \(model.kms ?? "")"
    }
    
}
