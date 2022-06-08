struct Watch: Decodable {
    var dir: String
    var debounce: Bool?
    var triggerFiles: Array<String>?
    var run: Array<String>
}

struct Config: Decodable {
    var watches: Array<Watch>
}
