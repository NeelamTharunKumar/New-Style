import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let channelName = "drape/native_ml"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: controller.binaryMessenger)

    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "isAvailable":
        result(true)
      case "analyzeGarmentImage":
        guard let args = call.arguments as? [String: Any],
              let imagePath = args["imagePath"] as? String else {
          result(FlutterError(code: "INVALID_ARGUMENT", message: "imagePath is required", details: nil))
          return
        }
        let localImageRef = args["localImageRef"] as? String ?? ""
        do {
          result(try Self.analyzeGarmentImage(imagePath: imagePath, localImageRef: localImageRef))
        } catch {
          result(FlutterError(code: "NATIVE_ANALYSIS_FAILED", message: error.localizedDescription, details: nil))
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private static func analyzeGarmentImage(imagePath: String, localImageRef: String) throws -> [String: Any] {
    guard let image = UIImage(contentsOfFile: imagePath), let cgImage = image.cgImage else {
      throw NSError(domain: "DrapeNativeML", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not decode image"])
    }

    let stats = dominantColorStats(cgImage: cgImage)
    let hex = rgbToHex(stats.r, stats.g, stats.b)
    return [
      "localImageRef": localImageRef,
      "hexColor": hex,
      "colorName": nameColor(stats.r, stats.g, stats.b),
      "patternHint": patternHint(stats.luminanceVariance),
      "brightness": stats.averageLuminance,
      "confidence": confidence(stats.sampleCount, stats.clusterShare, stats.luminanceVariance),
      "width": cgImage.width,
      "height": cgImage.height,
      "nativeEngine": "ios_swift_coregraphics",
      "privacy": "computed on-device; raw image not uploaded"
    ]
  }

  private static func dominantColorStats(cgImage: CGImage) -> ColorStats {
    let targetWidth = min(320, cgImage.width)
    let targetHeight = max(1, Int(Double(cgImage.height) * Double(targetWidth) / Double(cgImage.width)))
    let bytesPerPixel = 4
    let bytesPerRow = targetWidth * bytesPerPixel
    var rawData = [UInt8](repeating: 0, count: targetHeight * bytesPerRow)
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    guard let context = CGContext(
      data: &rawData,
      width: targetWidth,
      height: targetHeight,
      bitsPerComponent: 8,
      bytesPerRow: bytesPerRow,
      space: colorSpace,
      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else {
      return ColorStats(r: 128, g: 128, b: 128, sampleCount: 0, clusterShare: 0, averageLuminance: 128, luminanceVariance: 0)
    }
    context.draw(cgImage, in: CGRect(x: 0, y: 0, width: targetWidth, height: targetHeight))

    var buckets: [Int: Bucket] = [:]
    var luminanceValues: [Double] = []
    let step = max(1, Int(sqrt(Double(targetWidth * targetHeight) / 5000.0)))

    var y = 0
    while y < targetHeight {
      var x = 0
      while x < targetWidth {
        let index = y * bytesPerRow + x * bytesPerPixel
        let r = Int(rawData[index])
        let g = Int(rawData[index + 1])
        let b = Int(rawData[index + 2])
        let a = Int(rawData[index + 3])
        let lum = luminance(r, g, b)
        if a >= 180 && lum <= 244 && lum >= 8 {
          let rq = (r / 32) * 32
          let gq = (g / 32) * 32
          let bq = (b / 32) * 32
          let key = (rq << 16) + (gq << 8) + bq
          var bucket = buckets[key] ?? Bucket()
          bucket.count += 1
          bucket.r += r
          bucket.g += g
          bucket.b += b
          buckets[key] = bucket
          luminanceValues.append(lum)
        }
        x += step
      }
      y += step
    }

    guard let dominant = buckets.values.max(by: { $0.count < $1.count }) else {
      return ColorStats(r: 128, g: 128, b: 128, sampleCount: 0, clusterShare: 0, averageLuminance: 128, luminanceVariance: 0)
    }

    let total = max(1, buckets.values.reduce(0) { $0 + $1.count })
    let avgLum = luminanceValues.reduce(0, +) / Double(max(1, luminanceValues.count))
    let variance = luminanceValues.reduce(0) { $0 + pow($1 - avgLum, 2) } / Double(max(1, luminanceValues.count))
    return ColorStats(
      r: Int(Double(dominant.r) / Double(dominant.count)),
      g: Int(Double(dominant.g) / Double(dominant.count)),
      b: Int(Double(dominant.b) / Double(dominant.count)),
      sampleCount: total,
      clusterShare: Double(dominant.count) / Double(total),
      averageLuminance: avgLum,
      luminanceVariance: variance
    )
  }

  private static func patternHint(_ variance: Double) -> String {
    if variance > 3200 { return "patterned" }
    if variance > 1800 { return "subtle texture" }
    return "solid"
  }

  private static func confidence(_ sampleCount: Int, _ clusterShare: Double, _ variance: Double) -> Double {
    if sampleCount == 0 { return 0.1 }
    let sampleScore = min(1.0, Double(sampleCount) / 2500.0)
    let clusterScore = min(1.0, clusterShare * 2.2)
    let penalty = variance > 5000 ? 0.2 : 0.0
    return min(0.95, max(0.1, 0.35 + sampleScore * 0.35 + clusterScore * 0.3 - penalty))
  }

  private static func luminance(_ r: Int, _ g: Int, _ b: Int) -> Double {
    return 0.2126 * Double(r) + 0.7152 * Double(g) + 0.0722 * Double(b)
  }

  private static func rgbToHex(_ r: Int, _ g: Int, _ b: Int) -> String {
    return String(format: "#%02X%02X%02X", max(0, min(255, r)), max(0, min(255, g)), max(0, min(255, b)))
  }

  private static func nameColor(_ r: Int, _ g: Int, _ b: Int) -> String {
    let candidates: [String: (Int, Int, Int)] = [
      "black": (20, 20, 20), "white": (245, 245, 240), "cream": (238, 226, 198),
      "beige": (198, 173, 125), "brown": (115, 75, 45), "tan": (184, 132, 82),
      "grey": (128, 128, 128), "charcoal": (54, 61, 68), "navy blue": (24, 43, 88),
      "blue": (50, 105, 190), "light blue": (150, 190, 225), "green": (48, 130, 76),
      "olive": (104, 122, 52), "emerald green": (0, 135, 95), "yellow": (230, 200, 55),
      "mustard yellow": (205, 150, 35), "orange": (220, 115, 35), "red": (185, 45, 45),
      "maroon": (110, 30, 45), "pink": (220, 120, 160), "purple": (120, 75, 170),
      "gold": (210, 165, 55)
    ]
    return candidates.min { lhs, rhs in
      let ld = pow(Double(r - lhs.value.0), 2) + pow(Double(g - lhs.value.1), 2) + pow(Double(b - lhs.value.2), 2)
      let rd = pow(Double(r - rhs.value.0), 2) + pow(Double(g - rhs.value.1), 2) + pow(Double(b - rhs.value.2), 2)
      return ld < rd
    }?.key ?? "neutral"
  }

  private struct Bucket { var count = 0; var r = 0; var g = 0; var b = 0 }
  private struct ColorStats {
    let r: Int
    let g: Int
    let b: Int
    let sampleCount: Int
    let clusterShare: Double
    let averageLuminance: Double
    let luminanceVariance: Double
  }
}
