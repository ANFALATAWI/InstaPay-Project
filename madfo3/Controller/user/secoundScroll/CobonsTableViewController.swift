
import FoldingCell
import UIKit
import Firebase
import FirebaseDatabase

var sections = ["Gift's","Cobons"]
var cobonsName = ["Jarir" , "Bin Dawood"]

class MainTableViewController: UITableViewController , PlayVideoCellProtocol{
    
     var friends = [Friends]()
    var friendName = [Friends]()
    var ref:DatabaseReference?
    
    // if i wand to send cobons to my friends, use this alert
    
    func playVideoButtonDidSelect() {
  
        let alert = UIAlertController(title: "Error", message: "are you sure ? ", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "cancel", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    enum Const {
        static let closeCellHeight: CGFloat = 100
        static let openCellHeight: CGFloat = 410
        static let rowsCount = 10
    }
    

    var cellHeights: [CGFloat] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        loadFriends()
        
    }
    
    func loadFriends(){
        /*
        DispatchQueue.main.async() {
            
            // change it to cobons's firebase
            
            
  
            self.ref = Database.database().reference();
            let userID = Auth.auth().currentUser?.uid
            self.ref?.child("users").child("customer").child(userID!).child("friends").observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.childrenCount > 0 {
                    self.friends.removeAll()
                    
                    for friend in snapshot.children.allObjects as![DataSnapshot]{
                        print("**********************\(friend)")
                        let fri = friend.value as? [String: Any]
                        let frie = fri?["FriendID"]
                        let frien = Friends(friendName: frie as! String )
                        self.friends.append(frien)
                        print(self.friends.count)
                        
                        // bring friends name
                        self.ref?.child("users").child("customer").child(frie as! String).observeSingleEvent(of: .value, with: { (snapshot) in
                            var value = snapshot.value as! [String : Any]
                            let name = value["name"] as! String
                            print(name)
                            let frie = Friends(friendName: name)
                            self.friendName.append(frie)
                            print(self.friendName.count)
                            
                        })
                    }
                      self.tableView.reloadData()
                }})
  
 
        }
        */
        
    }
    

    private func setup() {
        cellHeights = Array(repeating: Const.closeCellHeight, count: Const.rowsCount)
        tableView.estimatedRowHeight = Const.closeCellHeight
        tableView.rowHeight = UITableViewAutomaticDimension

        //3D344F
  tableView.backgroundColor = UIColor(displayP3Red: 238/255, green: 240/255, blue: 246/255, alpha: 1)
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

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
      
       return friendName.count    }
    
   override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return sections[section]
        
    }
    
   override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clear
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.black
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

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoldingCell", for: indexPath) as! DemoCell
        let durations: [TimeInterval] = [0.26, 0.2, 0.2]
        cell.durationsForExpandedState = durations
        cell.durationsForCollapsedState = durations
      
        //from array
        
        cell.friendName.text = cobonsName[indexPath.row]
        cell.internalName.text = cobonsName[indexPath.row]
        
      //firebase  ..
    /*
        var friendCell :Friends
        friendCell = self.friendName[indexPath.row]
        cell.friendName.text = friendCell.friendName
          cell.delegate = self
*/
        return cell
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
    }
}
