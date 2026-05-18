func debugLog(_ message: @autoclosure () -> String) {
#if DEBUG
    print(message())
#endif
}
