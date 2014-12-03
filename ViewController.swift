
import UIKit
import Foundation
import MediaPlayer

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, HttpProtocol {
    // 本页面的基础组件基础引用，也就是组件与类进行关联的方式
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var lv: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressTime: UILabel!
    
    var Ohttp:HttpController = HttpController()
    
    // 全局定义外部使用变量
    var tableData:NSArray = NSArray()
    var channelData:NSArray = NSArray()
    // 缓存缩略图
    var imageCache = Dictionary<String, UIImage>()
    // 播放器声明
    var audioPlayer:MPMoviePlayerController = MPMoviePlayerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        Ohttp.delegate = self
        Ohttp.onSearch("http://www.douban.com/j/app/radio/channels")
        Ohttp.onSearch("http://douban.fm/j/mine/playlist?channel=0")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Return -> TableView Row's Count
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return tableData.count
    }
//MARK: - 返回指定的单元格 
    // cell 来进行反馈所有的内容给用户所见, 注意使用的是 cellForRowAtIndexPath 并且需要返回cell的实际内容
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Doubans")
        let rowData:NSDictionary = self.tableData[indexPath.row] as NSDictionary

        cell.textLabel.text = rowData["title"] as? String           // 标题
        cell.detailTextLabel?.text = rowData["artist"] as? String   // 详细歌手
        cell.imageView.image = UIImage(named: "default.png")        // 设置一个默认图片 特别注意:  UIImage的第1种用法，直接获取从本地文件中获取内容
        let imgurl = rowData["picture"] as String
        let image = self.imageCache[imgurl]
        if (image? == nil) {
            // 如果图片在缓存中不存在的情况，则加载
            let reurl = NSURL(string: imgurl)
            let reResponse = NSURLRequest(URL: reurl!)
            NSURLConnection.sendAsynchronousRequest(reResponse, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!, data:NSData!, error:NSError!) -> Void in
                let get_img = UIImage(data: data)  // 特别注意:  UIImage的第2种用法，直接获取从NSData里面取得的内容
                cell.imageView.image = get_img
                self.imageCache[imgurl] = get_img
            })
        } else {
            cell.imageView.image = image
        }
        
        return cell
    }
    
//MARK: - 点击表格里面的内容播放设置 : didSelectRowAtIndexPath
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let rowData:NSDictionary = self.tableData[indexPath.row] as NSDictionary
        let audioURL:String = rowData["url"] as String
        let imageURL:String = rowData["picture"] as String
        onSetAudio(audioURL)
        onSetImage(imageURL)
    }

//MARK: - 音乐播放控制
    // 设置音乐的图片，并且保证
    func onSetAudio(url: String){
        self.audioPlayer.stop()
        self.audioPlayer.contentURL = NSURL(string: url)
        self.audioPlayer.play()
    }
    // 异步设置图片内容
    func onSetImage(url: String){
        let image = self.imageCache[url]
        if (image? == nil) {
            let reurl = NSURL(string: url)
            let reResponse = NSURLRequest(URL: reurl!)
            NSURLConnection.sendAsynchronousRequest(reResponse, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!, data:NSData!, error:NSError!) -> Void in
                let get_img = UIImage(data: data)
                self.lv.image = get_img
                self.imageCache[url] = get_img
            })
        } else {
            self.lv.image = image
        }
    }
    
    func didReceiveResult(results:NSDictionary)
    {
        if (results["song"] != nil) {
            self.tableData = results["song"] as NSArray
            self.tv.reloadData()
            
            // 默认播放第一首歌
            let firstDict:NSDictionary = self.tableData[0] as NSDictionary
            let audioURL:NSString = firstDict["url"] as NSString
            let imageURL:NSString = firstDict["picture"] as NSString
            onSetAudio(audioURL);
            onSetImage(imageURL);
            
        } else if (results["channels"] != nil) {
            self.channelData = results["channels"] as NSArray
        }
    }

}
