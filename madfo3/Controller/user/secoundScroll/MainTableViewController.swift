
import FoldingCell
import UIKit
import Firebase
import FirebaseDatabase

//vars:
var cobonIds: String!

class MainTableViewController: UITableViewController , PlayVideoCellProtocol{
    
    
    //Vars:
    var cobonIndex:Int?
    var cobons = [Cobons]()
    var cobonsName = [Cobons]()
    var ref:DatabaseReference?
    
    //Outlet:
    @IBOutlet weak var emptyView: UIView!
    
    
    //alert *not used*
    func playVideoButtonDidSelect() {
        
        let alert = UIAlertController(title: "Error", message: "are you sure ? ", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "cancel", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    enum Const {
        static let closeCellHeight: CGFloat = 110
        static let openCellHeight: CGFloat = 450
        static let rowsCount = 10
    }
    
    
    var cellHeights: [CGFloat] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        loadCobons()
        
    }
    
    
    // this function for loading coubons from firebase ..
    func loadCobons(){
        
        DispatchQueue.main.async() {
            self.ref = Database.database().reference();
            let userID = Auth.auth().currentUser?.uid
            self.ref?.child("users").child("customer").child(userID!).child("cobons").observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.childrenCount > 0 {
                    self.cobons.removeAll()
                    self.cobonsName.removeAll()
                    
                    for cobon in snapshot.children.allObjects as![DataSnapshot]{
                        
                        let cob = cobon.value as? [String: Any]
                        
                        let merchant0 = cob?["merchant"]
                        let amount = cob?["amount"] as! Int
                        let date = cob?["date"]
                        let QRCode = cob?["QRCode"]
                        let gift = cob?["isGift"]
                        let back = cob?["image"]
                        let ownerID = cob?["owner"]
                        
                        
                        if amount != 0 {
                            
                            self.ref?.child("users").child("merchants").child(merchant0 as!String).observeSingleEvent(of: .value, with: { (snaphot2) in
                                var value = snaphot2.value as! [String : Any]
                                let name = value["name"] as! String
                                
                                self.ref?.child("users").child("customer").child(ownerID! as! String).observeSingleEvent(of: .value, with: { (snapshot3) in
                                    var value = snapshot3.value as! [String : Any]
                                    let Customername = value["name"] as! String
                                    
                                    let cobonInfo = Cobons(cobonId:cobon.key, merchantID: merchant0 as! String, cobonAmount: amount as! Int, cobonDate: date as! String , QR: QRCode as! String , merchantName : name as! String , isGift :gift as! Bool , background : back as! String , ownerID: ownerID as! String , Customername: Customername as! String)
                                    
                                    self.cobons.append(cobonInfo)
                                    
                                    self.tableView.reloadData()
                                })
                                self.tableView.reloadData()
                                
                                
                            })}else{
                            self.emptyView.isHidden = false
                            
                        }
                        self.tableView.reloadData()
                    }
                }else{
                    self.emptyView.isHidden = false
                }
            }
            )
            self.tableView.reloadData()
            
            
        }
    }
    
    private func setup() {
        cellHeights = Array(repeating: Const.closeCellHeight, count: Const.rowsCount)
        tableView.estimatedRowHeight = Const.closeCellHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        
        
        tableView.backgroundColor = UIColor(displayP3Red: 238/255, green: 240/255, blue: 246/255, alpha: 1)
        
        //  tableView.backgroundColor = UIColor.white
        if #available(iOS 10.0, *) {
            tableView.refreshControl = UIRefreshControl()
            tableView.refreshControl?.addTarget(self, action: #selector(refreshHandler), for: .valueChanged)
        }
    }
    
    @objc func refreshHandler() {
        let deadlineTime = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: { [weak self] in
            if #available(iOS 10.0, *) {
                self?.tableView.refreshControl?.endRefreshing()
            }
            
            
            self?.tableView.reloadData()
        })
    }
}

// MARK: - TableView

extension MainTableViewController {
    
    //  var cobonIndex:Int?
    
    
    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        
        return cobons.count    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    //for table view header *not user*
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.black
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
        
    }
    
    
    
    
    override func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard case let cell as DemoCell = cell else {
            return
        }
        
        cell.backgroundColor = .clear
        
        if cellHeights[indexPath.row] == Const.closeCellHeight {
            cell.unfold(false, animated: false, completion: nil)
        } else {
            cell.unfold(true, animated: false, completion: nil)
        }
        
        cell.number = indexPath.row
    }
    
    //fill cill with coubons information ..
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoldingCell", for: indexPath) as! DemoCell
        // let durations: [TimeInterval] = [0.26, 0.2, 0.2]
        let durations: [TimeInterval] = [0.26, 0.2]
        cell.durationsForExpandedState = durations
        cell.durationsForCollapsedState = durations
        
        //firebase  ..
        
        var cobonsCell :Cobons
        cobonsCell = self.cobons[indexPath.row]
        // cell.cobonAmount.text =
        cell.date.text = cobonsCell.cobonDate
        cell.merchantName.text = cobonsCell.merchantName
        
        
        cell.cobonAmount.text = NSString(format:"%d", cobonsCell.cobonAmount!) as String
        cell.olSendGift.addTarget(self, action: #selector(self.cobonID), for: .touchUpInside)
        cell.background.image=UIImage(named :cobonsCell.background!)
        
        
        //if the coubon is gift
        if cobonsCell.isGigt == true {
            
            //view
            cell.isGift.isHidden = false
            cell.giftSender.isHidden = false
            
            //hide
            cell.olSendGift.isHidden = true
            
            //fill
            cell.giftSender.text = cobonsCell.Customername
            cell.merchantName.text = cobonsCell.merchantName
            
        }
        
        
        let storageRef = Storage.storage()
        let httpsReference = storageRef.reference(forURL: cobonsCell.QR!)
        print("Got Image ref.")
        
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        //httpsReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
        httpsReference.getData(maxSize: 800 * 800) { data, error in
            if let error = error {
                print("Error! no image!!")
                print(error)
                // Uh-oh, an error occurred!
            } else {
                // Data for "images/island.jpg" is returned
                let image = UIImage(data: data!)
                print("Entered without error and got image.")
                cell.cobonQr.image = image
                print("Displayed image.")
            }
        }
        
        cell.delegate = self
        
        
        return cell
    }
    
    
    // when user click send, this function will send coupon id to friends list page ..
    @objc func cobonID(){
        
        
        cobonIds = self.cobons[self.cobonIndex!].cobonId
        let cobonInfo = self.storyboard?.instantiateViewController(withIdentifier: "viewFriends") as! sendToFriendsViewController
        self.navigationController?.pushViewController(cobonInfo, animated: true)
        performSegue(withIdentifier: "viewFriends", sender: self)
        
        
    }
    
    override func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! FoldingCell
        
        if cell.isAnimating() {
            return
        }
        
        var duration = 0.0
        let cellIsCollapsed = cellHeights[indexPath.row] == Const.closeCellHeight
        if cellIsCollapsed {
            cellHeights[indexPath.row] = Const.openCellHeight
            cell.unfold(true, animated: true, completion: nil)
            duration = 0.5
        } else {
            cellHeights[indexPath.row] = Const.closeCellHeight
            cell.unfold(false, animated: true, completion: nil)
            duration = 0.8
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: { () -> Void in
            tableView.beginUpdates()
            tableView.endUpdates()
        }, completion: nil)
        
        //save coubon id
        self.cobonIndex = indexPath.row
    }
}
