//
//  Constants.swift
//  maintenance_wizard
//
//  Created by Aki Leinonen on 23.10.2025.
//

import Foundation

struct K {
    struct Firebase {
        static let companiesCollection = "companies"
        static let usersCollection = "users"
        static let machinesCollection = "machines"
        static let maintenanceEntriesCollection = "maintenance_entries"
        static let timeEntriesCollection = "time_entries"
        static let baseCategoriesCollection = "base_categories"
    }

    struct Storage {
        static let companiesPath = "companies"
        static let maintenancePath = "maintenance"
    }

    struct Defaults {
        static let maxImageSizeMB = 2.0
        static let lunchBreakHours = 0.5
    }
}
