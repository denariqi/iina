//
//  AppDelegate.swift
//  iina
//
//  Created by lhc on 8/7/16.
//  Copyright © 2016年 lhc. All rights reserved.
//

import Cocoa
import MASPreferences

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  
  lazy var playerCore: PlayerCore = PlayerCore.shared
  
  lazy var fontPicker: FontPickerWindowController = FontPickerWindowController()
  
  lazy var inspector: InspectorWindowController = InspectorWindowController()
  
  lazy var vfWindow: FilterWindowController = {
    let w = FilterWindowController()
    w.filterType = MPVProperty.vf
    return w
  }()
  
  lazy var afWindow: FilterWindowController = {
    let w = FilterWindowController()
    w.filterType = MPVProperty.af
    return w
  }()
  
  lazy var preferenceWindowController: NSWindowController = {
    return MASPreferencesWindowController(viewControllers: [
      PrefGeneralViewController(),
      PrefControlViewController(),
      PrefKeyBindingViewController(),
      PrefAdvancedViewController(),
    ], title: "Preference")
  }()
  
  @IBOutlet weak var menuController: MenuController!
  
  @IBOutlet weak var dockMenu: NSMenu!

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    UserDefaults.standard.register(defaults: Preference.defaultPreference)
    playerCore.startMPV()
    menuController.bindMenuItems()
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }
  
  func applicationDidResignActive(_ notification: Notification) {
//    if NSApp.mainWindow == nil && NSApp.keyWindow == nil {
//      NSApp.terminate(self)
//    }
  }
  
  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return UserDefaults.standard.bool(forKey: Preference.Key.quitWhenNoOpenedWindow)
  }
  
  func applicationShouldTerminate(_ sender: NSApplication) -> NSApplicationTerminateReply {
    playerCore.terminateMPV()
    return .terminateNow
  }
  
  func application(_ sender: NSApplication, openFile filename: String) -> Bool {
    playerCore.openFile(URL(fileURLWithPath: filename))
    return true
  }
  
  // MARK: - Dock menu
  
  func applicationDockMenu(_ sender: NSApplication) -> NSMenu? {
    return dockMenu
  }
  
  // MARK: - Menu actions
  
  @IBAction func openFile(_ sender: NSMenuItem) {
    let panel = NSOpenPanel()
    panel.title = "Choose media file"
    panel.canCreateDirectories = false
    panel.canChooseFiles = true
    panel.canChooseDirectories = false
    panel.resolvesAliases = true
    panel.allowsMultipleSelection = false
    if panel.runModal() == NSFileHandlingPanelOKButton {
      if let url = panel.url {
        if playerCore.ud.bool(forKey: Preference.Key.recordRecentFiles) {
          NSDocumentController.shared().noteNewRecentDocumentURL(url)
        }
        playerCore.openFile(url)
      }
    }
  }
  
  @IBAction func menuOpenScreenshotFolder(_ sender: NSMenuItem) {
    let screenshotPath = UserDefaults.standard.string(forKey: Preference.Key.screenshotFolder)!
    let absoluteScreenshotPath = NSString(string: screenshotPath).expandingTildeInPath
    let url = URL(fileURLWithPath: absoluteScreenshotPath, isDirectory: true)
      NSWorkspace.shared().open(url)
  }
  
  @IBAction func showPreferences(_ sender: AnyObject) {
    preferenceWindowController.showWindow(self)
  }
  
  @IBAction func showVideoFilterWindow(_ sender: AnyObject) {
    vfWindow.showWindow(self)
  }
  
  @IBAction func showAudioFilterWindow(_ sender: AnyObject) {
    afWindow.showWindow(self)
  }
}
