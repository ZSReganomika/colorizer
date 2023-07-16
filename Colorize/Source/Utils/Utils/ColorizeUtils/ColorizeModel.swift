import CoreML

/// Class for model loading and prediction
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
class ColorizeModel {
    let model: MLModel

    init(model: MLModel) {
        self.model = model
    }

    func prediction(input: ColorizeModelInput) throws -> ColorizeModelOutput {
        return try self.prediction(input: input, options: MLPredictionOptions())
    }

    /**
        Make a prediction using the structured interface

        - parameters:
           - input: the input to the prediction as coremlColorizerInput
           - options: prediction options

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as coremlColorizerOutput
    */
    func prediction(
        input: ColorizeModelInput,
        options: MLPredictionOptions
    ) throws -> ColorizeModelOutput {
        let outFeatures = try model.prediction(from: input, options: options)
        return ColorizeModelOutput(features: outFeatures)
    }

    /**
        Make a prediction using the convenience interface

        - parameters:
            - input1 as 1 × 1 × 256 × 256 4-dimensional array of floats

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as coremlColorizerOutput
    */
    func prediction(input1: MLMultiArray) throws -> ColorizeModelOutput {
        let inputModel = ColorizeModelInput(input1: input1)
        return try self.prediction(input: inputModel)
    }

    /**
        Make a prediction using the convenience interface

        - parameters:
            - input1 as 1 × 1 × 256 × 256 4-dimensional array of floats

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as coremlColorizerOutput
    */

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    func prediction(input1: MLShapedArray<Float>) throws -> ColorizeModelOutput {
        let inputModel = ColorizeModelInput(input1: input1)
        return try self.prediction(input: inputModel)
    }

    /**
        Make a batch prediction using the structured interface

        - parameters:
           - inputs: the inputs to the prediction as [coremlColorizerInput]
           - options: prediction options

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as [coremlColorizerOutput]
    */
    func predictions(
        inputs: [ColorizeModelInput],
        options: MLPredictionOptions = MLPredictionOptions()
    ) throws -> [ColorizeModelOutput] {
        let batchIn = MLArrayBatchProvider(array: inputs)
        let batchOut = try model.predictions(from: batchIn, options: options)
        var results: [ColorizeModelOutput] = []
        results.reserveCapacity(inputs.count)
        for index in 0..<batchOut.count {
            let outProvider = batchOut.features(at: index)
            let result =  ColorizeModelOutput(features: outProvider)
            results.append(result)
        }
        return results
    }
}
