# UpdateCheckerLocally

/MARK: - APPDelegate's Implementation
//Implement in Appdelegate


func setupFirebase()
    {
        remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig?.configSettings = settings
        remoteConfig?.setDefaults(fromPlist: "RemoteConfigDefaults")
        fetchConfigue()
    }
    
    func fetchConfigue()
    {
        let expirationDuration = 0.0
        
        self.remoteConfig?.fetch(withExpirationDuration: expirationDuration, completionHandler: { (remoteStatus, error) in
            if(remoteStatus == .success)
            {
                self.remoteConfig?.activate(completion: { (changed, error) in
                })
            }
            else
            {
                print("Configure not activated=%@",error?.localizedDescription ?? "No error")
            }
            self.showDialogue()
        })
    }
    
    func showDialogue()
    {
        isAppUpdate = remoteConfig?[kForceUpdateKey].boolValue
        if let _ = isAppUpdate
        {
                let objUpdateChecker = UpdateChecker.init()
                if let rootvc = self.window?.rootViewController
                {
                    objUpdateChecker.presentingViewController = rootvc
                }
                objUpdateChecker.checkVersionDaily()
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
       fetchConfigue()
       isAppUpdate = remoteConfig?[kForceUpdateKey].boolValue
       if let _ = isAppUpdate
       {
           let objUpdateChecker = UpdateChecker.init()
           if let rootvc = self.window?.rootViewController
           {
               objUpdateChecker.presentingViewController = rootvc
           }
           objUpdateChecker.checkVersionDaily()
       }
   }
