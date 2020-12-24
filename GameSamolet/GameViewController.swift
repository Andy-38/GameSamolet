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
    let scoreLabel = UILabel()
    let gameoverLabel = UILabel()
    
    // MARK: - Stored Properties
    var gameoverflag: Bool = false // флаг конца игры
    //var scene: SCNScene? //scene - переменная типа SCNScene. Знак "?" значит что изначально она равна nil т.е. ничего
    var scene: SCNScene! //scene - переменная типа SCNScene. Знак "!" значит что ей точно будет присвоено значение, но позже
    var scnView: SCNView!
    var speed: TimeInterval = 10 // скорость подлета самолетов (время в секундах)
    var score = 0 { // для подсчета сбитых самолетов
        didSet { // вызывается после изменения score
        // oldValue - старое значение
            scoreLabel.text = "Очки: \(score)"
        }
        //willSet { // вызывается перед изменением score
        //}
    }
    var ship: SCNNode!
    var ship38: SCNNode!
    var cameraNode: SCNNode!
    // var startRotate: SCNVector4! // изначальный поворот кривой модели
    let depth: Int = -90 // Глубина 3D
    let maxX: Int = 30 // макс. координата по Х
    let maxY: Int = 30 // макс. координата по Y
    
    // MARK: - Methods
    
    
    /// Добавляем label с указанием очков
    func addGameoverLabel() {
        gameoverLabel.frame = CGRect(x: 0, y: 50, width: scnView.frame.width, height: 100)
        gameoverLabel.numberOfLines = 2
        gameoverLabel.textAlignment = .center
        gameoverLabel.font = UIFont.systemFont(ofSize: 30)
        gameoverLabel.textColor = .white
        gameoverLabel.isHidden = true // надпись пока что скрытая
        scnView.addSubview(gameoverLabel) // добавляем label на экран
        score = 0
    }

    /// Добавляем label с указанием очков
    func addScoreLabel() {
        scoreLabel.frame = CGRect(x: 10, y: 0, width: scnView.frame.width-10, height: 40)
        //scoreLabel.numberOfLines = 1
        scoreLabel.textAlignment = .left
        scoreLabel.font = UIFont.systemFont(ofSize: 15)
        scnView.addSubview(scoreLabel) // добавляем label на экран
    }
    
    /// Добавляем кнопку Restart
    func addRestartButton() {
        let width: CGFloat = 200
        let height: CGFloat = 40
        button.frame = CGRect(x: scnView.frame.midX - width/2, y: scnView.frame.maxY - height - 10, width: width, height: height)
        button.setTitle("Новая игра", for: .normal)             //текст на кнопке и состояние кнопки
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
    
    /// Конец игры
    func gameOver (nodname: String){
        // разрешаем пользователю вращать камеру
        scnView.allowsCameraControl = true
        //button.frame = CGRect(x: scnView.frame.midX - 100, y: scnView.frame.maxY - 50, width: 200, height: 40)
        button.isHidden = false // делаем кнопку видимой когда самолет долетел
        scoreLabel.isHidden = true
        gameoverLabel.text = "Игра окончена!\n Очки: \(score)"
        //gameoverLabel.frame = CGRect(x: 0, y: 50, width: scnView.frame.width, height: 100)
        gameoverLabel.isHidden = false // показываем надпись Конец игры
        gameoverflag = true // конец игры
        removeShip(nodeName: nodname) // убираем с экрана сторой самолет, чтоб не мешал
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
        //cameraNode.look(at: SCNVector3(0, 0, 0))
        //print(cameraNode.rotation)
        //cameraNode.rotation = SCNVector4(0,0,0,1) // поворачиваем камеру в исходное положение
        //print(cameraNode.rotation)
        //print (cameraNode.eulerAngles)
        // запрещаем пользователю вращать камеру
        //print(scnView.defaultCameraController.target)
        //scnView.defaultCameraController.target = SCNVector3(0,0,0)
        
        // создаем изначальную сцену
        createScene()
        scnView.allowsCameraControl = false
        button.isHidden = true
        gameoverLabel.isHidden = true
        scoreLabel.isHidden = false
        gameoverflag = false
        score = 0 // сбрасываем счетчик очков
        speed = 10 // и скорость подлета
        //ship.removeFromParentNode() // убираем самолет
        //ship38.removeFromParentNode() // убираем самолет 38
        removeShip(nodeName: "ship") // убираем самолет
        removeShip(nodeName: "node") // убираем самолет 38
        //cameraNode.removeFromParentNode()
        //scene.rootNode.addChildNode(cameraNode)
        let x = Int.random(in: 0 ... maxX)
        let y = Int.random(in: -maxY ... maxY)
        ship = getShip (filepath: "art.scnassets/ship.scn", nodeName: "ship")
        addShip(ship: ship, x: x, y: y, z: depth)
        ship.runAction(.move(to: SCNVector3(0, 0, 0), duration: speed)) {
            //print(#line, #function) //для отладки выводим номер строки и функцию
            DispatchQueue.main.async { //runAction по умолчанию запускается в дополнительном потоке на 10 сек, тут указываем что кнопку и текст надо показать в основном потоке
                self.gameOver (nodname: "node")
            }
        }
        
//        ship38 = getShip (filepath: "art.scnassets/TAL38OBJ.dae", nodeName: "node")
//        addShip(ship: ship38, x: -x, y: y, z: depth)
//        ship38.runAction(.move(to: SCNVector3(0, 0, 0), duration: speed)) {
//            DispatchQueue.main.async {
//                self.gameOver (nodname: "ship")
//            }
//        }
    }
    
    /// Находит и удаляет объект с именем nodeName со сцены
    func removeShip(nodeName: String) {
        scene.rootNode.childNode(withName: nodeName, recursively: true)?.removeFromParentNode()
    }
    
    /// Создает начальную сцену
    func createScene() {
        // создаем сцену на основе модели ship.scn
        scene = SCNScene(named: "art.scnassets/ship.scn")!
        // let задает константу
        // ! значит, что константа scene точно не равняется nil и не надо это проверять
        removeShip(nodeName: "ship") //удаляем со сцены изначальный самолет
        
        // создаем и добавляем камеру на сцену
        cameraNode = SCNNode() // создаем ноду(узел) она сама по себе невидима
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
        //lightNode.light?.castsShadow = true // отбрасываем тени
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
        
        // показываем FramePerSecond (FPS), время и прочую статистику
        scnView.showsStatistics = false
        
        // цвет фона (но он тут заслоняется готовой сценой с самолетом)
        scnView.backgroundColor = UIColor.black
        
        // перехватываем жесты нажатия на самолет и вызываем handleTap при нажатии
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture) // добавляем распознаватель жестов
    }
    
    override func viewDidLoad() {
        // override перезаписывает родительскую функцию
        //viewDidLoad запускается после создания главного ViewController'a
        super.viewDidLoad()
        //super вызывает не перезаписанную функцию из родительского класса
        
        // создаем изначальную сцену
        createScene()
        
        // запрещаем пользователю вращать камеру
        scnView.allowsCameraControl = false
        
        ship = getShip (filepath: "art.scnassets/ship.scn", nodeName: "ship") // получаем модель самолета из файла
        addShip(ship: ship, x: maxX-5, y: maxY-5, z: depth) // добавляем на сцену
        // анимация
        // {} после функции - это замыкание, функция без имени, вызываемая после окончания функции runAction
        ship.runAction(.move(to: SCNVector3(0, 0, 0), duration: speed)) {
            //print(#line, #function) //для отладки выводим номер строки и функцию
            DispatchQueue.main.async { //runAction по умолчанию запускается в дополнительном потоке на 10 сек, тут указываем что кнопку и текст надо показать в основном потоке
                self.gameOver (nodname: "node") // если долетел - то gameover
            }
        }
        // задаем анимацию (вращение) = постоянное, вдоль оси у на 2 радиана за 1 секунду
        // ship.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))
        // ship.runAction(SCNAction.rotateBy(x: 0, y: CGFloat.pi, z: 0, duration: 1))
        
        
//        ship38 = getShip (filepath: "art.scnassets/TAL38OBJ.dae", nodeName: "node") // грузим второй самолет из файла
//        addShip(ship: ship38, x: -(maxX-5), y: maxY-5, z: depth) // и добавляем на сцену
//        // анимация
//        ship38.runAction(.move(to: SCNVector3(0, 0, 0), duration: speed)) {
//            DispatchQueue.main.async {
//                self.gameOver (nodname: "ship") // если долетел - то gameover
//            }
//        }
        
        
        // Добавляем кнопку Restart и label со счетчиком очков
        addRestartButton()
        addScoreLabel()
        addGameoverLabel()
    }
    // MARK: - Actions
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        if !gameoverflag {
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
            SCNTransaction.animationDuration = 0.05 // длительность анимации подсветки
            // когда закончится подсветка - вовзвращаем все как было
            SCNTransaction.completionBlock = {
//                SCNTransaction.begin()
//                SCNTransaction.animationDuration = 0.5 // длительность анимации возвращения родного цвета
//                material.emission.contents = UIColor.black // emission - свойство материала, показывающее, насколько этот материал излучает; цвет излучения черный, т.е. не излучает
//                SCNTransaction.commit()
                self.score+=1 // увелииваем очки при сбитии самолета
                if (self.score % 2 == 0) { self.speed*=0.95 } // увеличиваем скорость подлета самолета через каждые 2 раза
                self.removeShip(nodeName: nodeName) // уничтожаем объект в который попали
                //print(nodeName)
                let x = Int.random(in: -self.maxX ... self.maxX)
                let y = Int.random(in: -self.maxY ... self.maxY)
                // создаем новый корабль вдалеке в случайных координатах
                if nodeName == "ship" { // если сбили первый самолет
                    self.ship = self.getShip (filepath: "art.scnassets/ship.scn", nodeName: "ship") // получаем модель самолета из файла
                    self.addShip(ship: self.ship, x: x, y: y, z: self.depth) // добавляем на сцену
                    self.ship.runAction(.move(to: SCNVector3(0, 0, 0), duration: self.speed)) {
                        DispatchQueue.main.async {
                            self.gameOver (nodname: "node") // если долетел - то gameover
                        }
                    }
                }
                if (nodeName == "node") || (self.score == 10) { // если сбили второй самолет или набрали 10 очков
                    self.ship38 = self.getShip (filepath: "art.scnassets/TAL38OBJ.dae", nodeName: "node") // получаем модель самолета из файла
                    self.addShip(ship: self.ship38, x: -x, y: y, z: self.depth) // добавляем на сцену
                    self.ship38.runAction(.move(to: SCNVector3(0, 0, 0), duration: self.speed)) {
                        DispatchQueue.main.async {
                            self.gameOver (nodname: "ship") // если долетел - то gameover
                        }
                    }
                }
            } //конец завершающего блока анимации
            // далее - начальный блок анимации
            material.emission.contents = UIColor.red // цвет излучения материала - красный
            SCNTransaction.commit()
        }
        }
    }
    
    // вызывается при повороте устройства
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { _ in
            // меняем расположение кнопок и надписей в зависимость от повотора экрана
            self.button.frame = CGRect(x: self.scnView.frame.midX - 100, y: self.scnView.frame.maxY - 50, width: 200, height: 40)
            self.gameoverLabel.frame = CGRect(x: 0, y: 50, width: self.scnView.frame.width, height: 100)
        }
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
