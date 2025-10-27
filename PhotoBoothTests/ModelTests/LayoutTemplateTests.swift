import XCTest
import Foundation
import UIKit
@testable import com_bcaps_photobooth

class LayoutTemplateTests: XCTestCase {

    // MARK: - Test Setup and Teardown

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testLayoutTemplateInitialization() {
        // Test basic initialization
        let layout = LayoutTemplate(
            name: "Test Layout",
            description: "A test layout",
            photoCount: 4,
            aspectRatio: CGSize(width: 2, height: 3)
        )

        XCTAssertNotNil(layout.id)
        XCTAssertEqual(layout.name, "Test Layout")
        XCTAssertEqual(layout.description, "A test layout")
        XCTAssertEqual(layout.photoCount, 4)
        XCTAssertEqual(layout.aspectRatio, CGSize(width: 2, height: 3))
    }

    func testLayoutTemplateInitializationWithCustomId() {
        // Test initialization with custom ID
        let customId = UUID()
        let layout = LayoutTemplate(
            id: customId,
            name: "Custom Layout",
            description: "Custom description",
            photoCount: 2,
            aspectRatio: CGSize(width: 1, height: 1)
        )

        XCTAssertEqual(layout.id, customId)
        XCTAssertEqual(layout.name, "Custom Layout")
        XCTAssertEqual(layout.photoCount, 2)
    }

    // MARK: - Default Layouts Tests

    func testDefaultLayoutsExist() {
        // Test that default layouts are available
        let defaultLayouts = LayoutTemplate.defaultLayouts

        XCTAssertFalse(defaultLayouts.isEmpty)
        XCTAssertGreaterThanOrEqual(defaultLayouts.count, 4)
    }

    func testDefaultLayoutsSinglePhoto() {
        // Test single photo layout
        let singleLayout = LayoutTemplate.defaultLayouts.first { $0.photoCount == 1 }

        XCTAssertNotNil(singleLayout)
        XCTAssertEqual(singleLayout?.name, "Single Photo")
        XCTAssertEqual(singleLayout?.photoCount, 1)
        XCTAssertEqual(singleLayout?.aspectRatio, CGSize(width: 4, height: 6))
    }

    func testDefaultLayoutsPhotoStrip() {
        // Test photo strip layout
        let stripLayout = LayoutTemplate.defaultLayouts.first { $0.name == "Photo Strip" }

        XCTAssertNotNil(stripLayout)
        XCTAssertEqual(stripLayout?.photoCount, 4)
        XCTAssertEqual(stripLayout?.aspectRatio, CGSize(width: 2, height: 6))
        XCTAssertEqual(stripLayout?.description, "Classic 4-photo strip")
    }

    func testDefaultLayouts2x2Grid() {
        // Test 2x2 grid layout
        let gridLayout = LayoutTemplate.defaultLayouts.first { $0.name == "2x2 Grid" }

        XCTAssertNotNil(gridLayout)
        XCTAssertEqual(gridLayout?.photoCount, 4)
        XCTAssertEqual(gridLayout?.aspectRatio, CGSize(width: 4, height: 4))
        XCTAssertEqual(gridLayout?.description, "Four photos in a grid")
    }

    func testDefaultLayoutsCollage() {
        // Test collage layout
        let collageLayout = LayoutTemplate.defaultLayouts.first { $0.name == "Collage" }

        XCTAssertNotNil(collageLayout)
        XCTAssertEqual(collageLayout?.photoCount, 6)
        XCTAssertEqual(collageLayout?.aspectRatio, CGSize(width: 6, height: 4))
        XCTAssertEqual(collageLayout?.description, "Multiple photos collage")
    }

    func testDefaultLayoutsUniqueIds() {
        // Test that all default layouts have unique IDs
        let defaultLayouts = LayoutTemplate.defaultLayouts
        let ids = Set(defaultLayouts.map { $0.id })

        XCTAssertEqual(ids.count, defaultLayouts.count, "All default layout IDs should be unique")
    }

    func testDefaultLayoutsUniqueNames() {
        // Test that all default layouts have unique names
        let defaultLayouts = LayoutTemplate.defaultLayouts
        let names = Set(defaultLayouts.map { $0.name })

        XCTAssertEqual(names.count, defaultLayouts.count, "All default layout names should be unique")
    }

    // MARK: - Codable Tests

    func testLayoutTemplateCodableConformance() {
        // Test that LayoutTemplate can be encoded and decoded
        let layout = TestHelpers.createTestLayoutTemplate()

        TestHelpers.assertJSONEquality(layout, type: LayoutTemplate.self)
    }

    func testLayoutTemplateCodableWithDefaultLayouts() {
        // Test encoding/decoding of default layouts
        for layout in LayoutTemplate.defaultLayouts {
            TestHelpers.assertJSONEquality(layout, type: LayoutTemplate.self)
        }
    }

    func testLayoutTemplateCodablePreservesAllProperties() {
        // Test that all properties are preserved during encoding/decoding
        let originalLayout = LayoutTemplate(
            name: "Test Layout",
            description: "Test description",
            photoCount: 5,
            aspectRatio: CGSize(width: 3.5, height: 2.1)
        )

        do {
            let data = try TestHelpers.encodeToJSON(originalLayout)
            let decodedLayout = try TestHelpers.decodeFromJSON(data, type: LayoutTemplate.self)

            XCTAssertEqual(originalLayout.id, decodedLayout.id)
            XCTAssertEqual(originalLayout.name, decodedLayout.name)
            XCTAssertEqual(originalLayout.description, decodedLayout.description)
            XCTAssertEqual(originalLayout.photoCount, decodedLayout.photoCount)
            XCTAssertEqual(originalLayout.aspectRatio.width, decodedLayout.aspectRatio.width, accuracy: 0.001)
            XCTAssertEqual(originalLayout.aspectRatio.height, decodedLayout.aspectRatio.height, accuracy: 0.001)
        } catch {
            XCTFail("Codable test failed: \(error)")
        }
    }

    // MARK: - Equatable Tests

    func testLayoutTemplateEquality() {
        // Test that layouts with same properties are equal
        let id = UUID()
        let aspectRatio = CGSize(width: 2, height: 3)

        let layout1 = LayoutTemplate(
            id: id,
            name: "Test",
            description: "Description",
            photoCount: 4,
            aspectRatio: aspectRatio
        )

        let layout2 = LayoutTemplate(
            id: id,
            name: "Test",
            description: "Description",
            photoCount: 4,
            aspectRatio: aspectRatio
        )

        XCTAssertEqual(layout1, layout2)
    }

    func testLayoutTemplateInequality() {
        // Test that layouts with different properties are not equal
        let layout1 = LayoutTemplate(
            name: "Layout 1",
            description: "Description 1",
            photoCount: 4,
            aspectRatio: CGSize(width: 2, height: 3)
        )

        let layout2 = LayoutTemplate(
            name: "Layout 2",
            description: "Description 2",
            photoCount: 4,
            aspectRatio: CGSize(width: 2, height: 3)
        )

        XCTAssertNotEqual(layout1, layout2) // Different IDs
    }

    func testLayoutTemplateInequalityDifferentProperties() {
        // Test inequality with different properties
        let id = UUID()

        let layout1 = LayoutTemplate(
            id: id,
            name: "Test",
            description: "Description",
            photoCount: 4,
            aspectRatio: CGSize(width: 2, height: 3)
        )

        let layout2 = LayoutTemplate(
            id: id,
            name: "Test",
            description: "Description",
            photoCount: 6, // Different photo count
            aspectRatio: CGSize(width: 2, height: 3)
        )

        XCTAssertNotEqual(layout1, layout2)
    }

    // MARK: - Property Validation Tests

    func testLayoutTemplatePhotoCountValidation() {
        // Test various photo counts
        let validCounts = [1, 2, 3, 4, 5, 6, 8, 9, 10]

        for count in validCounts {
            let layout = LayoutTemplate(
                name: "Test \(count)",
                description: "Test",
                photoCount: count,
                aspectRatio: CGSize(width: 1, height: 1)
            )
            XCTAssertEqual(layout.photoCount, count)
        }
    }

    func testLayoutTemplateAspectRatioValidation() {
        // Test various aspect ratios
        let aspectRatios = [
            CGSize(width: 1, height: 1),
            CGSize(width: 2, height: 3),
            CGSize(width: 4, height: 6),
            CGSize(width: 16, height: 9),
            CGSize(width: 0.5, height: 1)
        ]

        for ratio in aspectRatios {
            let layout = LayoutTemplate(
                name: "Test",
                description: "Test",
                photoCount: 1,
                aspectRatio: ratio
            )
            XCTAssertEqual(layout.aspectRatio, ratio)
        }
    }

    func testLayoutTemplateNameValidation() {
        // Test various name formats
        let validNames = [
            "Single Photo",
            "2x2 Grid",
            "Photo Strip",
            "Custom Layout 123",
            "Layout with Spaces",
            "A"
        ]

        for name in validNames {
            let layout = LayoutTemplate(
                name: name,
                description: "Test",
                photoCount: 1,
                aspectRatio: CGSize(width: 1, height: 1)
            )
            XCTAssertEqual(layout.name, name)
        }
    }

    // MARK: - Edge Cases

    func testLayoutTemplateWithZeroPhotoCount() {
        // Test with zero photo count (edge case)
        let layout = LayoutTemplate(
            name: "Empty Layout",
            description: "No photos",
            photoCount: 0,
            aspectRatio: CGSize(width: 1, height: 1)
        )

        XCTAssertEqual(layout.photoCount, 0)
        TestHelpers.assertJSONEquality(layout, type: LayoutTemplate.self)
    }

    func testLayoutTemplateWithLargePhotoCount() {
        // Test with large photo count
        let layout = LayoutTemplate(
            name: "Large Layout",
            description: "Many photos",
            photoCount: 100,
            aspectRatio: CGSize(width: 10, height: 10)
        )

        XCTAssertEqual(layout.photoCount, 100)
        TestHelpers.assertJSONEquality(layout, type: LayoutTemplate.self)
    }

    func testLayoutTemplateWithEmptyStrings() {
        // Test with empty strings
        let layout = LayoutTemplate(
            name: "",
            description: "",
            photoCount: 1,
            aspectRatio: CGSize(width: 1, height: 1)
        )

        XCTAssertEqual(layout.name, "")
        XCTAssertEqual(layout.description, "")
        TestHelpers.assertJSONEquality(layout, type: LayoutTemplate.self)
    }

    func testLayoutTemplateWithUnicodeStrings() {
        // Test with unicode characters
        let layout = LayoutTemplate(
            name: "📸 Photo Layout 🎨",
            description: "Layout with émojis and spéciål characters",
            photoCount: 4,
            aspectRatio: CGSize(width: 2, height: 3)
        )

        XCTAssertEqual(layout.name, "📸 Photo Layout 🎨")
        XCTAssertEqual(layout.description, "Layout with émojis and spéciål characters")
        TestHelpers.assertJSONEquality(layout, type: LayoutTemplate.self)
    }

    func testLayoutTemplateWithExtremeAspectRatios() {
        // Test with extreme aspect ratios
        let extremeRatios = [
            CGSize(width: 0.001, height: 1),
            CGSize(width: 1000, height: 1),
            CGSize(width: 1, height: 0.001),
            CGSize(width: 1, height: 1000)
        ]

        for ratio in extremeRatios {
            let layout = LayoutTemplate(
                name: "Extreme",
                description: "Extreme aspect ratio",
                photoCount: 1,
                aspectRatio: ratio
            )
            XCTAssertEqual(layout.aspectRatio, ratio)
        }
    }

    // MARK: - Performance Tests

    func testLayoutTemplateInitializationPerformance() {
        // Test that layout initialization is fast
        measure {
            for i in 0..<1000 {
                _ = LayoutTemplate(
                    name: "Layout \(i)",
                    description: "Description \(i)",
                    photoCount: i % 10 + 1,
                    aspectRatio: CGSize(width: 2, height: 3)
                )
            }
        }
    }

    func testLayoutTemplateCodablePerformance() {
        // Test that encoding/decoding is fast
        let layouts = (0..<100).map { i in
            LayoutTemplate(
                name: "Layout \(i)",
                description: "Description \(i)",
                photoCount: i % 10 + 1,
                aspectRatio: CGSize(width: 2, height: 3)
            )
        }

        measure {
            for layout in layouts {
                do {
                    let data = try TestHelpers.encodeToJSON(layout)
                    _ = try TestHelpers.decodeFromJSON(data, type: LayoutTemplate.self)
                } catch {
                    XCTFail("Performance test failed: \(error)")
                }
            }
        }
    }

    func testDefaultLayoutsPerformance() {
        // Test that accessing default layouts is fast
        measure {
            for _ in 0..<1000 {
                _ = LayoutTemplate.defaultLayouts
            }
        }
    }

    // MARK: - Array Operations Tests

    func testLayoutTemplateArraySorting() {
        // Test sorting layouts by photo count
        let layouts = [
            LayoutTemplate(name: "A", description: "A", photoCount: 5, aspectRatio: CGSize(width: 1, height: 1)),
            LayoutTemplate(name: "B", description: "B", photoCount: 2, aspectRatio: CGSize(width: 1, height: 1)),
            LayoutTemplate(name: "C", description: "C", photoCount: 8, aspectRatio: CGSize(width: 1, height: 1))
        ]

        let sortedLayouts = layouts.sorted { $0.photoCount < $1.photoCount }

        XCTAssertEqual(sortedLayouts[0].photoCount, 2)
        XCTAssertEqual(sortedLayouts[1].photoCount, 5)
        XCTAssertEqual(sortedLayouts[2].photoCount, 8)
    }

    func testLayoutTemplateArrayFiltering() {
        // Test filtering layouts
        let layouts = LayoutTemplate.defaultLayouts

        let singlePhotoLayouts = layouts.filter { $0.photoCount == 1 }
        let multiPhotoLayouts = layouts.filter { $0.photoCount > 1 }
        let squareLayouts = layouts.filter { $0.aspectRatio.width == $0.aspectRatio.height }

        XCTAssertGreaterThanOrEqual(singlePhotoLayouts.count, 1)
        XCTAssertGreaterThanOrEqual(multiPhotoLayouts.count, 1)
        XCTAssertGreaterThanOrEqual(squareLayouts.count, 0) // May or may not have square layouts
    }

    // MARK: - Memory Tests

    func testLayoutTemplateMemoryUsage() {
        // Test that layouts don't use excessive memory
        let (layouts, memoryUsed) = TestHelpers.measureMemoryUsage {
            return (0..<1000).map { i in
                LayoutTemplate(
                    name: "Layout \(i)",
                    description: "Description for layout number \(i)",
                    photoCount: i % 10 + 1,
                    aspectRatio: CGSize(width: Double(i % 5 + 1), height: Double(i % 3 + 1))
                )
            }
        }

        XCTAssertEqual(layouts.count, 1000)
        // Each layout should use minimal memory
        XCTAssertLessThan(memoryUsed, 5 * 1024 * 1024) // Less than 5MB for 1000 layouts
    }

    // MARK: - Real-world Scenario Tests

    func testLayoutTemplateUsageScenario() {
        // Test realistic usage scenario
        let availableLayouts = LayoutTemplate.defaultLayouts

        // User selects a layout
        let selectedLayout = availableLayouts.first { $0.photoCount == 4 }
        XCTAssertNotNil(selectedLayout)

        // System stores the selection
        let encoded = try? TestHelpers.encodeToJSON(selectedLayout!)
        XCTAssertNotNil(encoded)

        // System retrieves the selection
        let decoded = try? TestHelpers.decodeFromJSON(encoded!, type: LayoutTemplate.self)
        XCTAssertNotNil(decoded)
        XCTAssertEqual(selectedLayout, decoded)
    }

    func testLayoutTemplateCustomization() {
        // Test creating custom layouts
        let customLayouts = [
            LayoutTemplate(name: "Panoramic", description: "Wide format", photoCount: 3, aspectRatio: CGSize(width: 16, height: 6)),
            LayoutTemplate(name: "Portrait", description: "Tall format", photoCount: 2, aspectRatio: CGSize(width: 3, height: 8)),
            LayoutTemplate(name: "Square Grid", description: "Perfect square", photoCount: 9, aspectRatio: CGSize(width: 1, height: 1))
        ]

        for layout in customLayouts {
            XCTAssertNotNil(layout.id)
            XCTAssertFalse(layout.name.isEmpty)
            XCTAssertGreaterThan(layout.photoCount, 0)
            TestHelpers.assertJSONEquality(layout, type: LayoutTemplate.self)
        }
    }
}