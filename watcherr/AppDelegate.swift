import Cocoa


@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    var statusBar: StatusBarController!
    var watcher: Watcher!

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusBar = StatusBarController.init()
        watcher = Watcher()

        watcher.start(path: "/Users/pavlos/Library/Application Support/Firefox/Profiles/ru387quz.arken", debounce: true) { fileWatcherEvent in
            print(fileWatcherEvent)
            print(fileWatcherEvent.path)
            print(fileWatcherEvent.flags)
            print(fileWatcherEvent.description)
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        watcher.stop(path: "/Users/pavlos/Library/Application Support/Firefox/Profiles/ru387quz.arken")
    }
}
