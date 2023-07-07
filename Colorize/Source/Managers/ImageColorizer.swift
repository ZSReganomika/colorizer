import UIKit
import CoreML
import Colorful

protocol ImageColorizerProtocol {
    func colorize(
        image: UIImage,
        completion: @escaping (Result<UIImage, Error>) -> Void
    )
}

final class ImageColorizer: ImageColorizerProtocol {

    var model: MLModel?

    func colorize(
        image: UIImage,
        completion: @escaping (Result<UIImage, Error>) -> Void
    ) {
        DispatchQueue.background.async {
            if let model = self.model {
                let result = self.colorize(
                    image: image,
                    model: model
                )
                completion(result)
            } else {
                self.configureModelAndColorize(
                    image: image,
                    completion: completion
                )
            }
        }
    }

    func configureModelAndColorize(
        image: UIImage,
        completion: (Result<UIImage, Error>) -> Void
    ) {
        do {
            if let filename = UserDefaults.standard.string(forKey: "ml_model_destination") {
                let fileManager = FileManager.default
                let appSupportDirectory = try fileManager.url(
                    for: .applicationSupportDirectory,
                    in: .userDomainMask,
                    appropriateFor: nil,
                    create: true
                )

                let permanentUrl = appSupportDirectory.appendingPathComponent(filename)

                let model = try MLModel(contentsOf: permanentUrl)
                self.model = model
                let result = self.colorize(
                    image: image,
                    model: model
                )
                completion(result)
            } else {
                fatalError("fail to get url")
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

// MARK: Private

private struct LAB {
    let l, a, b: [NSNumber]
}

private enum ColorizerError: Swift.Error {
    case preprocessFailure
    case postprocessFailure
}

extension ImageColorizer {

    struct Constants {
        static let inputDimension = 256
        static let inputSize = CGSize(
            width: inputDimension,
            height: inputDimension
        )
        static let coremlInputShape = [
            1,
            1,
            NSNumber(value: Constants.inputDimension),
            NSNumber(value: Constants.inputDimension)
        ]
    }

    private func colorize(
        image inputImage: UIImage,
        model: MLModel
    ) -> Result<UIImage, Error> {
        do {
            let inputImageLab = try preProcess(inputImage: inputImage)
            let input = try coloriserInput(from: inputImageLab)
            let output = try ColorizeModel(model: model).prediction(input: input)
            let outputImageLab = imageLab(from: output, inputImageLab: inputImageLab)
            let resultImage = try postProcess(outputLAB: outputImageLab, inputImage: inputImage)
            return .success(resultImage)
        } catch {
            return .failure(error)
        }
    }

    private func coloriserInput(from imageLab: LAB) throws -> ColorizeModelInput {
        let inputArray = try MLMultiArray(
            shape: Constants.coremlInputShape,
            dataType: MLMultiArrayDataType.float32
        )
        imageLab.l.enumerated().forEach({ (idx, value) in
            let inputIndex = [
                NSNumber(value: 0),
                NSNumber(value: 0),
                NSNumber(value: idx / Constants.inputDimension),
                NSNumber(value: idx % Constants.inputDimension)
            ]
            inputArray[inputIndex] = value
        })
        return ColorizeModelInput(input1: inputArray)
    }

    private func imageLab(from colorizerOutput: ColorizeModelOutput, inputImageLab: LAB) -> LAB {
        var a = [NSNumber]()
        var b = [NSNumber]()
        for idx in 0..<Constants.inputDimension * Constants.inputDimension {
            let aIdx = [
                NSNumber(value: 0),
                NSNumber(value: 0),
                NSNumber(value: idx / Constants.inputDimension),
                NSNumber(value: idx % Constants.inputDimension)
            ]
            let bIdx = [
                NSNumber(value: 0),
                NSNumber(value: 1),
                NSNumber(value: idx / Constants.inputDimension),
                NSNumber(value: idx % Constants.inputDimension)
            ]
            a.append(NSNumber(value: colorizerOutput._796[aIdx].doubleValue))
            b.append(NSNumber(value: colorizerOutput._796[bIdx].doubleValue))
        }
        return LAB(l: inputImageLab.l, a: a, b: b)
    }

    // Pre-process input: resize
    private func preProcess(inputImage: UIImage) throws -> LAB {
        guard let lab = inputImage.resizedImage(with: Constants.inputSize)?.toLab() else {
            throw ColorizerError.preprocessFailure
        }
        return LAB(
            l: lab[0],
            a: lab[1],
            b: lab[2]
        )
    }

    private func postProcess(
        outputLAB: LAB,
        inputImage: UIImage
    ) throws -> UIImage {
        guard let resultImageLab = UIImage.image(
            from: [
                outputLAB.l,
                outputLAB.a,
                outputLAB.b
            ],
            size: Constants.inputSize
        ).resizedImage(with: inputImage.size)?.toLab(),
              let originalImageLab = inputImage.resizedImage(with: inputImage.size)?.toLab() else {
            throw ColorizerError.postprocessFailure
        }
        return UIImage.image(
            from:
                [
                    originalImageLab[0],
                    resultImageLab[1],
                    resultImageLab[2]
                ],
            size: inputImage.size
        )
    }
}
