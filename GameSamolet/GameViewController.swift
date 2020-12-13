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
    
    // MARK: - Outlets
    let button = UIButton()
    
    
    // MARK: - Stored Properties
    //var scene: SCNScene? //scene - переменная типа SCNScene. Знак "?" значит что изначально она равна nil т.е. ничего
    var scene: SCNScene! //scene - переменная типа SCNScene. Знак "!" значит что ей точно будет присвоено значение, но позже
    var scnView: SCNView!
    var ship: SCNNode!
    var ship38: SCNNode!
    
    // MARK: - Methods
    /// Добавляем кнопку Restart
    func addRestartButton() {
        let width: CGFloat = 200
        let height: CGFloat = 40
        button.frame = CGRect(x: scnView.frame.midX - width/2, y: scnView.frame.maxY - height - 10, width: width, height: height)
        button.setTitle("С начала", for: .normal)               //текст на кнопке и состояние кнопки
        button.backgroundColor = .red                           // цвет фона
        button.layer.cornerRadius = 16                          // скругление углов
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20) //размер шрифта
        button.isHidden = true                                  //кнопка пока что скрытая
        // добавляем обработчик нажатия кнопки
        button.addTarget(self, action: #selector(newGame), for: .touchUpInside)
        // добавляем кнопку на экран
        scnView.addSubview(button)
    }
    
    /// Добавляем самолет на сцену
    func addShip (ship: SCNNode, x: Float, y: Float, z: Float){
        scene.rootNode.addChildNode(ship) // добавляем на сцену
        ship.position = SCNVector3 (x, y, z) //задаем позицию
//        if ship.name == "node" { // если модель кривая, то поворачиваем ее как надо
//            ship.runAction(SCNAction.rotateBy(x: -CGFloat.pi/2, y: 0, z: 0, duration: 0))}
        ship.look(at: SCNVector3(2*x, 2*y, 2*z)) // задаем направление куда смотрит модель
    }
    
    /// Создает новый объект из сцены
    /// - Returns: SCNNode with object
    func getShip(filepath: String, nodeName: String) -> SCNNode {
        // создаем сцену на основе модели ship.scn
        let scene = SCNScene(named: filepath)!
        // находим на сцене ноду с именем nodeName и присваиваем ее константе ship
        let ship = scene.rootNode.childNode(withName: nodeName, recursively: true)!.clone()
        return ship
    }
    
//    class func loadFromFileToSCNNode(filepath:String) -> SCNNode { //функция для загрузки объекта из файла
//        let node = SCNNode()
//        let scene = SCNScene(named: filepath)
//        let nodeArray = scene!.rootNode.childNodes
//        for childNode in nodeArray {
//            node.addChildNode(childNode as SCNNode)
//        }
//        return node
    //    }
    
    
    /// Вызов новой игры
    // @objc значит, что функция пишется на языке object C, чтобы ее можно было навесить на обработчик кнопки
    @objc func newGame() {
        //print (#line, #function)
        button.isHidden = true
        //ship.removeFromParentNode() // убираем самолет
        //ship38.removeFromParentNode() // убираем самолет 38
        removeShip(nodeName: "ship") // убираем самолет
        removeShip(nodeName: "node") // убираем самолет 38
        addShip(ship: ship, x: 25.0, y: 25.0, z: -100.0)
        addShip(ship: ship38, x: -25.0, y: 25.0, z: -100.0)
        //ship38.runAction(SCNAction.rotateBy(x: -CGFloat.pi/2, y: 0, z: 0, duration: 0))
        ship.runAction(.move(to: SCNVector3(0, 0, 0), duration: 10)) {
            //print(#line, #function) //для отладки выводим номер строки и функцию
            DispatchQueue.main.async { //runAction по умолчанию запускается в дополнительном потоке на 10 сек, тут указываем что кнопку надо показать в основном потоке
                self.button.isHidden = false // делаем кнопку видимой когда самолет долетел
            }
        }
        ship38.runAction(SCNAction.rotateBy(x: -CGFloat.pi/2, y: 0, z: 0, duration: 0))
        ship38.runAction(.move(to: SCNVector3(0, 0, 0), duration: 10))
    }
    
    /// Находит и удаляет объект с именем nodeName со сцены
    func removeShip(nodeName: String) {
        scene.rootNode.childNode(withName: nodeName, recursively: true)?.removeFromParentNode()
    }
    
    override func viewDidLoad() {
        // override перезаписывает родительскую функцию
        //viewDidLoad запускается после создания главного ViewController'a
        super.viewDidLoad()
        //super вызывает не перезаписанную функцию из родительского класса
        
        // создаем сцену на основе модели ship.scn
        scene = SCNScene(named: "art.scnassets/ship.scn")!
        //let scene = SCNScene(named: "art.scnassets/TAL16OBJ.dae")!
        // let задает константу
        // ! значит, что константа scene точно не равняется nil и не надо это проверять
        removeShip(nodeName: "ship") //удаляем со сцены изначальный самолет
        
        // создаем и добавляем камеру на сцену
        let cameraNode = SCNNode() // создаем ноду(узел) она сама по себе невидима
        // к ноде можно цеплять камеру, свет, геометрию, тогда она становится видима
        cameraNode.camera = SCNCamera() //цепляем камеру к ноде, создаем точку обзора
        scene.rootNode.addChildNode(cameraNode) //добавляем чайлд ноду к корневой ноде
        //сцена состоит из нод, расположенных сверху вниз
        //сначала корневая(рут) нода, потом остальные
        
        // размещаем в пространстве ноду с камерой, задаем ей координаты
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 10)
        
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
        // ambientLightNode.light!.color = UIColor.init(red: 0, green: 1, blue: 0, alpha: 0)
        // цвет подсветки = зеленый
        scene.rootNode.addChildNode(ambientLightNode)
        
        // находим на сцене ноду с именем "ship" и присваиваем ее константе ship
        //let ship = scene.rootNode.childNode(withName: "ship", recursively: true)!
        
        // говорим что view у viewController'a будет не просто пряугольник, а 3d-сцена
        scnView = self.view as? SCNView
        
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
        
        ship = getShip (filepath: "art.scnassets/ship.scn", nodeName: "ship") // получаем модель самолета из файла
        addShip(ship: ship, x: 25.0, y: 25.0, z: -100.0) // добавляем на сцену
        // анимация
        //ship.runAction(SCNAction.moveBy(x: 0, y: 0, z: 10, duration: 5))
        // ship.runAction(.move(to: SCNVector3(0, 0, 0), duration: 10))
        
        // {} после функции - это замыкание, функция без имени, вызываемая после окончания функции runAction
        ship.runAction(.move(to: SCNVector3(0, 0, 0), duration: 10)) {
            //print(#line, #function) //для отладки выводим номер строки и функцию
            DispatchQueue.main.async { //runAction по умолчанию запускается в дополнительном потоке на 10 сек, тут указываем что кнопку надо показать в основном потоке
                self.button.isHidden = false // делаем кнопку видимой когда самолет долетел
            }
            
        }
        // задаем анимацию (вращение) = постоянное, вдоль оси у на 2 радиана за 1 секунду
        // ship.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))
        // ship.runAction(SCNAction.rotateBy(x: 0, y: CGFloat.pi, z: 0, duration: 1))
        // ship.runAction(SCNAction.moveBy(x: 0, y: 0, z: 10, duration: 5))
        
        
        
        //let ship38 = GameViewController.loadFromFileToSCNNode(filepath: "art.scnassets/TAL16OBJ.dae")
        ship38 = getShip (filepath: "art.scnassets/TAL16OBJ.dae", nodeName: "node") // грузим второй самолет из файла
        addShip(ship: ship38, x: -25.0, y: 25.0, z: -100.0) // и добавляем на сцену
        ship38.runAction(SCNAction.rotateBy(x: -CGFloat.pi/2, y: 0, z: 0, duration: 0)) // поворачиваем его как надо
        // анимация
        //ship.runAction(SCNAction.moveBy(x: 0, y: 0, z: 10, duration: 5))
        ship38.runAction(.move(to: SCNVector3(0, 0, 0), duration: 10))
        
        // Добавляем кнопку Restart
        addRestartButton()
        
    }
    
    // MARK: - Actions
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
    
    // MARK: - Compute Properties
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
