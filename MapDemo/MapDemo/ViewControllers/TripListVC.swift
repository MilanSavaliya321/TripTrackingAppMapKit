//
//  TripListVC.swift
//  MapDemo
//
//  Created by Milan on 08/10/22.
//

import UIKit
import CoreData

class TripListVC: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var tblTriplist: UITableView!
    
    // MARK: - Properties
    var arrTripList = [Trip]()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchRecordsFromDB()
    }
    
    // MARK: - Functions
    func setupUI() {
        title = "Trip History"
        
        tblTriplist.register(UINib(nibName: "TripListCell", bundle: nil), forCellReuseIdentifier: "TripListCell")
        tblTriplist.dataSource = self
        tblTriplist.delegate = self
        tblTriplist.reloadData()
    }
    
    func fetchRecordsFromDB() {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        print(path[0])
        do {
            let result = try PersistentStorage.shared.context.fetch(Trip.fetchRequest())
            self.arrTripList.removeAll()
            self.arrTripList.append(contentsOf: result)
            print(self.arrTripList)
        } catch let error {
            print(error.localizedDescription)
        }
        DispatchQueue.main.async {
            self.tblTriplist.reloadData()
        }
    }
    
    func getRecord(byId id: UUID) -> Trip? {
        let fetchRequest = NSFetchRequest<Trip>(entityName: "Trip")
        let fetchById = NSPredicate(format: "id==%@", id as CVarArg)
        fetchRequest.predicate = fetchById
        
        let result = try! PersistentStorage.shared.context.fetch(fetchRequest)
        guard result.count != 0 else {return nil}
        return result.first
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension TripListVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        arrTripList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TripListCell") as? TripListCell else { return .init() }
        let model = arrTripList[indexPath.row]
        cell.lblTripNum.text = "Trip \(indexPath.row + 1)"
        cell.configData(model: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let trip = getRecord(byId: arrTripList[indexPath.row].id!) else { return }
        
        guard let viewTripVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewTripVC") as? ViewTripVC else { return }
        viewTripVC.startLocation = .init(latitude: trip.startLet, longitude: trip.startLong)
        viewTripVC.endLocation = .init(latitude: trip.endLet, longitude: trip.endLong)
        self.navigationController?.pushViewController(viewTripVC, animated: true)
    }
}
