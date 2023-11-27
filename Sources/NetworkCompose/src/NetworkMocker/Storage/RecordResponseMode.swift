//
//  RecordResponseMode.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 26/11/23.
//

import Foundation

public enum RecordResponseMode {
    case disabled

    /// Enables recording responses for automation tests.
    ///
    /// When enabled, actual network responses are recorded for subsequent automation testing.
    case enabled
}
