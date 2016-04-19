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
let totalBytes = 4
let bitmap = calloc(totalBytes, sizeof(UInt8))
let colorSpace = CGColorSpaceCreateDeviceRGB()

let maxAlpha = CIFilter(name: "CIAreaMaximumAlpha")!
maxAlpha.setValue(ciImage, forKey:"inputImage")

var topPoint: CGFloat = 0.0
for topEdge in 0..<Int(ciImage.extent.size.height) {
    maxAlpha.setValue(CIVector(CGRect:CGRect(x: 0, y: topEdge, width: Int(ciImage.extent.width), height: 1)), forKey: kCIInputExtentKey)
    let maxAlphaImage = maxAlpha.outputImage!
    context.render(maxAlphaImage, toBitmap: bitmap, rowBytes: totalBytes, bounds: maxAlphaImage.extent, format: kCIFormatRGBA8, colorSpace: colorSpace)
    let rgba = UnsafeBufferPointer<UInt8>(
        start: UnsafePointer<UInt8>(bitmap),
        count: totalBytes)
    let alpha = Float(rgba[3]) / 255
    if alpha > 0 {
        topPoint = CGFloat(topEdge - 1)
        break
    }
}

