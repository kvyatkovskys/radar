//
//  CircleTests.swift
//  CircleTests
//
//  Created by Kviatkovskii on 08/12/2017.
//  Copyright © 2017 Kviatkovskii. All rights reserved.
//

import XCTest
import RxSwift
import Unbox

@testable import Circle

class CircleTests: XCTestCase {
    fileprivate let disposeBag = DisposeBag()
    
    func testGetPlaces() {
        let testExpectation = expectation(description: "Ожидаем ответ от сервера")
        let location = CLLocation(latitude: 55.7522, longitude: 37.6156)
        let categories = PlaceSetting().allCategories
        PlaceService().loadPlaces(location, categories, 1000.0).asObservable().subscribe(onNext: { (model) in
            XCTAssertNotNil(model, "Моделька пустая, печалька")
            testExpectation.fulfill()
        }, onError: { (error) in
            XCTFail("Всё сломалось модельки нет \(error)")
        }).disposed(by: disposeBag)
        
        waitForExpectations(timeout: 10.0) { error in
            if let error = error {
                XCTFail("Не дождались результатов: \(error)")
            }
        }
    }
}
