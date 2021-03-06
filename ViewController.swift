
import UIKit
import Foundation
import MediaPlayer
import QuartzCore   // 视觉展示核心

// 注意，遵循了协议，必须要实现协议的方法才可以
class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, HttpProtocol, channel_review_protocol{
    // 本页面的基础组件基础引用，也就是组件与类进行关联的方式
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var lv: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressTime: UILabel!
    @IBOutlet var tapTouch: UITapGestureRecognizer! = nil
    @IBOutlet weak var btn: UIImageView!
    
    var Ohttp:HttpController = HttpController()
    
    // 全局定义外部使用变量
    var tableData:NSArray = NSArray()
    var channelData:NSArray = NSArray()
    // 缓存缩略图
    var imageCache = Dictionary<String, UIImage>()
    // 播放器声明
    var audioPlayer:MPMoviePlayerController = MPMoviePlayerController()
    // 进度条时间延迟
    var timer:NSTimer?
    // 触摸点击事件
    @IBAction func onTapTouch(sender: UITapGestureRecognizer) {
        // 点击音乐图片的时候，显示继续播放button，并且停止音乐
        if (sender.view == lv) {
            btn.hidden = false
            audioPlayer.pause()
            btn.addGestureRecognizer(tapTouch)
            lv.removeGestureRecognizer(tapTouch)
        // 反之
        } else if (sender.view == btn){
            btn.hidden = true
            audioPlayer.play()
            btn.removeGestureRecognizer(tapTouch)
            lv.addGestureRecognizer(tapTouch)
        }
    }
    
//MARK: - 全局定义函数
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        Ohttp.delegate = self
        Ohttp.onSearch("http://www.douban.com/j/app/radio/channels")
        Ohttp.onSearch("http://douban.fm/j/mine/playlist?channel=0")
        
        // 初始化将进度条置为0
        progressView.setProgress(0.0, animated: true)
        
        // 初始化手势粘贴动作 可以进行add或者remove
        lv.addGestureRecognizer(tapTouch)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

//MARK: - 返回指定的单元格 
    // Return -> TableView Row's Count
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return tableData.count
    }
    
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
        timer?.invalidate() //停止计时内容
        progressTime.text = "00:00"
        self.audioPlayer.stop()
        self.audioPlayer.contentURL = NSURL(string: url)
        self.audioPlayer.play()
        timer=NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: "onProcessSchedule", userInfo: nil, repeats: true)
        
        btn.removeGestureRecognizer(tapTouch)
        btn.hidden = true
        lv.addGestureRecognizer(tapTouch)
    }
    func onProcessSchedule() {
        
        let current = audioPlayer.currentPlaybackTime // 当前播放长度
        
        // 整体动画效果
        if (current > 0.0) {
            // 整体进度条动画效果
            let t = audioPlayer.duration // 总长度
            let p:CFloat = CFloat(current/t)
            progressView.setProgress(p, animated: true)
            
            // 整体文本对应结果
            let all:Int = Int(current)
            let second:Int = Int(all % 60)
            let minute:Int = Int(all / 60)
            var timeForLabel = ""
            
            //给分补位0
            if (minute < 10){
                timeForLabel = "0\(minute)"
            }else{
                timeForLabel = "\(minute)"
            }
            //给秒补位0
            if (second < 10){
                timeForLabel += ":0\(second)"
            }else{
                timeForLabel += ":\(second)"
            }
            
            progressTime.text = timeForLabel
        }
        
        
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
//MARK: - 页面跳转函数
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var channelC:channelcontroller = segue.destinationViewController as channelcontroller
        channelC.delegate = self // 如果代理不设置回来，则回调会无响应
        channelC.channelData = self.channelData
    }
    
    func onChangeChannel(channel_id:String) {
        let url:String = "http://douban.fm/j/mine/playlist?\(channel_id)"
        Ohttp.onSearch(url)
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
//MARK: - 视觉实现动画部分
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
        UIView.animateWithDuration(0.25, animations: {
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
        })
    }
}
