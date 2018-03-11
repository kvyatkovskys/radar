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
    fileprivate let location = CLLocation(latitude: 55.7522, longitude: 37.6156)
    fileprivate let distance = 1000.0
    
    func testLoadPhotos() {
        let testExpectation = expectation(description: "Ожидаем ответ от сервера")
        let viewModel = PlaceViewModel(PlaceService())
        
        viewModel.getPlaces(location: location, distance: distance)
            .flatMapLatest { (places) -> Observable<DetailImagesModel> in
                return DetailService().loadPhotos(id: places.items[0].id)
            }
            .asObservable()
            .subscribe(onNext: { (model) in
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
    
    func testLoadPicture() {
        let testExpectation = expectation(description: "Ожидаем ответ от сервера")
        let viewModel = PlaceViewModel(PlaceService())
        
        viewModel.getPlaces(location: location, distance: distance)
            .flatMapLatest { (places) -> Observable<URL?> in
                return DetailService().loadPicture(id: places.items[0].id)
            }
            .asObservable()
            .subscribe(onNext: { (url) in
                XCTAssertNotNil(url, "Нет урла для картинки")
                testExpectation.fulfill()
            }, onError: { (error) in
                XCTFail("Всё сломалось урла нет \(error)")
            }).disposed(by: disposeBag)
        
        waitForExpectations(timeout: 10.0) { error in
            if let error = error {
                XCTFail("Не дождались результатов: \(error)")
            }
        }
    }
    
    func testMoreLoadedPlaces() {
        let testExpectation = expectation(description: "Ожидаем ответ от сервера")
        let viewModel = PlaceViewModel(PlaceService())
        
        viewModel.getPlaces(location: location, distance: distance)
            .flatMapLatest { (places) -> Observable<Places> in
                return viewModel.getMorePlaces(url: places.next!)
            }
            .asObservable()
            .subscribe(onNext: { (model) in
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
    
    func testModelPlaces() {
        let testExpectation = expectation(description: "Ожидаем ответ от сервера")
        let viewModel = PlaceViewModel(PlaceService())
        
        viewModel.getPlaces(location: location, distance: distance)
            .asObservable()
            .subscribe(onNext: { (model) in
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
    
    func testModelDetailPlace() {
        let testExpectation = expectation(description: "Ожидаем ответ от сервера")
        let viewModel = PlaceViewModel(PlaceService())
        
        viewModel.getPlaces(location: location, distance: distance)
            .flatMapFirst { (places) -> Observable<DetailPlaceViewModel> in
                return Observable.just(DetailPlaceViewModel(places.items[0],
                                                            places.titles[0],
                                                            places.ratings[0],
                                                            FavoritesService()))
            }
            .asObservable()
            .subscribe(onNext: { (model) in
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
