//
//  feedVC.swift
//  showcase
//
//  Created by shengxiang guo on 1/26/16.
//  Copyright © 2016 shengxiang guo. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class feedVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var  tableView: UITableView!
    @IBOutlet var textField: materialTextFeild!
    @IBOutlet var imageSelectorImage: UIImageView!
    
    var posts = [Post]()
    static var imageCache = NSCache()
    
    var imagePick: UIImagePickerController!
    var imageSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.estimatedRowHeight = 360
        
        imagePick = UIImagePickerController()
        imagePick.delegate = self
        
        DataService.ds.REF_POSTS.observeEventType(.Value, withBlock: { snapshot in
            //print(snapshot.value)
            self.posts = []
            
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot]{
                for snap in snapshots{
                   // print("SNAP: \(snap)")
                    if let postDict = snap.value as? Dictionary<String, AnyObject>{
                        let key = snap.key
                        let post = Post(postKey: key, dictionary: postDict)
                        self.posts.append(post)
                    }
                }
                
              
            }
            
            self.tableView.reloadData()
        })
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let post = posts[indexPath.row]
        //print(post.postDescription)
        if let cell = tableView.dequeueReusableCellWithIdentifier("postCell") as? postCell{
            
            cell.request?.cancel()
            
            var img:UIImage?
            
            if let url = post.imageUrl{
                img = feedVC.imageCache.objectForKey(url) as? UIImage
            }
            
            cell.configureCell(post, img: img)
            return cell
        }else{
            return postCell()
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let post  = posts[indexPath.row]
        if post.imageUrl == nil{
            return 148
        }else{
            return tableView.estimatedRowHeight
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imagePick.dismissViewControllerAnimated(true, completion: nil)
        imageSelectorImage.image = image
        imageSelected = true
    }
    
    @IBAction func selectImage(sender: UITapGestureRecognizer) {
        presentViewController(imagePick, animated: true, completion: nil)
    }
    
    @IBAction func makePost(sender: AnyObject) {
        if let txt = textField.text where txt != ""{
            if let img = imageSelectorImage.image where imageSelected == true{
                let urlStr = "https://post.imageshack.us/upload_api.php"
                let url = NSURL(string: urlStr)!
                let imgData = UIImageJPEGRepresentation(img, 0.2)!
                let keyData = "12DJKPSU5fc3afbd01b1630cc718cae3043220f3".dataUsingEncoding(NSUTF8StringEncoding)
                let keyJS = "json".dataUsingEncoding(NSUTF8StringEncoding)!
                
                Alamofire.upload(.POST, url, multipartFormData: { multipartFormData in
                    
                    multipartFormData.appendBodyPart(data: imgData, name: "fileupload", fileName: "image", mimeType: "image/jpg")
                    
                    multipartFormData.appendBodyPart(data: keyData!, name: "key")
                    
                    multipartFormData.appendBodyPart(data: keyJS, name: "format")
                    
                    }) { encodingResult in
                        
                        switch encodingResult {
                        case .Success(let upload, _, _):
                            upload.responseJSON(completionHandler: {response in
                                if let info = response.result.value as? Dictionary<String, AnyObject> {
                                    if let links = info["links"] as? Dictionary<String, AnyObject>{
                                        if let imgLinks = links["image_link"] as? String{
                                            print("LINK: \(imgLinks)")
                                            self.postToFirebase(imgLinks)
                                        }
                                    }
                                }
                            })
                        case .Failure(let err):
                            print(err)
                        }
                }
            }else {
                self.postToFirebase(nil)
            }
        }
    }
    
    func postToFirebase(imgURL: String?){
        var post: Dictionary<String, AnyObject> = [
            "description": textField.text!,
            "likes": 0
        ]
        
        if imgURL != nil {
            post["imageURL"] = imgURL!
        }
     
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        
        
        textField.text = ""
        imageSelectorImage.image = UIImage(named: "camera")
        imageSelected = false
        
        tableView.reloadData()
    }
}
