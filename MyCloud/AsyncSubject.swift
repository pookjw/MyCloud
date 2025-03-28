import Foundation
import os

final class AsyncSubject<Element> {
    private let osLock: OSAllocatedUnfairLock<[UUID: AsyncStream<Element>.Continuation]> = .init(initialState: [:])

  deinit {
    osLock.withLockUnchecked { continuations in
      for continuation in continuations.values {
        continuation.finish()
      }
    }
  }

  func stream(bufferingPolicy limit: AsyncStream<Element>.Continuation.BufferingPolicy = .unbounded) -> AsyncStream<Element> {
    let stream: AsyncStream<Element> = osLock.withLockUnchecked { continuations in
      let (stream, continuation) = AsyncStream<Element>.makeStream(bufferingPolicy: limit)
      let key = UUID()

      continuation.onTermination = { [osLock] termination in
        switch termination {
        case .cancelled:
          osLock.withLockUnchecked { continuations in
            _ = continuations.removeValue(forKey: key)
          }
        case .finished:
          break
        @unknown default:
          break
        }
      }

      continuations[key] = continuation

      return stream
    }

    return stream
  }

  func yield(_ value: Element) {
    osLock.withLockUnchecked { continuations in
      for continuation in continuations.values {
        continuation.yield(value)
      }
    }
  }

  func yield(
    with result: Result<Element, Never>
  ) {
    osLock.withLockUnchecked { continuations in
      for continuation in continuations.values {
        continuation.yield(with: result)
      }
    }
  }

  func yield() where Element == Void {
    yield(())
  }
}
