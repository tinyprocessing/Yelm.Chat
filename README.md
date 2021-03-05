# Yelm.Chat
 Chat SDK 

```swift
    YelmChat.start(platform: platform, user: user) { (load) in
                            if (load){
                                YelmChat.core.register { (done) in
                                    if (done){
                                        YelmChat.core.server(host: "https://chat.yelm.io/")
                                    }
                                }
                            }
                        }
```
