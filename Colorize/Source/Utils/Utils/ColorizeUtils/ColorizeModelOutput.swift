import CoreML

/// Model Prediction Output Type
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
class ColorizeModelOutput: MLFeatureProvider {

    /// Source provided by CoreML
    private let provider: MLFeatureProvider

    /// 796 as multidimensional array of floats
    var output: MLMultiArray {
        return self.provider.featureValue(for: "796")!.multiArrayValue!
    }

    /// 796 as multidimensional array of floats
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    var outputShapedArray: MLShapedArray<Float> {
        return MLShapedArray<Float>(self.output)
    }

    var featureNames: Set<String> {
        return self.provider.featureNames
    }

    func featureValue(for featureName: String) -> MLFeatureValue? {
        return self.provider.featureValue(for: featureName)
    }

    init(output: MLMultiArray) {
        // swiftlint:disable:next force_try
        self.provider = try! MLDictionaryFeatureProvider(
            dictionary: [
                "796": MLFeatureValue(multiArray: output)
            ]
        )
    }

    init(features: MLFeatureProvider) {
        self.provider = features
    }
}
