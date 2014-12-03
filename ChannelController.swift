
import UIKit

/* 由于datasource和delegate两个通过storyboard进行了关联，所以在这里要继承相关属性, 但是需要注意的是
   继承了2个其他的类，需要去实现其他类的相关虚方法(override方法不已optional开头) */
class channelcontroller: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tv: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

//MARK: - 复写TableViewDataSource的相关方法
    // Return -> TableView Row's Count
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 10
    }
    // 返回指定的单元格 cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "channel")
        return cell
    }
    
//MARK: - 复写UITableViewDelegate的相关方法
    // 点击后将进行tableview selectrow的判断，需要判断有多少行可以使用
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}



