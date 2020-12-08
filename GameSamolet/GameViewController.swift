//
//  GameViewController.swift
//  GameSamolet
//
//  Created by Андрей Двойцов on 08.12.2020.
//

//import UIKit
//import QuartzCore
import SceneKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        // override перезаписывает родительскую функцию
        //viewDidLoad запускается после создания главного ViewController'a
        super.viewDidLoad()
        //super вызывает не перезаписанную функцию из родительского класса
        
        // создаем сцену на основе модели ship.scn
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        // let задает константу
        // ! значит, что константа scene точно не равняется nil и не надо это проверять
        
        // создаем и добавляем камеру на сцену
        let cameraNode = SCNNode() // создаем ноду(узел) она сама по себе невидима
        // к ноде можно цеплять камеру, свет, геометрию, тогда она становится видима
        cameraNode.camera = SCNCamera() //цепляем камеру к ноде, создаем точку обзора
        scene.rootNode.addChildNode(cameraNode) //добавляем чайлд ноду к корневой ноде
        //сцена состоит из нод, расположенных сверху вниз
        //сначала корневая(рут) нода, потом остальные
        
        // размещаем в пространстве ноду с камерой, задаем ей координаты
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        
        // создаем точечный источник света, он висит в пространстве по координатам
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni //тип = точечный
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // создаем фоновую подсветку, она общая для всего, нигде не висит
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient //тип = фоновый
        ambientLightNode.light!.color = UIColor.init(red: 135/255, green: 206/255, blue: 235/255, alpha: 0) // цвет подсветки = небесно-голубой
        scene.rootNode.addChildNode(ambientLightNode)
        
        // находим на сцене ноду с именем "ship" и присваиваем ее константе ship
        let ship = scene.rootNode.childNode(withName: "ship", recursively: true)!
        
        // задаем анимацию (вращение) = постоянное, вдоль оси у на 2 радиана за 1 секунду
        // ship.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))
        ship.runAction(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1))
        
        // говорим что view у viewController'a будет не просто пряугольник, а 3d-сцена
        let scnView = self.view as! SCNView
        
        // и указываем какая именно (ранее созданная)
        scnView.scene = scene
        
        // разрешаем пользователю вращать камеру
        scnView.allowsCameraControl = true
        
        // показываем FramePerSecond (FPS), время и прочую статистику
        // scnView.showsStatistics = true
        
        // цвет фона (но он тут заслоняется готовой сценой с самолетом)
        scnView.backgroundColor = UIColor.black
        
        // перехватываем жесты нажатия на самолет и вызываем handleTap при нажатии
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture) // добавляем распознаватель жестов
    }
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            
            // get its material
            let material = result.node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                material.emission.contents = UIColor.black
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = UIColor.red
            
            SCNTransaction.commit()
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

}
