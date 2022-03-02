import UIKit

import MondrianLayout
import CompositionKit
import NextGrowingTextView
import TypedTextAttributes

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    let newWindow = UIWindow()
    newWindow.rootViewController = RootContainerViewController()
    newWindow.makeKeyAndVisible()
    self.window = newWindow
    return true
  }

}
