// Resources/Constants.swift
import Foundation

enum API {
    static let baseURL = "http://localhost:5021"
    
    enum Endpoints {
        static let login         = "\(API.baseURL)/identity/Account/Login"
        static let register      = "\(API.baseURL)/game/GameAccount/Register"
        static let refreshToken      = "\(API.baseURL)/identity/Account/RefreshTokenData"
        static let logout      = "\(API.baseURL)/identity/Account/Logout"
        static let leaderboard = "\(API.baseURL)/game/Leaderboard/List"
        static let collection = "\(API.baseURL)/game/Collection/List"
        static let lobby = "\(API.baseURL)/game/Lobby/Get"
        static let satelliteDetails = "\(API.baseURL)/game/Satellite/Details"
        static let satelliteUnlock  = "\(API.baseURL)/game/Satellite/Unlock"
        static let progress = "\(API.baseURL)/game/Progress/Overview"
        static let sessionSubmit = "\(API.baseURL)/game/Session/Submit"
        static let sessionSync = "\(API.baseURL)/game/Session/Sync"
    }
}

import SwiftUI

enum AppColors {
}
