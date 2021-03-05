# Yelm.Chat
 Chat SDK 

Start Chat.Core - register with platform from Yelm.Server wiki and put user_id 

```swift
    YelmChat.start(platform: platform, user: user) {
      (load) in
      if (load) {
        YelmChat.core.register {
          (done) in
          if (done) {
            YelmChat.core.server(host: "https://chat.yelm.io/")
          }
        }
      }
    }
```
Add Yelm.Chat in view - SwiftUI

```swift
@ObservedObject var chat : ChatIO = YelmChat
```

All messages automate are in array  

```swift
self.chat.chat.messages 
```

Get new maeesages - you need to collect messages when come back to app from notification

```swift
YelmChat.core.get()
```

All messages structure

```swift

public var id: Int
public var user: chat_user = chat_user(id: 0)
public var text: String = ""
public var time: String = ""
public var date: String = ""
public var attachments : [String : String] = [:]
public var asset : PHAsset? = nil
public var item : items_structure = items_structure()
    
```
