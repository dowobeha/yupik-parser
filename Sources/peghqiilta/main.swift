import Dispatch

var str = "Hello, playground"
/*
DispatchQueue.global(qos: .background).async {
    for i in 0...5 {
        print("Nakaa \(i)")
    }
}

DispatchQueue.global(qos: .userInteractive).async {
    for i in 0...5 {
        print("Aa-a \(i)")
    }
}

print(str)
*/
/*
var workItem: DispatchWorkItem?
workItem = DispatchWorkItem {
    for i in 1..<6 {
        guard let item = workItem, !item.isCancelled else {
            print("cancelled")
            break
        }
        sleep(1)
        print(String(i))
    }
}

workItem?.notify(queue: .main) {
    print("done")
}

DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(2)) {
    workItem?.cancel()
}
DispatchQueue.main.async(execute: workItem!)
*/

/*
func load(delay: UInt32, completion: () -> Void) {
    sleep(delay)
    completion()
}

let group = DispatchGroup()

group.enter()
load(delay: 0) {
    print("1")
    group.leave()
}

group.enter()
load(delay: 0) {
    print("2")
    group.leave()
}

group.enter()
load(delay: 0) {
    print("3")
    group.leave()
}

group.notify(queue: .main) {
    print("done")
}


group.wait()
*/
/*
let semaphore = DispatchSemaphore(value: 0)
let queue = DispatchQueue.global()
let n = 9
for i in 0..<n {
    queue.async {
        print("run \(i)")
        sleep(3)
        semaphore.signal()
    }
}
print("wait")
for i in 0..<n {
    semaphore.wait()
    print("completed \(i)")
}
print("done")
*/


let queue = DispatchQueue.global()
let group = DispatchGroup()
let n = 100
for i in 0..<n {
    queue.async(group: group) {
        print("\(i): Running async task...")
        sleep(3)
        print("\(i): Async task completed")
    }
}
group.wait()
print("done")

print(str)

