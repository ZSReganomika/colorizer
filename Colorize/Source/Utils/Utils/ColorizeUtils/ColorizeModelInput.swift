import CoreML

/// Model Prediction Input Type
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
class ColorizeModelInput: MLFeatureProvider {

    /// input1 as 1 × 1 × 256 × 256 4-dimensional array of floats
    var input1: MLMultiArray

    var featureNames: Set<String> {
        ["input1"]
    }

    func featureValue(for featureName: String) -> MLFeatureValue? {
        if featureName == "input1" {
            return MLFeatureValue(multiArray: input1)
        }
        return nil
    }

    init(input1: MLMultiArray) {
        self.input1 = input1
    }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    convenience init(input1: MLShapedArray<Float>) {
        self.init(input1: MLMultiArray(input1))
    }
}
