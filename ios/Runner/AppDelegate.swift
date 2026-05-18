import Flutter
import UIKit
import UserNotifications
import Vision

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let controller = window?.rootViewController as? FlutterViewController {
      let notificationPermissionChannel = FlutterMethodChannel(
        name: "tag/local_notification_permission",
        binaryMessenger: controller.binaryMessenger
      )

      notificationPermissionChannel.setMethodCallHandler { call, result in
        guard call.method == "requestPermission" else {
          result(FlutterMethodNotImplemented)
          return
        }

        UNUserNotificationCenter.current().requestAuthorization(
          options: [.alert, .badge, .sound]
        ) { granted, error in
          DispatchQueue.main.async {
            if error != nil {
              result("denied")
              return
            }

            result(granted ? "granted" : "denied")
          }
        }
      }

      let deviceStorageChannel = FlutterMethodChannel(
        name: "tag/device_storage",
        binaryMessenger: controller.binaryMessenger
      )

      deviceStorageChannel.setMethodCallHandler { call, result in
        guard call.method == "getStorageInfo" else {
          result(FlutterMethodNotImplemented)
          return
        }

        do {
          let homeURL = URL(fileURLWithPath: NSHomeDirectory())
          let values = try homeURL.resourceValues(forKeys: [
            .volumeAvailableCapacityForImportantUsageKey,
            .volumeAvailableCapacityKey,
            .volumeTotalCapacityKey,
          ])

          let availableBytes =
            values.volumeAvailableCapacityForImportantUsage
            ?? Int64(values.volumeAvailableCapacity ?? 0)
          let totalBytes = Int64(values.volumeTotalCapacity ?? 0)

          result([
            "availableBytes": availableBytes,
            "totalBytes": totalBytes,
          ])
        } catch {
          result(FlutterError(
            code: "storage_unavailable",
            message: "Unable to read device storage capacity.",
            details: error.localizedDescription
          ))
        }
      }

      let textRecognitionChannel = FlutterMethodChannel(
        name: "tag/local_text_recognition",
        binaryMessenger: controller.binaryMessenger
      )

      textRecognitionChannel.setMethodCallHandler { call, result in
        guard call.method == "recognizeTextFromImage" else {
          result(FlutterMethodNotImplemented)
          return
        }

        guard
          let arguments = call.arguments as? [String: Any],
          let imagePath = arguments["imagePath"] as? String
        else {
          result(FlutterError(
            code: "invalid_arguments",
            message: "recognizeTextFromImage requires an imagePath.",
            details: nil
          ))
          return
        }

        Self.recognizeText(imagePath: imagePath, result: result)
      }

      let shareIntakeChannel = FlutterMethodChannel(
        name: "tag/share_intake",
        binaryMessenger: controller.binaryMessenger
      )

      shareIntakeChannel.setMethodCallHandler { call, result in
        switch call.method {
        case "getPendingSharedSources":
          do {
            result(try Self.pendingSharedSources())
          } catch {
            result(FlutterError(
              code: "share_intake_unavailable",
              message: "Unable to read pending shared sources.",
              details: error.localizedDescription
            ))
          }
        case "markPendingSharedSourceImported":
          guard
            let arguments = call.arguments as? [String: Any],
            let id = arguments["id"] as? String
          else {
            result(FlutterError(
              code: "invalid_arguments",
              message: "markPendingSharedSourceImported requires an id.",
              details: nil
            ))
            return
          }

          do {
            try Self.removePendingSharedSource(id: id)
            result(nil)
          } catch {
            result(FlutterError(
              code: "share_intake_cleanup_failed",
              message: "Unable to clear imported shared source.",
              details: error.localizedDescription
            ))
          }
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private static func recognizeText(imagePath: String, result: @escaping FlutterResult) {
    let trimmedPath = imagePath.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmedPath.isEmpty else {
      result([
        "text": "",
        "lines": [],
        "confidence": 0.0,
      ])
      return
    }

    guard FileManager.default.fileExists(atPath: trimmedPath) else {
      result(FlutterError(
        code: "image_missing",
        message: "Image file is missing.",
        details: trimmedPath
      ))
      return
    }

    let request = VNRecognizeTextRequest { request, error in
      if let error {
        DispatchQueue.main.async {
          result(FlutterError(
            code: "ocr_failed",
            message: "Local text recognition failed.",
            details: error.localizedDescription
          ))
        }
        return
      }

      let observations = (request.results as? [VNRecognizedTextObservation] ?? [])
        .sorted { lhs, rhs in
          let yDelta = abs(lhs.boundingBox.midY - rhs.boundingBox.midY)
          if yDelta > 0.02 {
            return lhs.boundingBox.midY > rhs.boundingBox.midY
          }

          return lhs.boundingBox.minX < rhs.boundingBox.minX
        }
      var lines: [String] = []
      var confidenceTotal: Float = 0
      var confidenceCount: Float = 0

      for observation in observations {
        guard let candidate = observation.topCandidates(1).first else {
          continue
        }

        let line = candidate.string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !line.isEmpty else {
          continue
        }

        lines.append(line)
        confidenceTotal += candidate.confidence
        confidenceCount += 1
      }

      let confidence = confidenceCount == 0 ? 0.0 : Double(confidenceTotal / confidenceCount)
      DispatchQueue.main.async {
        result([
          "text": lines.joined(separator: "\n"),
          "lines": lines,
          "confidence": confidence,
        ])
      }
    }

    request.recognitionLevel = .accurate
    request.usesLanguageCorrection = true

    let handler = VNImageRequestHandler(
      url: URL(fileURLWithPath: trimmedPath),
      options: [:]
    )

    DispatchQueue.global(qos: .userInitiated).async {
      do {
        try handler.perform([request])
      } catch {
        DispatchQueue.main.async {
          result(FlutterError(
            code: "ocr_failed",
            message: "Local text recognition failed.",
            details: error.localizedDescription
          ))
        }
      }
    }
  }

  private static let appGroupIdentifier = "group.com.festusowumi.usetag"
  private static let shareManifestFileName = "pending_shares.json"

  private static func pendingSharedSources() throws -> [[String: Any]] {
    guard let manifestURL = shareManifestURL(),
      FileManager.default.fileExists(atPath: manifestURL.path)
    else {
      return []
    }

    let manifest = try loadShareManifest(from: manifestURL)
    let items = manifest["items"] as? [[String: Any]] ?? []

    return items.compactMap { item in
      guard (item["imported"] as? Bool) != true else {
        return nil
      }

      return [
        "id": item["id"] as? String ?? "",
        "type": item["type"] as? String ?? "text",
        "file_path": item["file_path"] as? String ?? "",
        "text": item["text"] as? String ?? "",
        "url": item["url"] as? String ?? "",
        "suggested_name": item["suggested_name"] as? String ?? "",
        "source_application": item["source_application"] as? String ?? "",
        "received_at": item["received_at"] as? Int64 ?? 0,
        "uti": item["uti"] as? String ?? "",
      ]
    }
  }

  private static func removePendingSharedSource(id: String) throws {
    guard let manifestURL = shareManifestURL() else {
      throw ShareIntakeError.appGroupUnavailable
    }

    guard FileManager.default.fileExists(atPath: manifestURL.path) else {
      return
    }

    var manifest = try loadShareManifest(from: manifestURL)
    let items = manifest["items"] as? [[String: Any]] ?? []
    manifest["items"] = items.filter { item in
      (item["id"] as? String) != id
    }

    let data = try JSONSerialization.data(withJSONObject: manifest, options: [.prettyPrinted])
    try data.write(to: manifestURL, options: .atomic)

    if let groupURL = appGroupURL() {
      let pendingDirectory = groupURL
        .appendingPathComponent("pending_shares", isDirectory: true)
        .appendingPathComponent(id, isDirectory: true)
      if FileManager.default.fileExists(atPath: pendingDirectory.path) {
        try FileManager.default.removeItem(at: pendingDirectory)
      }
    }
  }

  private static func appGroupURL() -> URL? {
    FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)
  }

  private static func shareManifestURL() -> URL? {
    appGroupURL()?.appendingPathComponent(shareManifestFileName)
  }

  private static func loadShareManifest(from url: URL) throws -> [String: Any] {
    let data = try Data(contentsOf: url)
    return (try JSONSerialization.jsonObject(with: data)) as? [String: Any]
      ?? ["version": 1, "items": []]
  }
}

private enum ShareIntakeError: Error {
  case appGroupUnavailable
}
