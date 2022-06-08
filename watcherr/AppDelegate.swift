import Cocoa


@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    var statusBar: StatusBarController!
    var watcher: Watcher!
    var config: Config!


    func applicationDidFinishLaunching(_ notification: Notification) {
        statusBar = StatusBarController.init()
        watcher = Watcher()

        let jsonData = try! Data(contentsOf: URL(fileURLWithPath: "/Users/pavlos/.config/watcherr/watcherrconfig.json"))
        let decoder = JSONDecoder()
        config = try! decoder.decode(Config.self, from: jsonData)
        config.watches.forEach { watch in
            watcher.start(watch)
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        config.watches.forEach { watcher.stop(path: $0.dir) }
    }
}

/// reload config
/// launch on startup
