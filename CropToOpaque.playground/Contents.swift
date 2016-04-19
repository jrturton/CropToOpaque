//: Playground - noun: a place where people can play

import UIKit

let emoji = "💩"
let attributes = [NSFontAttributeName: UIFont.systemFontOfSize(100)]

let boundingSize = emoji.sizeWithAttributes(attributes)

UIGraphicsBeginImageContextWithOptions(boundingSize, false, 0)
emoji.drawAtPoint(.zero, withAttributes: attributes)
let image = UIGraphicsGetImageFromCurrentImageContext()
UIGraphicsEndImageContext()

let ciImage = CIImage(image: image)!

let context = CIContext()

let maxAlpha = CIFilter(name: "CIAreaMaximumAlpha")!
maxAlpha.setValue(ciImage, forKey:"inputImage")

let horizontalSlices = (0..<Int(ciImage.extent.size.height)).map {
    return CGRect(x: 0, y: $0, width: Int(ciImage.extent.width), height: 1)
}

let verticalSlices = (0..<Int(ciImage.extent.size.width)).map {
    return CGRect(x: $0, y: 0, width: 1, height: Int(ciImage.extent.height))
}

func alphaFromImage(image: CIImage, context: CIContext) -> Float {
    let totalBytes = 4
    let bitmap = calloc(totalBytes, sizeof(UInt8))
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    
    context.render(image, toBitmap: bitmap, rowBytes: totalBytes, bounds: CGRect(origin: .zero, size: CGSize(width:1, height: 1)), format: kCIFormatRGBA8, colorSpace: colorSpace)
    let rgba = UnsafeBufferPointer<UInt8>(
        start: UnsafePointer<UInt8>(bitmap),
        count: totalBytes)
    let alpha = Float(rgba[3]) / 255
    return alpha
}

func firstNonAlphaSliceInImage(image: CIImage, slices: [CGRect]) -> CGFloat {
    for (index, slice) in slices.enumerate() {
        maxAlpha.setValue(CIVector(CGRect:slice), forKey: kCIInputExtentKey)
        let maxAlphaImage = maxAlpha.outputImage!
        let alpha = alphaFromImage(maxAlphaImage, context: context)
        if alpha > 0 {
            return CGFloat(index)
        }
    }
    return 0
}

let topInset = firstNonAlphaSliceInImage(ciImage, slices: horizontalSlices)
let bottomInset = firstNonAlphaSliceInImage(ciImage, slices: horizontalSlices.reverse())
let leftInset = firstNonAlphaSliceInImage(ciImage, slices: verticalSlices)
let rightInset = firstNonAlphaSliceInImage(ciImage, slices: verticalSlices.reverse())

let cropInsets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
let croppedRect = UIEdgeInsetsInsetRect(ciImage.extent, cropInsets)

let cropFilter = CIFilter(name: "CICrop", withInputParameters: [kCIInputImageKey : ciImage, "inputRectangle" : CIVector(CGRect:croppedRect)])
let result = cropFilter?.outputImage!



