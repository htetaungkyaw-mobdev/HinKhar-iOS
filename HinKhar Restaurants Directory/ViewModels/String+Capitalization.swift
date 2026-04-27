// String+Capitalization.swift
// Shared utilities for String capitalization

import Foundation

public extension String {
    /// Returns a copy of the string with only the first character uppercased.
    /// If the string is empty, returns the original string.
    var capitalizedFirstLetter: String {
        guard let first = self.first else { return self }
        return String(first).uppercased() + self.dropFirst()
    }

    /// Returns a new string with the first character uppercased.
    /// Provided as a method variant mirroring the original helper.
    func capitalizingFirstLetter() -> String {
        return self.capitalizedFirstLetter
    }
}
