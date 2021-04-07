//
//  AppDelegate.swift
//  virtualTours
//
//  Created by Dylan Burkett on 3/5/21.
//

import UIKit
import GooglePlaces
import BackgroundTasks //https://www.andyibanez.com/posts/modern-background-tasks-ios13/

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        GMSPlacesClient.provideAPIKey("AIzaSyBteIWUNfzha84rBc5w7FKKnkt46wF1tbg")
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "edu.umich.nkeller97.fetchNearby", using: nil){ //TODO: sync with nearby in-app
            (task) in self.handleAppRefreshTask(task: task as! BGAppRefreshTask)
        }
        return true
        }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func handleAppRefreshTask(task: BGAppRefreshTask){
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
            NearbyStore.urlSession.invalidateAndCancel()
        }
        while(true){
            scheduleBackgroundNearbyFetch()
        }
    }

    func scheduleBackgroundNearbyFetch() {
        let nearbyFetchTask = BGAppRefreshTaskRequest(identifier: "edu.umich.nkeller97.fetchNearby")
        nearbyFetchTask.earliestBeginDate = Date.init(timeIntervalSinceNow: 60)
        do {
            try BGTaskScheduler.shared.submit(nearbyFetchTask)
        } catch {
                print("error submitting task")
        }
    }
}
