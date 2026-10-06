//
//  ShareViewController.swift
//  RoomCheckShare
//
//  Created by John Re on 6/10/2026.
//

import UIKit
import UniformTypeIdentifiers

class ShareViewController: UIViewController {
    private let suite = "group.JohnReUTS.RoomCheck"

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let item = extensionContext?.inputItems.first as? NSExtensionItem,
              let provider = item.attachments?.first else {
            extensionContext?.cancelRequest(withError: CocoaError(.fileNoSuchFile))
            return
        }
        let type = UTType.image.identifier
        guard provider.hasItemConformingToTypeIdentifier(type) else {
            extensionContext?.cancelRequest(withError: CocoaError(.fileReadUnsupportedScheme))
            return
        }
        provider.loadFileRepresentation(forTypeIdentifier: type) { url, _ in
            guard let url else {
                DispatchQueue.main.async {
                    self.extensionContext?.cancelRequest(withError: CocoaError(.fileReadUnknown))
                }
                return
            }
            self.store(url)
        }
    }

    private func store(_ url: URL) {
        let container = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: suite
        )
        let destination = container?.appendingPathComponent(url.lastPathComponent)
        if let destination {
            try? FileManager.default.removeItem(at: destination)
            try? FileManager.default.copyItem(at: url, to: destination)
            UserDefaults(suiteName: suite)?.set(destination.path, forKey: "sharedPhotoPath")
        }
        DispatchQueue.main.async {
            self.extensionContext?.completeRequest(returningItems: nil)
        }
    }
}
