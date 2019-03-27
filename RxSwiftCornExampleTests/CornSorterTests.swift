//
//  CornSorterTests.swift
//  RxSwiftCornExampleTests
//
//  Created by Fernando on 22.02.19.
//  Copyright © 2019 Fernando. All rights reserved.
//

import Foundation
import XCTest
import RxTest
import RxSwift
@testable import RxSwiftCornExample

class CornSorterTests: XCTestCase {
    func test_sortCorns() {
        let testScheduler = TestScheduler(initialClock: 0)
        let testObserver = testScheduler.createObserver(String.self)
        let disposeBag = DisposeBag()
        
        //Given
        let testInput = ["corn", "waste", "corn", "corn", "waste", "waste", "corn"]
        let observableInput = Observable.from(testInput).asObservable().observeOn(testScheduler)
        let sorter = CornSorter(tractorStream: observableInput)
        let sortCornObservable = sorter.sortedCorns()
        
        // When
        sortCornObservable.subscribe(testObserver).disposed(by: disposeBag)
        
        testScheduler.start()
        
        let expectedEvents = [
            next(1, "corn"),
            next(3, "corn"),
            next(4, "corn"),
            next(7, "corn"),
            completed(8)
        ]
        
        XCTAssertEqual(expectedEvents, testObserver.events)
        
        sorter.currentStatePublisher?.onNext(State(isActive: true))
        XCTAssertFalse(sorter.hasError())
        sorter.currentStatePublisher?.onNext(State(isActive: true))
        XCTAssertTrue(sorter.hasError())
    }
    
    func test_sortCorns_coldObservable() {
        let scheduler = TestScheduler(initialClock: 0)
        let testObserver = scheduler.createObserver(String.self)
        let disposeBag = DisposeBag()
        
        let original: Observable<String> = scheduler.createColdObservable(
        [next(1, "corn"),
         next(2, "waste"),
         next(3, "corn"),
         completed(4)]).asObservable()
        
        let sorter = CornSorter(tractorStream: original)
        let sortCornObservable = sorter.sortedCorns()
        
        sortCornObservable.subscribe(testObserver).disposed(by: disposeBag)
        scheduler.start()
        
        let expectedEvents = [
            next(1, "corn"),
            next(3, "corn"),
            completed(4)
        ]
//
        XCTAssertEqual(expectedEvents, testObserver.events)
    }
}
