//
//  Tests.swift
//  Tests
//
//  Created by Florian Morello on 25/05/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest
import AKTrakt

class Tests: XCTestCase {

    let trakt = Trakt(clientId: "37558e63c821f673801c2c0788f4f877f5ed626bf5ba4493626173b3ac19b594",
                      clientSecret: "9a80ed5b84182af99be0a452696e68e525b2c629e6f2a9a7cd748e4147d85690",
                      applicationId: 3695)

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSearchMovie() {
        let expectation = expectationWithDescription("Searching for a movie")
        trakt.search("avatar", type: .Movies) { result, error in
            guard let movie = result?.first as? TraktMovie else {
                return XCTFail("Response was not a TraktMovie")
            }

            XCTAssertEqual(movie.title, "Avatar")
            XCTAssertEqual(movie.year, 2009)

            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(5) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }

    func testRoute() {
        let expectation = expectationWithDescription("Searching for a show")
        TraktRequestShow(id: 39105).request(trakt) { show, error in
            XCTAssertNil(show?.overview)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(5) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }

    func testRouteExtended() {
        let expectation = expectationWithDescription("Searching for a show extended")
        TraktRequestShow(id: 39105, extended: .Full).request(trakt) { (show, error) in
            XCTAssertNotNil(show?.overview)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(5) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }

    func testSearchShow() {
        let expectation = expectationWithDescription("Searching for a show")
        trakt.search("scandal", type: .Shows) { result, error in
            guard let show = result?.first as? TraktShow else {
                return XCTFail("Response was not a TraktShow")
            }
            XCTAssertEqual(show.title, "Scandal")
            XCTAssertEqual(show.id, 39105)
            XCTAssertEqual(show.year, 2012)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(5) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }

    func testMovie() {
        let expectation = expectationWithDescription("Getting a movie by id")
        TraktRequestMovie(id: 1235).request(trakt) { movie, error in
            XCTAssertEqual(movie?.title, "Cervantes")
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(5) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }

    func testPerson() {
        let expectation = expectationWithDescription("Getting a movie by id")
        TraktRequestPeople(id: "mel-gibson", extended: .Full).request(trakt) { person, error in
            XCTAssertEqual(person?.name, "Mel Gibson")
            XCTAssertEqual(person?.birthday?.description.containsString("1956-01-03"), true)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(5) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }

    func testCasting() {
        let expectation = expectationWithDescription("Getting casting")
        TraktRequestMediaPeople(type: .Shows, id: 39105).request(trakt) { characters, crew, error in
            XCTAssertEqual(characters?.first?.character, "Olivia Pope")
            XCTAssertEqual(characters?.first?.person.name, "Kerry Washington")

            guard let exProducer = crew?[.Production]?.filter({ $0.job == "Executive Producer" }).first else {
                return XCTFail("Executive Producer not found")
            }
            XCTAssertEqual(exProducer.person.name, "Shonda Rhimes")

            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(5) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }

    func testCredits() {
        let expectation = expectationWithDescription("Getting person's credits")

        TraktRequestPeopleCredits(type: .Movies, id: "mel-gibson").request(trakt) { tuple, error in
            guard let role = tuple?.cast?.filter({ $0.character == "Driver" }).first else {
                return XCTFail("Cannot find actor character")
            }
            XCTAssertEqual((role.media as? TraktMovie)?.title, "Get the Gringo")
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(5) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }

    func testImages() {
        let expectation = expectationWithDescription("Getting movie")
        TraktRequestMovie(id: "tron-legacy-2010", extended: .Images).request(trakt) { movie, error in
            XCTAssertTrue(movie?.images.count > 0)

            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(5) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }

    func testSeasons() {
        let expectation = expectationWithDescription("Getting seasons")
        trakt.seasons(39105) { seasons, error in
            XCTAssertTrue(seasons?.count == 7)

            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(5) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }

    func testEpisodes() {
        let expectation = expectationWithDescription("Getting episodes")
        trakt.episodes(39105, seasonNumber: 5) { episodes, error in
            XCTAssertTrue(episodes?.count == 21)
            XCTAssertEqual(episodes?.last?.title, "That's My Girl")

            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(5) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}