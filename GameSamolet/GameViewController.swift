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
    // var startRotate: SCNVector4! // изначальный поворот кривой модели
    let depth: Int = -80 // Глубина 3D
    
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
    func addShip (ship: SCNNode, x: Int, y: Int, z: Int){
        scene.rootNode.addChildNode(ship) // добавляем на сцену
        ship.position = SCNVector3 (x, y, z) //задаем позицию
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
        let x = Int.random(in: 0 ... 30)
        let y = Int.random(in: -30 ... 30)
        ship = getShip (filepath: "art.scnassets/ship.scn", nodeName: "ship")
        addShip(ship: ship, x: x, y: y, z: depth)
        ship38 = getShip (filepath: "art.scnassets/TAL38OBJ.dae", nodeName: "node")
        addShip(ship: ship38, x: -x, y: y, z: depth)
        //ship38.rotation = startRotate // поворачиваем кривую модель
        ship.runAction(.move(to: SCNVector3(0, 0, 0), duration: 10)) {
            //print(#line, #function) //для отладки выводим номер строки и функцию
            DispatchQueue.main.async { //runAction по умолчанию запускается в дополнительном потоке на 10 сек, тут указываем что кнопку надо показать в основном потоке
                self.button.isHidden = false // делаем кнопку видимой когда самолет долетел
                self.removeShip(nodeName: "node") // убираем с экрана сторой самолет, чтоб не мешал
            }
        }
        ship38.runAction(.move(to: SCNVector3(0, 0, 0), duration: 10)) {
            DispatchQueue.main.async {self.button.isHidden = false} // делаем кнопку видимой когда самолет долетел
            self.removeShip(nodeName: "ship") // убираем с экрана сторой самолет, чтоб не мешал
            }
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
        
        // говорим что view у viewController'a будет не просто пряугольник, а 3d-сцена
        scnView = self.view as? SCNView
        
        // и указываем какая именно (ранее созданная)
        scnView.scene = scene
        
        // разрешаем пользователю вращать камеру
        scnView.allowsCameraControl = true
        
        // показываем FramePerSecond (FPS), время и прочую статистику
        scnView.showsStatistics = false
        
        // цвет фона (но он тут заслоняется готовой сценой с самолетом)
        scnView.backgroundColor = UIColor.black
        
        // перехватываем жесты нажатия на самолет и вызываем handleTap при нажатии
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture) // добавляем распознаватель жестов
        
        ship = getShip (filepath: "art.scnassets/ship.scn", nodeName: "ship") // получаем модель самолета из файла
        addShip(ship: ship, x: 25, y: 25, z: depth) // добавляем на сцену
        // анимация
        // ship.runAction(.move(to: SCNVector3(0, 0, 0), duration: 10))
        
        // {} после функции - это замыкание, функция без имени, вызываемая после окончания функции runAction
        ship.runAction(.move(to: SCNVector3(0, 0, 0), duration: 10)) {
            //print(#line, #function) //для отладки выводим номер строки и функцию
            DispatchQueue.main.async { //runAction по умолчанию запускается в дополнительном потоке на 10 сек, тут указываем что кнопку надо показать в основном потоке
                self.button.isHidden = false // делаем кнопку видимой когда самолет долетел
                self.removeShip(nodeName: "node") // убираем с экрана сторой самолет, чтоб не мешал
            }
            
        }
        // задаем анимацию (вращение) = постоянное, вдоль оси у на 2 радиана за 1 секунду
        // ship.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))
        // ship.runAction(SCNAction.rotateBy(x: 0, y: CGFloat.pi, z: 0, duration: 1))
        
        ship38 = getShip (filepath: "art.scnassets/TAL38OBJ.dae", nodeName: "node") // грузим второй самолет из файла
        addShip(ship: ship38, x: -25, y: 25, z: depth) // и добавляем на сцену
        //ship38.runAction(SCNAction.rotateBy(x: -CGFloat.pi/2, y: 0, z: 0, duration: 0)) {// поворачиваем его как надо
        //    self.startRotate = self.ship38.rotation }
        // анимация
        //ship38.runAction(.move(to: SCNVector3(0, 0, 0), duration: 10))
        ship38.runAction(.move(to: SCNVector3(0, 0, 0), duration: 10)) {
            DispatchQueue.main.async {
                self.button.isHidden = false // делаем кнопку видимой когда самолет долетел
                self.removeShip(nodeName: "ship") // убираем с экрана сторой самолет, чтоб не мешал
            }
        }
        
        // Добавляем кнопку Restart
        addRestartButton()
        
    }
    
    // MARK: - Actions
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // получаем ссылку на сцену
        let scnView = self.view as! SCNView
        var nodeName: String! // имя нажимаемой ноды
        
        // проверяем что нода была нажата
        let p = gestureRecognize.location(in: scnView) // нажатие было внутри сцены? получаем координаты x,y касания пальцем на двухмерном экране
        let hitResults = scnView.hitTest(p, options: [:]) // результат нажатия, массив объектов. Если провести воображаемый луч от глаза пользователя через точку касания на экране вглубь сцены, в массив попадают по порядку все объекты через которые проходит луч вглубь сцены
        // проверяем что получился как минимум 1 объект
        if hitResults.count > 0 {
            // получаем первый нажатый объект, ближний к пользователю
            let result = hitResults[0]
            
            // получаем материал этого нажатого объекта
            let material = result.node.geometry!.firstMaterial!
            
            // получаем имя подсвеченной ноды
            nodeName = result.node.name
            if nodeName == "shipMesh" { nodeName = "ship"} // у модели самолета почему то две ноды ship и shipMesh
            
            // подсвечиваем объект
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.2 // длительность анимации подсветки
            
            // когда закончится подсветка - вовзвращаем все как было
            SCNTransaction.completionBlock = {
//                SCNTransaction.begin()
//                SCNTransaction.animationDuration = 0.5 // длительность анимации возвращения родного цвета
//
//                material.emission.contents = UIColor.black // emission - свойство материала, показывающее, насколько этот материал излучает; цвет излучения черный, т.е. не излучает
//
//                SCNTransaction.commit()
                
                self.removeShip(nodeName: nodeName) // уничтожаем объект в который попали
                //print(nodeName)
                let x = Int.random(in: 0 ... 30)
                let y = Int.random(in: -30 ... 30)
                if nodeName == "ship" {
                    self.ship = self.getShip (filepath: "art.scnassets/ship.scn", nodeName: "ship") // получаем модель самолета из файла
                    self.addShip(ship: self.ship, x: x, y: y, z: self.depth) // добавляем на сцену
                    self.ship.runAction(.move(to: SCNVector3(0, 0, 0), duration: 10)) {
                        DispatchQueue.main.async {self.button.isHidden = false} // делаем кнопку видимой когда самолет долетел
                        self.removeShip(nodeName: "node") // убираем с экрана сторой самолет, чтоб не мешал
                    }
                }
                if nodeName == "node" {
                    self.ship38 = self.getShip (filepath: "art.scnassets/TAL38OBJ.dae", nodeName: "node") // получаем модель самолета из файла
                    self.addShip(ship: self.ship38, x: x, y: y, z: self.depth) // добавляем на сцену
                    self.ship38.runAction(.move(to: SCNVector3(0, 0, 0), duration: 10)) {
                        DispatchQueue.main.async {self.button.isHidden = false} // делаем кнопку видимой когда самолет долетел
                        self.removeShip(nodeName: "ship") // убираем с экрана сторой самолет, чтоб не мешал
                        }
                }
                
            } //конец завершающего блока анимации
            // далее - начальный блок анимации
            material.emission.contents = UIColor.red // цвет излучения материала - красный
            
            SCNTransaction.commit()
        }
        //self.removeShip(nodeName: nodeName)
    }
    
    // MARK: - Compute Properties
    override var shouldAutorotate: Bool { // поворот сцены вместе с поворотом экрана телефона
        return true
    }
    
    override var prefersStatusBarHidden: Bool { //скрыть статус-бар
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

}
