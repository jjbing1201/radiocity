
import UIKit

// 在本文件中，只是定义了向回传的内容方法和实现传递的方式，具体的内容，通过protocol传递回去
protocol channel_review_protocol{
    func onChangeChannel(channel_id:String)
}

/* 由于datasource和delegate两个通过storyboard进行了关联，所以在这里要继承相关属性, 但是需要注意的是
   继承了2个其他的类，需要去实现其他类的相关虚方法(override方法不已optional开头) */
class channelcontroller: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tv: UITableView!
    // 初始化传递参数内容
    var channelData:NSArray = NSArray()
    // 初始化协议传参id -> 通过点击事件来确认需要输出的内容和返回的传参
    var delegate:channel_review_protocol?
    
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
        // 填充传递参数的数据
        let rowData:NSDictionary = self.channelData[indexPath.row] as NSDictionary
        cell.textLabel.text = rowData["name"] as? String
        return cell
    }
    
//MARK: - 复写UITableViewDelegate的相关方法
    // 点击后将进行tableview selectrow的判断，需要判断有多少行可以使用
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        // 呼应delegate
        var rowData:NSDictionary = self.channelData[indexPath.row] as NSDictionary
        let channel_id:AnyObject = rowData["channel_id"] as AnyObject!
        let channel:String = "channel=\(channel_id)"
        delegate?.onChangeChannel(channel) // 向回传的方法调用
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}



