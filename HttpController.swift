
import UIKit

protocol HttpProtocol
{
    func didReceiveResult(results:NSDictionary)
}

class HttpController : NSObject{
    
    var delegate:HttpProtocol?
    
    func onSearch(url:String)
    {
        // 将所有的内容进行汇总，并且获取到其中的内容
        var nsUrl:NSURL = NSURL(string: url)!
        var request:NSURLRequest = NSURLRequest(URL: nsUrl)
        
//MARK: - 编写Connection的异步调用方法
        // url异步请求
        // url异步请求队列
        // 闭包函数 : 
        //          1. 解析json内容， 调用一个自定义Protocol
        //          2. 自定义的protocol是必定要实现的内容，并且可以外部申请引入
        NSURLConnection.sendAsynchronousRequest(
            request,
            queue: NSOperationQueue.mainQueue(),
            completionHandler: {(request:NSURLResponse!, data:NSData!, error:NSError!) -> Void in
                var json_EX:NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
                self.delegate?.didReceiveResult(json_EX)
        })

    }
}