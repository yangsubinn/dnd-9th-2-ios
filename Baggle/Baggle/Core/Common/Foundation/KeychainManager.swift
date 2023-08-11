//
//  KeychainManager.swift
//  Baggle
//
//  Created by 양수빈 on 2023/08/11.
//

import Foundation
import Security

class UserToken: Codable {
    var accessToken: String
    var refreshToken: String
    
    init(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
}

class KeychainManager {
    static let shared = KeychainManager()
    
    private init() {}
    
    private let account = "Baggle"
    private let service = Bundle.main.bundleIdentifier
    
    private lazy var query: [CFString: Any]? = {
        guard let service = self.service else { return nil }
        return [kSecClass: kSecClassGenericPassword,
          kSecAttrService: service,
          kSecAttrAccount: account]
    }()
    
    func createUserToken(_ user: UserToken) throws {
        guard let data = try? JSONEncoder().encode(user),
              let service = self.service else { return }
        let query: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
                                kSecAttrService: service,
                                kSecAttrAccount: account,
                                kSecAttrGeneric: data]
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw APIError.keychain(status: status)
        }
    }
    
    func readUserToken() -> UserToken? {
        guard let service = self.service else { return nil }
        let query: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
                                kSecAttrService: service,
                                kSecAttrAccount: account,
                                 kSecMatchLimit: kSecMatchLimitOne,
                           kSecReturnAttributes: true,
                                 kSecReturnData: true]
        var item: CFTypeRef?
        if SecItemCopyMatching(query as CFDictionary, &item) != errSecSuccess { return nil }
        
        guard let existingItem = item as? [String: Any],
              let data = existingItem[kSecAttrGeneric as String] as? Data,
              let user = try? JSONDecoder().decode(UserToken.self, from: data) else { return nil }
        
        return user
    }
    
    func updateUserToken(_ user: UserToken) throws {
        guard let query = self.query,
              let data = try? JSONEncoder().encode(user) else { return }
        let attributes: [CFString: Any] = [kSecAttrAccount: account,
                                           kSecAttrGeneric: data]
        let status =  SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw APIError.keychain(status: status)
        }
    }
    
    func deleteUserToken() throws {
        guard let query = self.query else { return }
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw APIError.keychain(status: status)
        }
    }
}
