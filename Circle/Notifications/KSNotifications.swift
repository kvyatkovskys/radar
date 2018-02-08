//
//  KSNotifications.swift
//  Circle
//
//  Created by Kviatkovskii on 07/02/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit
import UserNotifications
import RxSwift

final class KSNotifications: NSObject {
    let center: UNUserNotificationCenter
    fileprivate let disposeBag = DisposeBag()
    
    init(center: UNUserNotificationCenter) {
        self.center = center
        super.init()
    }
    
    func showNotification(title: String, subTitle: String, body: String, imageUrl: String? = nil) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subTitle
        content.body = body
        content.sound = UNNotificationSound.default()
        if UIApplication.shared.applicationState != .active {
            content.badge = UIApplication.shared.applicationIconBadgeNumber + 1 as NSNumber
        }
        content.userInfo = ["url_image": imageUrl ?? ""]
        
        let identifier = ProcessInfo.processInfo.globallyUniqueString
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        
        center.removeAllPendingNotificationRequests()
        
        guard let url = URL(string: imageUrl ?? "") else {
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            center.add(request) { (error) in
                if let error = error {
                    print(error)
                }
            }
            return
        }
    
        loadImage(with: url) { (image) in
            if let img = image, let attechment = UNNotificationAttachment.create(identifier: identifier, image: img, options: nil) {
                content.attachments = [attechment]
            }

            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            self.center.add(request) { (error) in
                if let error = error {
                    print(error)
                }
            }
        }
    }
    
    fileprivate func loadImage(with url: URL, completion: @escaping (_ image: UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { (data, response, _) in
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(nil)
                return
            }
            
            guard let dataImage = data, let image = UIImage(data: dataImage) else {
                completion(nil)
                return
            }
            
            completion(image)
        }.resume()
    }
}

extension UNNotificationAttachment {
    static func create(identifier: String, image: UIImage, options: [NSObject: AnyObject]?) -> UNNotificationAttachment? {
        let fileManager = FileManager.default
        let subFolderName = ProcessInfo.processInfo.globallyUniqueString
        let subFolderURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(subFolderName, isDirectory: true)
        do {
            try fileManager.createDirectory(at: subFolderURL, withIntermediateDirectories: true, attributes: nil)
            let imageFileIdentifier = identifier + ".jpg"
            let fileURL = subFolderURL.appendingPathComponent(imageFileIdentifier)
            guard let imageData = UIImagePNGRepresentation(image) else {
                return nil
            }
            try imageData.write(to: fileURL)
            let imageAttachment = try UNNotificationAttachment.init(identifier: imageFileIdentifier, url: fileURL, options: options)
            return imageAttachment
        } catch {
            print("error " + error.localizedDescription)
        }
        return nil
    }
}
