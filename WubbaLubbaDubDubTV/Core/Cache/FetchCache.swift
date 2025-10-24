// WubbaLubbaDubDubTV/Core/Cache/FetchCache.swift
import Foundation

actor FetchCache<Key: Hashable, Value> {
    private var tasks: [Key: Task<Value, Error>] = [:]

    func cached(_ key: Key, start: () -> Task<Value, Error>) -> Task<Value, Error> {
        if let task = tasks[key] { return task }
        let task = start()
        tasks[key] = task
        return task
    }

    func remove(_ key: Key) {
        tasks[key] = nil
    }
}
