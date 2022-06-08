import Foundation
import FileWatcher
import RxSwift
import Commands


struct WatcherData: Equatable {
    var path: String
    var watcher: FileWatcher
    var debounce: Bool
    var subject: PublishSubject<FileWatcherEvent>?

    static func == (lhs: WatcherData, rhs: WatcherData) -> Bool {
        lhs.path == rhs.path
    }
}

typealias Callback = (_ fileWatcherEvent: FileWatcherEvent) -> Void


let disposeBag = DisposeBag()

struct Watcher {
    var watchers: Array<WatcherData> = []


    mutating func start(_ watch: Watch) {
        start(path: watch.dir,
              debounce: watch.debounce ?? false,
              filterFiles: watch.triggerFiles ?? nil,
              callback: { fileWatcherEvent -> Void in
            watch.run.forEach { cmd in
                print("will run: \(cmd)")
                Commands.Bash.run("cd '\(watch.dir)'; \(cmd)")
//                print(Commands.Bash.run("cd '\(watch.dir)'; \(cmd)").output)
            }
        })
    }

    mutating func start(path: String, debounce: Bool = false, filterFiles: Array<String>? = nil, callback: @escaping Callback) {
        let watcher = FileWatcher([path])
        watcher.queue = DispatchQueue.global()

        var subject: PublishSubject<FileWatcherEvent>? = nil
        if debounce {
            subject = PublishSubject()
            let wrappedCallback: Callback = {fileWatcherEvent -> Void in
                subject!.onNext(fileWatcherEvent)
            }
            watcher.callback = wrappedCallback
            subject!
                .filter({ event in
                    if filterFiles == nil {
                        return true
                    }
                    let triggerFile = String(event.path.split(separator: "/").last!)
                    if (filterFiles!.contains(triggerFile)) {
                        return true
                    }
                    return false
                })
                .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
                .subscribe({ event in
                    callback(event.element!)
                })
                .disposed(by: disposeBag)
        } else {
            watcher.callback = callback
        }

        watcher.start()
        watchers.append(WatcherData(path: path, watcher: watcher, debounce: debounce, subject: subject))
    }

    mutating func stop(path: String) {
        let toRemove = watchers.all { $0.path == path }
        toRemove.forEach { $0.watcher.stop() }
        watchers.removeAll { $0.path == path }
    }
}


extension Array where Element: Equatable {
    func all(where predicate: (Element) -> Bool) -> [Element] {
        return self.compactMap { predicate($0) ? $0 : nil }
    }
}
