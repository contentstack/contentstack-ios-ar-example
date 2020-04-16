//
//  ViewController.swift
//  ContentstackAR
//
//  Created by Uttam Ukkoji on 14/06/18.
//  Copyright © 2018 Contentstack. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    var modelPath: URL?
    var modelScene : SCNScene?
    let session = ARSession()
    var sessionConfig: ARConfiguration  = ARWorldTrackingConfiguration()
    var startScale : CGFloat = 0
    var lastScale : CGFloat = 0.01
    var panDirection : String?
    var lastAngle: Float = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.setUp(viewController: self, session: session)
        addTapGestureToSceneView()
        configureLighting()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
        if let worldSessionConfig = sessionConfig as? ARWorldTrackingConfiguration {
            worldSessionConfig.planeDetection = .horizontal
            session.run(worldSessionConfig, options: [.resetTracking, .removeExistingAnchors])
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
   
    func configureLighting() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
    
    @objc func handlePanGesture(withGestureRecognizer recognizer: UIPanGestureRecognizer) {
        // get pan direction
        let velocity: CGPoint = recognizer.velocity(in: recognizer.view!)
        if self.panDirection == nil {
            self.panDirection = GameHelper.getPanDirection(velocity: velocity)
        }
        
        // if selected brick
        if let scenc = self.modelScene {
            
            if recognizer.state == .began{
                lastAngle = 0.0   // reset last angle
            }
            
            let translation = recognizer.translation(in: recognizer.view!)
            let anglePan = (self.panDirection == "horizontal") ?  GameHelper.deg2rad(deg: Float(translation.x)) : GameHelper.deg2rad(deg: Float(translation.y))
            
            let y:CGFloat = (self.panDirection == "horizontal" ) ?  1 : 0.0
            
            // calculate the angle change from last call
            let fraction = CGFloat(anglePan - lastAngle)
            lastAngle = anglePan
            
            // perform rotation by difference to last angle
            scenc.rootNode.runAction(SCNAction.rotate(by: fraction, around: SCNVector3(0,y,0), duration: 0.1))
            
            
            if(recognizer.state == .ended) {
                
                // calculate angle to snap to 90 degree increments
                let finalRotation = GameHelper.rad2deg(rad:anglePan)
                let diff = finalRotation.truncatingRemainder(dividingBy: 90.0)
                var finalDiff = Float(0.0)
                
                switch diff {
                case 45..<90 :
                    finalDiff = 90 - diff
                case 0..<45 :
                    finalDiff = -diff
                case -45..<0 :
                    finalDiff = abs(diff)
                case -90 ..< -45 :
                    finalDiff = -90 - diff
                default:
                    print("do nothing")
                }
                
                // final transform to apply snap to closest 90deg increment
                let snapAngle = CGFloat(GameHelper.deg2rad(deg: finalDiff))
                scenc.rootNode.runAction(SCNAction.rotate(by: snapAngle, around: SCNVector3(0,y,0), duration: 0.1))
            }
        }

    }
    
    @objc func handlePinchGesture(withGestureRecognizer recognizer: UIPinchGestureRecognizer) {
        if let scene = self.modelScene {
            let zoom = recognizer.scale
            if (recognizer.state == .began){
                startScale = lastScale
            } else if (recognizer.state == .changed){
                let fov = Double(startScale * zoom)
                scene.rootNode.scale = SCNVector3(fov,fov,fov)
            } else {
                lastScale = startScale * zoom
            }
        }
    }
    
    @objc func selectSceneView(withGestureRecognizer recognizer: UIGestureRecognizer) {
        if recognizer.state == .ended {
            let location: CGPoint = recognizer.location(in: sceneView)
            let hits = self.sceneView.hitTest(location, options: nil)
            if !hits.isEmpty{
                let tappedNode = hits.first?.node
            }
        }
    }
    
    @objc func addShipToSceneView(withGestureRecognizer recognizer: UIGestureRecognizer) {
        let tapLocation = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)

        guard let hitTestResult = hitTestResults.first else { return }
        let translation = hitTestResult.worldTransform.translation
        let x = translation.x
        let y = translation.y
        let z = translation.z

        if let scene = self.modelScene {
            scene.rootNode.position = SCNVector3(x,y,z)
        }else if let model = self.modelPath {
            if FileManager.default.fileExists(atPath: model.path) {
                guard let scene = try? SCNScene(url: model)
                    else { return }
                scene.rootNode.position = SCNVector3(x,y,z)
                scene.rootNode.scale = SCNVector3(0.01,0.01,0.01)
                sceneView.scene.rootNode.addChildNode(scene.rootNode)

                self.modelScene = scene
            }
        }else {
            let alertUser = UIAlertController(title: "", message: "No model found", preferredStyle: UIAlertController.Style.alert)
            let action = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
            alertUser.addAction(action)
            self.navigationController?.present(alertUser, animated: true, completion: nil)
        }
    }
    
    func addTapGestureToSceneView() {
        let twoTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectSceneView(withGestureRecognizer:)))
        twoTapGestureRecognizer.numberOfTapsRequired = 2
        sceneView.addGestureRecognizer(twoTapGestureRecognizer)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(addShipToSceneView(withGestureRecognizer:)))
        tapGestureRecognizer.require(toFail: twoTapGestureRecognizer)
        sceneView.addGestureRecognizer(tapGestureRecognizer)
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(pinchGestureRecognizer)
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(panGestureRecognizer)
    }
}

extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}

extension UIColor {
    open class var transparentLightBlue: UIColor {
        return UIColor(red: 90/255, green: 200/255, blue: 250/255, alpha: 0.50)
    }
}

extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        
        let plane = SCNPlane(width: width, height: height)
        plane.materials.first?.diffuse.contents = UIColor.clear

        let planeNode = SCNNode(geometry: plane)
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x,y,z)
        planeNode.eulerAngles.x = -.pi / 2
        
        node.addChildNode(planeNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {

        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
        
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        plane.width = width
        plane.height = height
        
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x, y, z)
    }
}

extension ARSCNView {
    func setUp(viewController: ARSCNViewDelegate, session: ARSession) {
        delegate = viewController
        self.session = session
        antialiasingMode = .multisampling4X
        automaticallyUpdatesLighting = false
        preferredFramesPerSecond = 60
        contentScaleFactor = 1.3
        enableEnvironmentMapWithIntensity(25.0)
        if let camera = pointOfView?.camera {
            camera.wantsHDR = true
            camera.wantsExposureAdaptation = true
            camera.exposureOffset = -1
            camera.minimumExposure = -1
        }
    }
    
    func enableEnvironmentMapWithIntensity(_ intensity: CGFloat) {
        if scene.lightingEnvironment.contents == nil {
            if let environmentMap = UIImage(named: "art.scnassets/sharedImages/environment_blur.exr") {
                scene.lightingEnvironment.contents = environmentMap
            }
        }
        scene.lightingEnvironment.intensity = intensity
    }
}

class GameHelper {
    
    static func rad2deg( rad:Float ) -> Float {
        return rad * (Float) (180.0 /  Double.pi)
    }
    
    static func deg2rad( deg:Float ) -> Float{
        return deg * (Float)(Double.pi / 180)
    }
    
    static func getPanDirection(velocity: CGPoint) -> String {
        var panDirection:String = ""
        if ( velocity.x > 0 && velocity.x > abs(velocity.y) || velocity.x < 0 && abs(velocity.x) > abs(velocity.y) ){
            panDirection = "horizontal"
        }
        
        if ( velocity.y < 0 && abs(velocity.y) > abs(velocity.x) || velocity.y > 0 &&  velocity.y  > abs(velocity.x)) {
            panDirection = "vertical"
        }
        
        
        return panDirection
    }
    
}
