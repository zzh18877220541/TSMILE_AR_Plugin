//
//  ARViewModel.swift
//  TSMILE_AR_Plugin
//
//  Created by 周子皓 on 2024/11/17.
//

import Foundation
import SceneKit
import Combine
import UIKit
import ARKit

class ARViewModel: ObservableObject {
    @Published var modelNode_plane: SCNNode?
    @Published var modelNode_video: SCNNode?
}
