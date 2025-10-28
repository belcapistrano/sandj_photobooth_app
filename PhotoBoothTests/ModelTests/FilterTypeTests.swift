import XCTest
import Foundation
@testable import com_bcaps_photobooth

class FilterTypeTests: XCTestCase {

    // MARK: - Test Setup and Teardown

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: - Basic Enum Tests

    func testFilterTypeRawValues() {
        // Test that all expected wedding filter types exist with correct raw values
        XCTAssertEqual(FilterType.original.rawValue, "Original")
        XCTAssertEqual(FilterType.warmRomance.rawValue, "Warm")
        XCTAssertEqual(FilterType.classicFilm.rawValue, "Classic")
        XCTAssertEqual(FilterType.elegantBW.rawValue, "B&W")
        XCTAssertEqual(FilterType.softDream.rawValue, "Soft")
    }

    func testFilterTypeAllCases() {
        // Test that all cases are included in allCases
        let allCases = FilterType.allCases
        let expectedCount = 5

        XCTAssertEqual(allCases.count, expectedCount)
        XCTAssertTrue(allCases.contains(.original))
        XCTAssertTrue(allCases.contains(.warmRomance))
        XCTAssertTrue(allCases.contains(.classicFilm))
        XCTAssertTrue(allCases.contains(.elegantBW))
        XCTAssertTrue(allCases.contains(.softDream))
    }

    func testFilterTypeUniqueRawValues() {
        // Test that all raw values are unique
        let allCases = FilterType.allCases
        let rawValues = allCases.map { $0.rawValue }
        let uniqueRawValues = Set(rawValues)

        XCTAssertEqual(rawValues.count, uniqueRawValues.count, "All raw values should be unique")
    }

    // MARK: - Display Name Tests

    func testFilterTypeDisplayNames() {
        // Test that all filters have proper display names
        let expectedDisplayNames: [FilterType: String] = [
            .none: "None",
            .vintage: "Vintage",
            .blackAndWhite: "B&W",
            .sepia: "Sepia",
            .vibrant: "Vibrant",
            .dramatic: "Dramatic",
            .cool: "Cool",
            .warm: "Warm"
        ]

        for (filter, expectedName) in expectedDisplayNames {
            XCTAssertEqual(filter.displayName, expectedName)
        }
    }

    func testFilterTypeDisplayNameNotEmpty() {
        // Test that all display names are non-empty
        for filter in FilterType.allCases {
            XCTAssertFalse(filter.displayName.isEmpty, "Display name for \(filter) should not be empty")
        }
    }

    // MARK: - Description Tests

    func testFilterTypeDescriptions() {
        // Test that all filters have proper descriptions
        let expectedDescriptions: [FilterType: String] = [
            .none: "Original photo",
            .vintage: "Classic vintage look",
            .blackAndWhite: "Timeless black and white",
            .sepia: "Warm sepia tone",
            .vibrant: "Enhanced colors",
            .dramatic: "High contrast drama",
            .cool: "Cool blue tones",
            .warm: "Warm golden tones"
        ]

        for (filter, expectedDescription) in expectedDescriptions {
            XCTAssertEqual(filter.description, expectedDescription)
        }
    }

    func testFilterTypeDescriptionNotEmpty() {
        // Test that all descriptions are non-empty
        for filter in FilterType.allCases {
            XCTAssertFalse(filter.description.isEmpty, "Description for \(filter) should not be empty")
        }
    }

    func testFilterTypeDescriptionsDifferent() {
        // Test that all descriptions are unique
        let descriptions = FilterType.allCases.map { $0.description }
        let uniqueDescriptions = Set(descriptions)

        XCTAssertEqual(descriptions.count, uniqueDescriptions.count, "All descriptions should be unique")
    }

    // MARK: - Codable Tests

    func testFilterTypeCodableConformance() {
        // Test that FilterType can be encoded and decoded
        for filter in FilterType.allCases {
            TestHelpers.assertJSONEquality(filter, type: FilterType.self)
        }
    }

    func testFilterTypeCodablePreservesRawValue() {
        // Test that encoding/decoding preserves raw values
        for filter in FilterType.allCases {
            do {
                let data = try TestHelpers.encodeToJSON(filter)
                let decoded = try TestHelpers.decodeFromJSON(data, type: FilterType.self)

                XCTAssertEqual(filter, decoded)
                XCTAssertEqual(filter.rawValue, decoded.rawValue)
            } catch {
                XCTFail("Codable test failed for \(filter): \(error)")
            }
        }
    }

    func testFilterTypeArrayCodable() {
        // Test that arrays of FilterType can be encoded and decoded
        let filters = FilterType.allCases

        do {
            let data = try TestHelpers.encodeToJSON(filters)
            let decoded = try TestHelpers.decodeFromJSON(data, type: [FilterType].self)

            XCTAssertEqual(filters, decoded)
        } catch {
            XCTFail("Array codable test failed: \(error)")
        }
    }

    // MARK: - String Initialization Tests

    func testFilterTypeStringInitialization() {
        // Test that FilterType can be initialized from string
        let validRawValues = [
            "None", "Vintage", "B&W", "Sepia", "Vibrant", "Dramatic", "Cool", "Warm"
        ]

        for rawValue in validRawValues {
            let filter = FilterType(rawValue: rawValue)
            XCTAssertNotNil(filter, "Should be able to create FilterType from '\(rawValue)'")
        }
    }

    func testFilterTypeInvalidStringInitialization() {
        // Test that invalid strings return nil
        let invalidRawValues = [
            "none", "VINTAGE", "black and white", "sepia_tone", "Invalid", "", " None "
        ]

        for rawValue in invalidRawValues {
            let filter = FilterType(rawValue: rawValue)
            XCTAssertNil(filter, "Should not be able to create FilterType from invalid value '\(rawValue)'")
        }
    }

    // MARK: - Equality Tests

    func testFilterTypeEquality() {
        // Test that same filter types are equal
        XCTAssertEqual(FilterType.none, FilterType.none)
        XCTAssertEqual(FilterType.vintage, FilterType.vintage)
        XCTAssertEqual(FilterType.blackAndWhite, FilterType.blackAndWhite)
    }

    func testFilterTypeInequality() {
        // Test that different filter types are not equal
        XCTAssertNotEqual(FilterType.none, FilterType.vintage)
        XCTAssertNotEqual(FilterType.vintage, FilterType.sepia)
        XCTAssertNotEqual(FilterType.cool, FilterType.warm)
    }

    // MARK: - Hashable Tests

    func testFilterTypeHashable() {
        // Test that FilterType can be used in Set and Dictionary
        let filterSet = Set(FilterType.allCases)
        XCTAssertEqual(filterSet.count, FilterType.allCases.count)

        let filterDict = Dictionary(uniqueKeysWithValues: FilterType.allCases.map { ($0, $0.displayName) })
        XCTAssertEqual(filterDict.count, FilterType.allCases.count)
    }

    func testFilterTypeHashValues() {
        // Test that different filters have different hash values (most of the time)
        let hashValues = FilterType.allCases.map { $0.hashValue }
        let uniqueHashValues = Set(hashValues)

        // While hash collisions are possible, it's unlikely with only 8 values
        XCTAssertEqual(hashValues.count, uniqueHashValues.count, "Hash values should typically be unique")
    }

    // MARK: - Switch Statement Tests

    func testFilterTypeSwitchStatement() {
        // Test that all cases can be handled in switch statement
        for filter in FilterType.allCases {
            var handled = false

            switch filter {
            case .none:
                handled = true
            case .vintage:
                handled = true
            case .blackAndWhite:
                handled = true
            case .sepia:
                handled = true
            case .vibrant:
                handled = true
            case .dramatic:
                handled = true
            case .cool:
                handled = true
            case .warm:
                handled = true
            }

            XCTAssertTrue(handled, "Filter \(filter) should be handled in switch statement")
        }
    }

    // MARK: - Categorization Tests

    func testFilterTypeColorCategories() {
        // Test categorizing filters by color enhancement
        func isColorEnhancing(_ filter: FilterType) -> Bool {
            switch filter {
            case .vibrant, .cool, .warm:
                return true
            case .none, .vintage, .blackAndWhite, .sepia, .dramatic:
                return false
            }
        }

        XCTAssertFalse(isColorEnhancing(.none))
        XCTAssertFalse(isColorEnhancing(.vintage))
        XCTAssertFalse(isColorEnhancing(.blackAndWhite))
        XCTAssertFalse(isColorEnhancing(.sepia))
        XCTAssertTrue(isColorEnhancing(.vibrant))
        XCTAssertFalse(isColorEnhancing(.dramatic))
        XCTAssertTrue(isColorEnhancing(.cool))
        XCTAssertTrue(isColorEnhancing(.warm))
    }

    func testFilterTypeMonochromeCategories() {
        // Test categorizing filters by monochrome
        func isMonochrome(_ filter: FilterType) -> Bool {
            switch filter {
            case .blackAndWhite, .sepia:
                return true
            case .none, .vintage, .vibrant, .dramatic, .cool, .warm:
                return false
            }
        }

        XCTAssertFalse(isMonochrome(.none))
        XCTAssertFalse(isMonochrome(.vintage))
        XCTAssertTrue(isMonochrome(.blackAndWhite))
        XCTAssertTrue(isMonochrome(.sepia))
        XCTAssertFalse(isMonochrome(.vibrant))
        XCTAssertFalse(isMonochrome(.dramatic))
        XCTAssertFalse(isMonochrome(.cool))
        XCTAssertFalse(isMonochrome(.warm))
    }

    // MARK: - Performance Tests

    func testFilterTypePerformance() {
        // Test that filter type operations are fast
        measure {
            for _ in 0..<10000 {
                _ = FilterType.allCases
                for filter in FilterType.allCases {
                    _ = filter.displayName
                    _ = filter.description
                    _ = filter.rawValue
                }
            }
        }
    }

    func testFilterTypeCodablePerformance() {
        // Test that encoding/decoding is fast
        let filters = Array(repeating: FilterType.allCases, count: 100).flatMap { $0 }

        measure {
            for filter in filters {
                do {
                    let data = try TestHelpers.encodeToJSON(filter)
                    _ = try TestHelpers.decodeFromJSON(data, type: FilterType.self)
                } catch {
                    XCTFail("Performance test failed: \(error)")
                }
            }
        }
    }

    func testFilterTypeSwitchPerformance() {
        // Test that switch statements are fast
        let filters = Array(repeating: FilterType.allCases, count: 1000).flatMap { $0 }

        measure {
            for filter in filters {
                switch filter {
                case .none:
                    break
                case .vintage:
                    break
                case .blackAndWhite:
                    break
                case .sepia:
                    break
                case .vibrant:
                    break
                case .dramatic:
                    break
                case .cool:
                    break
                case .warm:
                    break
                }
            }
        }
    }

    // MARK: - Array Operations Tests

    func testFilterTypeArrayOperations() {
        // Test common array operations with FilterType
        let filters = FilterType.allCases

        // Test filtering
        let colorFilters = filters.filter { filter in
            ![FilterType.none, FilterType.blackAndWhite].contains(filter)
        }
        XCTAssertEqual(colorFilters.count, 6)

        // Test mapping
        let displayNames = filters.map { $0.displayName }
        XCTAssertEqual(displayNames.count, filters.count)

        // Test sorting
        let sortedFilters = filters.sorted { $0.rawValue < $1.rawValue }
        XCTAssertEqual(sortedFilters.count, filters.count)
    }

    func testFilterTypeSetOperations() {
        // Test Set operations with FilterType
        let set1: Set<FilterType> = [.none, .vintage, .sepia]
        let set2: Set<FilterType> = [.vintage, .dramatic, .cool]

        let intersection = set1.intersection(set2)
        let union = set1.union(set2)
        let difference = set1.subtracting(set2)

        XCTAssertEqual(intersection, [.vintage])
        XCTAssertEqual(union.count, 5)
        XCTAssertEqual(difference, [.none, .sepia])
    }

    // MARK: - Real-world Usage Tests

    func testFilterTypeInUserPreferences() {
        // Test using FilterType for user preferences
        func saveUserPreference(filter: FilterType) -> String {
            return "User selected: \(filter.displayName)"
        }

        func loadUserPreference(from string: String) -> FilterType? {
            let components = string.components(separatedBy: ": ")
            guard components.count == 2 else { return nil }
            return FilterType.allCases.first { $0.displayName == components[1] }
        }

        let originalFilter = FilterType.vintage
        let saved = saveUserPreference(filter: originalFilter)
        let loaded = loadUserPreference(from: saved)

        XCTAssertEqual(loaded, originalFilter)
    }

    func testFilterTypeInFilterSelection() {
        // Test realistic filter selection scenario
        struct FilterSelection {
            let availableFilters: [FilterType]
            var selectedFilter: FilterType

            init() {
                self.availableFilters = FilterType.allCases
                self.selectedFilter = .none
            }

            mutating func selectFilter(_ filter: FilterType) -> Bool {
                guard availableFilters.contains(filter) else { return false }
                selectedFilter = filter
                return true
            }
        }

        var selection = FilterSelection()
        XCTAssertEqual(selection.selectedFilter, .none)

        let success = selection.selectFilter(.vintage)
        XCTAssertTrue(success)
        XCTAssertEqual(selection.selectedFilter, .vintage)

        // Test with a hypothetical invalid filter (if we had one)
        // This test ensures the enum is properly constrained
        XCTAssertTrue(FilterType.allCases.contains(selection.selectedFilter))
    }

    // MARK: - Memory Tests

    func testFilterTypeMemoryUsage() {
        // Test that FilterType instances don't use excessive memory
        let (filters, memoryUsed) = TestHelpers.measureMemoryUsage {
            return (0..<10000).map { i in
                FilterType.allCases[i % FilterType.allCases.count]
            }
        }

        XCTAssertEqual(filters.count, 10000)
        // Enums should use minimal memory
        XCTAssertLessThan(memoryUsed, 1024 * 1024) // Less than 1MB for 10000 enum values
    }

    // MARK: - Edge Cases

    func testFilterTypeWithEmptyRawValue() {
        // Test that we can't create FilterType with empty raw value
        let emptyFilter = FilterType(rawValue: "")
        XCTAssertNil(emptyFilter)
    }

    func testFilterTypeWithWhitespaceRawValue() {
        // Test that we can't create FilterType with whitespace
        let whitespaceFilter = FilterType(rawValue: " ")
        XCTAssertNil(whitespaceFilter)
    }

    func testFilterTypeCaseSensitivity() {
        // Test that FilterType raw values are case sensitive
        let lowercaseFilter = FilterType(rawValue: "none")
        let uppercaseFilter = FilterType(rawValue: "NONE")

        XCTAssertNil(lowercaseFilter)
        XCTAssertNil(uppercaseFilter)
        XCTAssertNotNil(FilterType(rawValue: "None")) // Correct case
    }
}