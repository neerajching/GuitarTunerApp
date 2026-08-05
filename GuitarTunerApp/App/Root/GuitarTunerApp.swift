//
//  GuitarTunerAppApp.swift
//  GuitarTunerApp
//
//  Created by Negi on 29/05/26.
//

import SwiftUI
import Firebase

@main
struct GuitarTunerApp: App {
    
    @State private var authManager : AuthManager
    
    init() {
        
        FirebaseApp.configure()
        _authManager = State(initialValue: AuthManager())
        print("CLIENT ID:", FirebaseApp.app()?.options.clientID ?? "nil")
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(authManager)
        }
    }
}


// MARK: FireBase CODE for app main Entry Point

/*
 import SwiftUI
 import FirebaseCore


 class AppDelegate: NSObject, UIApplicationDelegate {
   func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
     FirebaseApp.configure()

     return true
   }
 }

 @main
 struct YourApp: App {
   // register app delegate for Firebase setup
   @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate


   var body: some Scene {
     WindowGroup {
       NavigationView {
         ContentView()
       }
     }
   }
 }
 */
