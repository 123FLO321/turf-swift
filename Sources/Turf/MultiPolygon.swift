import Foundation

/**
 A `MultiLineString` geometry. The coordinates property represents a `[LineString]`.
 */
public struct MultiPolygon: Codable, Equatable {
    var type: String = GeometryType.MultiPolygon.rawValue
    public var coordinates: [[[CLLocationCoordinate2D]]]
    
    public init(_ coordinates: [[[CLLocationCoordinate2D]]]) {
        self.coordinates = coordinates
    }
    
    public init(_ polygons: [Polygon]) {
        self.coordinates = [[[CLLocationCoordinate2D]]]()
        for polygon in polygons {
            self.coordinates.append(polygon.coordinates)
        }
    }
}

public struct MultiPolygonFeature: GeoJSONObject {
    public var type: FeatureType = .feature
    public var identifier: FeatureIdentifier?
    public var geometry: MultiPolygon
    public var properties: [String : AnyJSONType]?
    
    public init(_ geometry: MultiPolygon) {
        self.geometry = geometry
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: GeoJSONCodingKeys.self)
        geometry = try container.decode(MultiPolygon.self, forKey: .geometry)
        properties = try container.decode([String: AnyJSONType]?.self, forKey: .properties)
        identifier = try container.decodeIfPresent(FeatureIdentifier.self, forKey: .identifier)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: GeoJSONCodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(geometry, forKey: .geometry)
        try container.encode(properties, forKey: .properties)
        try container.encodeIfPresent(identifier, forKey: .identifier)
    }
}

extension MultiPolygon {
    
    public var polygons: [Polygon] {
        var polygons = [Polygon]()
        for polygonCoordinates in coordinates {
            polygons.append(Polygon(polygonCoordinates))
        }
        return polygons
    }
    
    public func contains(_ coordinate: CLLocationCoordinate2D, ignoreBoundary: Bool = false) -> Bool {
        
        for polygon in polygons {
            if polygon.contains(coordinate, ignoreBoundary: ignoreBoundary) {
                return true
            }
        }
        return false
    }
    
}
