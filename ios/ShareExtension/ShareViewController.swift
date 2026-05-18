import UIKit
import UniformTypeIdentifiers

final class ShareViewController: UIViewController {
  private static let appGroupIdentifier = "group.com.festusowumi.usetag"
  private static let manifestFileName = "pending_shares.json"

  private let titleLabel = UILabel()
  private let detailLabel = UILabel()

  override func viewDidLoad() {
    super.viewDidLoad()
    configureView()
    saveFirstSupportedAttachment()
  }

  private func configureView() {
    view.backgroundColor = UIColor(red: 0.973, green: 0.969, blue: 0.949, alpha: 1)

    let cardView = UIView()
    cardView.translatesAutoresizingMaskIntoConstraints = false
    cardView.backgroundColor = .white
    cardView.layer.cornerRadius = 20
    cardView.layer.borderWidth = 1
    cardView.layer.borderColor = UIColor(red: 0.906, green: 0.886, blue: 0.855, alpha: 1).cgColor

    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.text = "Saved to Tag"
    titleLabel.textColor = UIColor(red: 0.09, green: 0.10, blue: 0.12, alpha: 1)
    titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
    titleLabel.textAlignment = .center

    detailLabel.translatesAutoresizingMaskIntoConstraints = false
    detailLabel.text = "I will turn it into a card if it needs action."
    detailLabel.textColor = UIColor(red: 0.37, green: 0.40, blue: 0.45, alpha: 1)
    detailLabel.font = .systemFont(ofSize: 15, weight: .regular)
    detailLabel.textAlignment = .center
    detailLabel.numberOfLines = 0

    view.addSubview(cardView)
    cardView.addSubview(titleLabel)
    cardView.addSubview(detailLabel)

    NSLayoutConstraint.activate([
      cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      cardView.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, constant: -48),
      cardView.widthAnchor.constraint(greaterThanOrEqualToConstant: 280),

      titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 24),
      titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
      titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),

      detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
      detailLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
      detailLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
      detailLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -24),
    ])
  }

  private func saveFirstSupportedAttachment() {
    let providers = extensionContext?
      .inputItems
      .compactMap { $0 as? NSExtensionItem }
      .flatMap { $0.attachments ?? [] } ?? []

    saveNextProvider(from: providers, at: 0) { [weak self] didSave in
      DispatchQueue.main.async {
        if didSave {
          self?.completeAfterConfirmation()
        } else {
          self?.showFailure()
        }
      }
    }
  }

  private func saveNextProvider(
    from providers: [NSItemProvider],
    at index: Int,
    completion: @escaping (Bool) -> Void
  ) {
    guard index < providers.count else {
      completion(false)
      return
    }

    let provider = providers[index]
    if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
      saveImage(provider: provider) { didSave in
        didSave ? completion(true) : self.saveNextProvider(from: providers, at: index + 1, completion: completion)
      }
      return
    }

    if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
      saveURL(provider: provider) { didSave in
        didSave ? completion(true) : self.saveNextProvider(from: providers, at: index + 1, completion: completion)
      }
      return
    }

    if provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
      saveText(provider: provider) { didSave in
        didSave ? completion(true) : self.saveNextProvider(from: providers, at: index + 1, completion: completion)
      }
      return
    }

    saveNextProvider(from: providers, at: index + 1, completion: completion)
  }

  private func saveImage(provider: NSItemProvider, completion: @escaping (Bool) -> Void) {
    provider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { [weak self] url, _ in
      guard let self, let url else {
        self?.saveImageItem(provider: provider, completion: completion)
        return
      }

      do {
        let id = self.makePayloadId()
        let copiedURL = try self.copySharedFile(
          sourceURL: url,
          payloadId: id,
          suggestedName: provider.suggestedName,
          fallbackExtension: "png"
        )
        try self.appendPendingPayload([
          "id": id,
          "type": "image",
          "file_path": copiedURL.path,
          "suggested_name": provider.suggestedName ?? copiedURL.lastPathComponent,
          "received_at": self.nowMilliseconds(),
          "source_application": "",
          "uti": UTType.image.identifier,
        ])
        completion(true)
      } catch {
        completion(false)
      }
    }
  }

  private func saveImageItem(provider: NSItemProvider, completion: @escaping (Bool) -> Void) {
    provider.loadItem(forTypeIdentifier: UTType.image.identifier, options: nil) { [weak self] item, _ in
      guard let self else {
        completion(false)
        return
      }

      do {
        let id = self.makePayloadId()
        let payloadDirectory = try self.pendingDirectory(for: id)
        let fileURL = payloadDirectory.appendingPathComponent(self.safeFileName(provider.suggestedName, fallbackExtension: "png"))

        if let data = item as? Data {
          try data.write(to: fileURL, options: .atomic)
        } else if let image = item as? UIImage, let data = image.pngData() {
          try data.write(to: fileURL, options: .atomic)
        } else if let url = item as? URL {
          let copiedURL = try self.copySharedFile(
            sourceURL: url,
            payloadId: id,
            suggestedName: provider.suggestedName,
            fallbackExtension: "png"
          )
          try self.appendPendingPayload([
            "id": id,
            "type": "image",
            "file_path": copiedURL.path,
            "suggested_name": provider.suggestedName ?? copiedURL.lastPathComponent,
            "received_at": self.nowMilliseconds(),
            "source_application": "",
            "uti": UTType.image.identifier,
          ])
          completion(true)
          return
        } else {
          completion(false)
          return
        }

        try self.appendPendingPayload([
          "id": id,
          "type": "image",
          "file_path": fileURL.path,
          "suggested_name": provider.suggestedName ?? fileURL.lastPathComponent,
          "received_at": self.nowMilliseconds(),
          "source_application": "",
          "uti": UTType.image.identifier,
        ])
        completion(true)
      } catch {
        completion(false)
      }
    }
  }

  private func saveText(provider: NSItemProvider, completion: @escaping (Bool) -> Void) {
    provider.loadItem(forTypeIdentifier: UTType.plainText.identifier, options: nil) { [weak self] item, _ in
      guard let self else {
        completion(false)
        return
      }

      let text = (item as? String) ?? (item as? URL)?.absoluteString
      guard let text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
        completion(false)
        return
      }

      do {
        try self.appendPendingPayload([
          "id": self.makePayloadId(),
          "type": "text",
          "text": text,
          "suggested_name": provider.suggestedName ?? "",
          "received_at": self.nowMilliseconds(),
          "source_application": "",
          "uti": UTType.plainText.identifier,
        ])
        completion(true)
      } catch {
        completion(false)
      }
    }
  }

  private func saveURL(provider: NSItemProvider, completion: @escaping (Bool) -> Void) {
    provider.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { [weak self] item, _ in
      guard let self else {
        completion(false)
        return
      }

      let urlString = (item as? URL)?.absoluteString ?? item as? String
      guard let urlString, !urlString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
        completion(false)
        return
      }

      do {
        try self.appendPendingPayload([
          "id": self.makePayloadId(),
          "type": "url",
          "url": urlString,
          "suggested_name": provider.suggestedName ?? "",
          "received_at": self.nowMilliseconds(),
          "source_application": "",
          "uti": UTType.url.identifier,
        ])
        completion(true)
      } catch {
        completion(false)
      }
    }
  }

  private func completeAfterConfirmation() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { [weak self] in
      self?.extensionContext?.completeRequest(returningItems: nil)
    }
  }

  private func showFailure() {
    titleLabel.text = "Could not save"
    detailLabel.text = "Open Tag and try importing it manually."
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
      self?.extensionContext?.cancelRequest(withError: ShareExtensionError.saveFailed)
    }
  }

  private func appendPendingPayload(_ payload: [String: Any]) throws {
    guard let manifestURL = Self.manifestURL() else {
      throw ShareExtensionError.appGroupUnavailable
    }

    try FileManager.default.createDirectory(
      at: manifestURL.deletingLastPathComponent(),
      withIntermediateDirectories: true
    )

    var manifest = try Self.loadManifest(from: manifestURL)
    var items = manifest["items"] as? [[String: Any]] ?? []
    items.append(payload)
    manifest["version"] = 1
    manifest["items"] = items

    let data = try JSONSerialization.data(withJSONObject: manifest, options: [.prettyPrinted])
    try data.write(to: manifestURL, options: .atomic)
  }

  private func copySharedFile(
    sourceURL: URL,
    payloadId: String,
    suggestedName: String?,
    fallbackExtension: String
  ) throws -> URL {
    let directory = try pendingDirectory(for: payloadId)
    let destinationURL = directory.appendingPathComponent(
      safeFileName(suggestedName ?? sourceURL.lastPathComponent, fallbackExtension: fallbackExtension)
    )

    if FileManager.default.fileExists(atPath: destinationURL.path) {
      try FileManager.default.removeItem(at: destinationURL)
    }

    try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
    return destinationURL
  }

  private func pendingDirectory(for payloadId: String) throws -> URL {
    guard let rootURL = Self.appGroupURL() else {
      throw ShareExtensionError.appGroupUnavailable
    }

    let directory = rootURL
      .appendingPathComponent("pending_shares", isDirectory: true)
      .appendingPathComponent(payloadId, isDirectory: true)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    return directory
  }

  private static func appGroupURL() -> URL? {
    FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)
  }

  private static func manifestURL() -> URL? {
    appGroupURL()?.appendingPathComponent(manifestFileName)
  }

  private static func loadManifest(from url: URL) throws -> [String: Any] {
    guard FileManager.default.fileExists(atPath: url.path) else {
      return ["version": 1, "items": []]
    }

    let data = try Data(contentsOf: url)
    return (try JSONSerialization.jsonObject(with: data)) as? [String: Any]
      ?? ["version": 1, "items": []]
  }

  private func makePayloadId() -> String {
    "share_\(UUID().uuidString.lowercased())"
  }

  private func nowMilliseconds() -> Int64 {
    Int64(Date().timeIntervalSince1970 * 1000)
  }

  private func safeFileName(_ value: String?, fallbackExtension: String) -> String {
    let fallback = "shared.\(fallbackExtension)"
    let candidate = (value ?? fallback)
      .components(separatedBy: CharacterSet(charactersIn: "/:\\"))
      .joined(separator: "_")
      .trimmingCharacters(in: .whitespacesAndNewlines)

    if candidate.isEmpty {
      return fallback
    }

    if candidate.contains(".") {
      return candidate
    }

    return "\(candidate).\(fallbackExtension)"
  }
}

private enum ShareExtensionError: Error {
  case appGroupUnavailable
  case saveFailed
}
