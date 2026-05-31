package com.bharatfit.ai

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlin.math.max
import kotlin.math.min
import kotlin.math.pow
import kotlin.math.sqrt

class MainActivity : FlutterActivity() {
    private val channelName = "bharatfit/native_ml"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "isAvailable" -> result.success(true)
                "analyzeGarmentImage" -> {
                    val imagePath = call.argument<String>("imagePath")
                    val localImageRef = call.argument<String>("localImageRef") ?: ""
                    if (imagePath.isNullOrBlank()) {
                        result.error("INVALID_ARGUMENT", "imagePath is required", null)
                        return@setMethodCallHandler
                    }
                    try {
                        result.success(analyzeGarmentImage(imagePath, localImageRef))
                    } catch (error: Throwable) {
                        result.error("NATIVE_ANALYSIS_FAILED", error.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun analyzeGarmentImage(imagePath: String, localImageRef: String): Map<String, Any> {
        val options = BitmapFactory.Options().apply { inSampleSize = 2 }
        val bitmap = BitmapFactory.decodeFile(imagePath, options)
            ?: throw IllegalStateException("Could not decode image")
        val scaled = if (bitmap.width > 320) {
            val ratio = 320.0 / bitmap.width.toDouble()
            Bitmap.createScaledBitmap(bitmap, 320, max(1, (bitmap.height * ratio).toInt()), true)
        } else bitmap

        val stats = dominantColorStats(scaled)
        val hex = rgbToHex(stats.r, stats.g, stats.b)
        return mapOf(
            "localImageRef" to localImageRef,
            "hexColor" to hex,
            "colorName" to nameColor(stats.r, stats.g, stats.b),
            "patternHint" to patternHint(stats.luminanceVariance),
            "brightness" to stats.averageLuminance,
            "confidence" to confidence(stats.sampleCount, stats.clusterShare, stats.luminanceVariance),
            "width" to bitmap.width,
            "height" to bitmap.height,
            "nativeEngine" to "android_kotlin_bitmap",
            "privacy" to "computed on-device; raw image not uploaded"
        )
    }

    private fun dominantColorStats(bitmap: Bitmap): ColorStats {
        val buckets = mutableMapOf<Int, Bucket>()
        val luminanceValues = mutableListOf<Double>()
        val step = max(1, sqrt((bitmap.width * bitmap.height / 5000.0)).toInt())

        var y = 0
        while (y < bitmap.height) {
            var x = 0
            while (x < bitmap.width) {
                val color = bitmap.getPixel(x, y)
                val r = (color shr 16) and 0xFF
                val g = (color shr 8) and 0xFF
                val b = color and 0xFF
                val lum = luminance(r, g, b)
                if (lum <= 244.0 && lum >= 8.0) {
                    val rq = (r / 32) * 32
                    val gq = (g / 32) * 32
                    val bq = (b / 32) * 32
                    val key = (rq shl 16) + (gq shl 8) + bq
                    val bucket = buckets.getOrPut(key) { Bucket() }
                    bucket.count += 1
                    bucket.r += r
                    bucket.g += g
                    bucket.b += b
                    luminanceValues.add(lum)
                }
                x += step
            }
            y += step
        }

        if (buckets.isEmpty()) return ColorStats(128, 128, 128, 0, 0.0, 128.0, 0.0)
        val dominant = buckets.values.maxBy { it.count }
        val total = buckets.values.sumOf { it.count }
        val avgLum = luminanceValues.sum() / max(1, luminanceValues.size)
        val variance = luminanceValues.sumOf { (it - avgLum).pow(2.0) } / max(1, luminanceValues.size)
        return ColorStats(
            (dominant.r / dominant.count.toDouble()).toInt(),
            (dominant.g / dominant.count.toDouble()).toInt(),
            (dominant.b / dominant.count.toDouble()).toInt(),
            total,
            dominant.count / max(1, total).toDouble(),
            avgLum,
            variance
        )
    }

    private fun patternHint(variance: Double): String = when {
        variance > 3200.0 -> "patterned"
        variance > 1800.0 -> "subtle texture"
        else -> "solid"
    }

    private fun confidence(sampleCount: Int, clusterShare: Double, variance: Double): Double {
        if (sampleCount == 0) return 0.1
        val sampleScore = min(1.0, sampleCount / 2500.0)
        val clusterScore = min(1.0, clusterShare * 2.2)
        val penalty = if (variance > 5000.0) 0.2 else 0.0
        return (0.35 + sampleScore * 0.35 + clusterScore * 0.3 - penalty).coerceIn(0.1, 0.95)
    }

    private fun luminance(r: Int, g: Int, b: Int): Double = 0.2126 * r + 0.7152 * g + 0.0722 * b
    private fun rgbToHex(r: Int, g: Int, b: Int): String = "#%02X%02X%02X".format(r.coerceIn(0, 255), g.coerceIn(0, 255), b.coerceIn(0, 255))

    private fun nameColor(r: Int, g: Int, b: Int): String {
        val candidates = mapOf(
            "black" to intArrayOf(20, 20, 20),
            "white" to intArrayOf(245, 245, 240),
            "cream" to intArrayOf(238, 226, 198),
            "beige" to intArrayOf(198, 173, 125),
            "brown" to intArrayOf(115, 75, 45),
            "tan" to intArrayOf(184, 132, 82),
            "grey" to intArrayOf(128, 128, 128),
            "charcoal" to intArrayOf(54, 61, 68),
            "navy blue" to intArrayOf(24, 43, 88),
            "blue" to intArrayOf(50, 105, 190),
            "light blue" to intArrayOf(150, 190, 225),
            "green" to intArrayOf(48, 130, 76),
            "olive" to intArrayOf(104, 122, 52),
            "emerald green" to intArrayOf(0, 135, 95),
            "yellow" to intArrayOf(230, 200, 55),
            "mustard yellow" to intArrayOf(205, 150, 35),
            "orange" to intArrayOf(220, 115, 35),
            "red" to intArrayOf(185, 45, 45),
            "maroon" to intArrayOf(110, 30, 45),
            "pink" to intArrayOf(220, 120, 160),
            "purple" to intArrayOf(120, 75, 170),
            "gold" to intArrayOf(210, 165, 55)
        )
        return candidates.minBy { (_, c) ->
            (r - c[0]).toDouble().pow(2.0) + (g - c[1]).toDouble().pow(2.0) + (b - c[2]).toDouble().pow(2.0)
        }.key
    }

    data class Bucket(var count: Int = 0, var r: Int = 0, var g: Int = 0, var b: Int = 0)
    data class ColorStats(
        val r: Int,
        val g: Int,
        val b: Int,
        val sampleCount: Int,
        val clusterShare: Double,
        val averageLuminance: Double,
        val luminanceVariance: Double
    )
}
