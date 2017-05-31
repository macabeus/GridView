//
//  GridViewTests.swift
//  GridViewTests
//
//  Created by Bruno Macabeus Aquino on 31/05/17.
//  Copyright © 2017 Bruno Macabeus Aquino. All rights reserved.
//

import Quick
import Nimble
import GridView


class GridConfigurationTests: QuickSpec {
    override func spec() {
        
        let slots: [[Slot]] = [[]]
        let gridConfiguration = GridConfiguration(slots: slots)
        
        describe("a gridConfiguration") {
            it("is loud") {
                expect(gridConfiguration.slots.count).to(equal(1))
            }
        }
    }
}
