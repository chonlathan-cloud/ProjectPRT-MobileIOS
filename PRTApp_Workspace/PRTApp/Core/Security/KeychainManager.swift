//
//  KeychainManager.swift
//  PRTApp_Workspace
//

import Foundation
import Security

protocol KeychainServiceProtocol: Sendable {
    func saveToken(_ token: String) throws
    func getToken() -> String?
    func deleteToken()
}

enum KeychainError: LocalizedError, Sendable {
    case invalidTokenData
    case unexpectedTokenData
    case saveFailed(status: OSStatus)
    case updateFailed(status: OSStatus)
    case readFailed(status: OSStatus)
    case deleteFailed(status: OSStatus)

    var errorDescription: String? {
        switch self {
        case .invalidTokenData:
            return "Unable to encode token for secure storage."
        case .unexpectedTokenData:
            return "Keychain returned token data in an unexpected format."
        case .saveFailed(let status):
            return "Unable to save token to Keychain: \(Self.statusMessage(for: status))."
        case .updateFailed(let status):
            return "Unable to update token in Keychain: \(Self.statusMessage(for: status))."
        case .readFailed(let status):
            return "Unable to read token from Keychain: \(Self.statusMessage(for: status))."
        case .deleteFailed(let status):
            return "Unable to delete token from Keychain: \(Self.statusMessage(for: status))."
        }
    }

    private static func statusMessage(for status: OSStatus) -> String {
        SecCopyErrorMessageString(status, nil) as String? ?? "OSStatus \(status)"
    }
}

final class KeychainManager: KeychainServiceProtocol, @unchecked Sendable {
    static let shared = KeychainManager()

    private let service: String
    private let account = "jwtToken"

    private init(service: String = Bundle.main.bundleIdentifier ?? "com.projectprt.token") {
        self.service = service
    }

    func saveToken(_ token: String) throws {
        guard let tokenData = token.data(using: .utf8) else {
            throw KeychainError.invalidTokenData
        }

        let attributes: [String: Any] = [
            kSecValueData as String: tokenData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let addStatus = SecItemAdd(makeTokenQuery(additionalItems: attributes) as CFDictionary, nil)

        switch addStatus {
        case errSecSuccess:
            return
        case errSecDuplicateItem:
            let updateStatus = SecItemUpdate(
                makeTokenQuery() as CFDictionary,
                attributes as CFDictionary
            )

            guard updateStatus == errSecSuccess else {
                throw KeychainError.updateFailed(status: updateStatus)
            }
        default:
            throw KeychainError.saveFailed(status: addStatus)
        }
    }

    func getToken() -> String? {
        var item: CFTypeRef?
        let readStatus = SecItemCopyMatching(makeTokenQuery(additionalItems: [
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]) as CFDictionary, &item)

        switch readStatus {
        case errSecSuccess:
            guard let tokenData = item as? Data,
                  let token = String(data: tokenData, encoding: .utf8) else {
                assertionFailure(KeychainError.unexpectedTokenData.localizedDescription)
                return nil
            }

            return token
        case errSecItemNotFound:
            return nil
        default:
            assertionFailure(KeychainError.readFailed(status: readStatus).localizedDescription)
            return nil
        }
    }

    func deleteToken() {
        let deleteStatus = SecItemDelete(makeTokenQuery() as CFDictionary)

        guard deleteStatus == errSecSuccess || deleteStatus == errSecItemNotFound else {
            assertionFailure(KeychainError.deleteFailed(status: deleteStatus).localizedDescription)
            return
        }
    }

    private func makeTokenQuery(additionalItems: [String: Any] = [:]) -> [String: Any] {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        additionalItems.forEach { key, value in
            query[key] = value
        }

        return query
    }
}
