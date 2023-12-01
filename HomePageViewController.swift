//
//  HomePageViewController.swift
//  Gene
//
//  Created by manoj on 20/10/23.



import UIKit
import AVFoundation

class HomeViewController: UIViewController {
    
    
    
  let filter1View = UIView()
    let filter2View = UIView()
    let filter3View = UIView()
    let filter4View = UIView()
    let filter5View = UIView()
    let filter6View = UIView()
    let filter7View = UIView()
    var usebutton : UIButton!
    var profileButton : UIButton!
    var likeButton : UIButton!
    var commentButton : UIButton!
    var scrollView : UIScrollView!
    
    let imageCache = NSCache<NSString, UIImage>()
    
    
    let firstview = cameraViewController()
    let secondview = cameraViewController()
    let thirdview = cameraViewController()
    let fourthview = cameraViewController()
    let fifthview = cameraViewController()
    let sixthview = cameraViewController()
    let seventhview = cameraViewController()
    
   
    
    
override func viewDidLoad() {
    super.viewDidLoad()
  
    view.backgroundColor = .white
    
    
    let user1 = UserData(username: "user1", likesCount: 20, userCount: 11, comments: ["good"], imageLink: "https://1.img-dpreview.com/files/p/TS600x450~sample_galleries/4660266261/9717191255.jpg")
    let user2 =  UserData(username: "user2", likesCount: 22, userCount: 12, comments: ["amazing",], imageLink: "https://4.img-dpreview.com/files/p/TS600x450~sample_galleries/4660266261/1081683410.jpg")
    
    let user3 = UserData(username: "user3", likesCount: 23, userCount: 22, comments: ["nice"], imageLink:  "https://1.img-dpreview.com/files/p/TS600x450~sample_galleries/4660266261/2491138603.jpg")
    
    let user4 = UserData(username: "user4", likesCount: 34, userCount: 32, comments: ["good"], imageLink:  "https://4.img-dpreview.com/files/p/TS600x450~sample_galleries/4660266261/4167123167.jpg")
    
    let user5 = UserData(username: "user5", likesCount: 54, userCount: 2, comments: ["good"], imageLink:  "https://4.img-dpreview.com/files/p/TS600x450~sample_galleries/4660266261/1639460135.jpg")
    
    let user6 = UserData(username: "user6", likesCount: 34, userCount: 32, comments: ["good"], imageLink:  "https://1.img-dpreview.com/files/p/TS600x450~sample_galleries/4660266261/8594185784.jpg")
    
    
    let user7 = UserData(username: "user7", likesCount: 34, userCount: 32, comments: ["good"], imageLink:  "https://2.img-dpreview.com/files/p/TS600x450~sample_galleries/4660266261/3008600982.jpg")
    

    setupUI()
    let cameraImage = UIImage(systemName: "livephoto")?.withTintColor(.white, renderingMode: .alwaysOriginal)
    let cameraButton = UIButton()
    
    cameraButton.translatesAutoresizingMaskIntoConstraints = false
    cameraButton.setImage(cameraImage, for: .normal)
    cameraButton.transform = CGAffineTransform(scaleX: 3, y: 3)
 
    cameraButton.addTarget(self, action: #selector(openCamera(_:)), for: .touchUpInside)
    view.addSubview(cameraButton)

/*
 let headtittle = UILabel()
    headtittle.text = "G E N E"
    headtittle.font = UIFont.boldSystemFont(ofSize: 25)
    headtittle.textColor = .systemYellow
    headtittle.textAlignment = .center
    headtittle.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(headtittle)*/

 
        NSLayoutConstraint.activate([
        cameraButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        cameraButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
        cameraButton.widthAnchor.constraint(equalToConstant: 40),
        cameraButton.heightAnchor.constraint(equalTo: cameraButton.widthAnchor),
        
//        headtittle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 42),
//        headtittle.bottomAnchor.constraint(equalTo: view.topAnchor,constant: 51)
        
        
      
    ])
    
    
    
    loadUserImage(from: user1, for: filter1View, tag: 1)
    loadUserImage(from: user2, for: filter2View, tag: 2)
    loadUserImage(from: user3, for: filter3View, tag: 3)
    loadUserImage(from: user4, for: filter4View, tag: 4)
    loadUserImage(from: user5, for: filter5View, tag: 5)
    loadUserImage(from: user6, for: filter6View, tag: 6)
    loadUserImage(from: user7, for: filter7View, tag: 7)
    


    
    
    let backButton = UIBarButtonItem(title: "Home", style: .plain, target: nil, action: nil)
    navigationItem.backBarButtonItem = backButton
    
}

override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    coordinator.animate(alongsideTransition: { _ in
        // Update UI layout for the new orientation
        //self.updateLayoutForOrientation()
    }, completion: nil)
}


    
    
    func loadUserImage(from userData: UserData, for view: UIView, tag: Int) {
        loadImage(from: userData.imageLink) {  (image) in
            DispatchQueue.main.async {
                let imageView = UIImageView(image: image)
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                imageView.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(imageView)
                
        
            
        
                
                NSLayoutConstraint.activate([
                    imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
                    imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60),
                    
                 

                ])
            }
           
                  
        }

      
        let userImage = UIImage(systemName: "rectangle.portrait.and.arrow.forward")?.withTintColor(.black, renderingMode: .alwaysOriginal)
         usebutton = UIButton()
        usebutton.setImage(userImage, for: .normal)
        usebutton.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        usebutton.translatesAutoresizingMaskIntoConstraints = false
        usebutton.tag = tag
        usebutton.addTarget(self, action: #selector(useButtonPressed(_:)), for: .touchUpInside)

     
       view.addSubview(usebutton)
        
        
        let profileImage = UIImage(systemName: "person.crop.circle.fill")?.withTintColor(.black, renderingMode: .alwaysOriginal)
        profileButton = UIButton()
        profileButton.setTitle(userData.username, for: .normal)
        profileButton.setTitleColor(.black, for: .normal)
        profileButton.setImage(profileImage, for: .normal)
        profileButton.transform = CGAffineTransform(scaleX: 1, y: 1)
       
        profileButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profileButton)
        
        let likeImage  = UIImage(systemName: "suit.heart.fill")?.withTintColor(.red, renderingMode: .alwaysOriginal)
        likeButton = UIButton()
        likeButton.setImage(likeImage, for: .normal)
        likeButton.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        
        likeButton.translatesAutoresizingMaskIntoConstraints = false
       view.addSubview(likeButton)
        
        let commandImage = UIImage(systemName: "message")?.withTintColor(.black, renderingMode: .alwaysOriginal)
        commentButton = UIButton()
        commentButton.setImage(commandImage, for: .normal)
        commentButton.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        commentButton.translatesAutoresizingMaskIntoConstraints  = false
        view.addSubview(commentButton)
    
        
       // view.addSubview(commentButton)
        
    
  
        let usersCountLabel = UILabel()
        usersCountLabel.text = "\(userData.userCount)"  // Convert Int to String for label text
        usersCountLabel.textColor = .black
        usersCountLabel.textAlignment = .center
        usersCountLabel.font = UIFont.systemFont(ofSize: 14)
        usersCountLabel.translatesAutoresizingMaskIntoConstraints = false
         view.addSubview(usersCountLabel)
    
        
        let likescount = UILabel()
        likescount.text = "\(userData.likesCount)"
        likescount.textColor = .black
        likescount.textAlignment = .center
        likescount.font = UIFont.systemFont(ofSize: 14)
        likescount.translatesAutoresizingMaskIntoConstraints = false
      
        view.addSubview(likescount)
        
        
     



        NSLayoutConstraint.activate([
            
      profileButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
      profileButton.bottomAnchor.constraint(equalTo: view.topAnchor, constant: 25),
           
      likeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 320),
      likeButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20 ),
      likeButton.widthAnchor.constraint(equalToConstant: 40),
      likeButton.heightAnchor.constraint(equalToConstant: 40),
      
      commentButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      commentButton.bottomAnchor.constraint(equalTo: likeButton.bottomAnchor),
      commentButton.widthAnchor.constraint(equalToConstant: 40),
      commentButton.heightAnchor.constraint(equalToConstant: 40),
      
         usebutton.leadingAnchor.constraint(equalTo: commentButton.trailingAnchor, constant: 120),
         usebutton.centerYAnchor.constraint(equalTo: commentButton.centerYAnchor),
         usebutton.widthAnchor.constraint(equalToConstant: 40),
         usebutton.heightAnchor.constraint(equalToConstant: 40),

     
          
        ])

      
        
       NSLayoutConstraint.activate([
      usersCountLabel.centerXAnchor.constraint(equalTo:usebutton.centerXAnchor, constant: -5),
   usersCountLabel.topAnchor.constraint(equalTo: usebutton.bottomAnchor, constant: 2),
            
            likescount.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 330),
            likescount.topAnchor.constraint(equalTo: likeButton.bottomAnchor, constant: 2)
        ])




    }

    func loadImage(from urlString: String, completion: @escaping (UIImage) -> Void) {
        guard let url = URL(string: urlString) else { return }

        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            completion(cachedImage)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, let image = UIImage(data: data) else { return }
            self.imageCache.setObject(image, forKey: urlString as NSString)
            completion(image)
        }.resume()
    }





func setupUI() {
    
    
    filter1View.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(filter1View)
  //  filter1View.backgroundColor = .white
    
    
    //filter2Button.setTitle("Filter 2", for: .normal)
    
   // filter2View.imageView?.contentMode = .scaleAspectFill
    //filter2View.addTarget(self, action: #selector(openFilter2(_:)), for: .touchUpInside)
    filter2View.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(filter2View)
  //  filter2View.backgroundColor = .white
    // filter3Button.setTitle("Filter 3", for: .normal)
    
   // filter3View.imageView?.contentMode = .scaleAspectFill
   // filter3View.addTarget(self, action: #selector(openFilter3(_:)), for: .touchUpInside)
    filter3View.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(filter3View)
  //  filter3View.backgroundColor = .white
    
    //filter4Button.setTitle("Filter 4", for: .normal)
   // filter4View.imageView?.contentMode = .scaleAspectFill
  //  filter4View.addTarget(self, action: #selector(openFilter4(_:)), for: .touchUpInside)
    filter4View.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(filter4View)
 //   filter4View.backgroundColor = .white
    
    //filter5Button.setTitle("Filter 5", for: .normal)
   // filter5View.imageView?.contentMode = .scaleAspectFill
  //  filter5View.addTarget(self, action: #selector(openFilter5(_:)), for: .touchUpInside)
    filter5View.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(filter5View)
  //  filter5View.backgroundColor = .white
    
  //  filter6View.imageView?.contentMode = .scaleAspectFill
   // filter6View.addTarget(self, action: #selector(openFilter6(_:)), for: .touchUpInside)
    filter6View.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(filter6View)
    //filter6View.backgroundColor = .white
    
    //filter7Button.setTitle("Filter 7", for: .normal)
    //filter7View.imageView?.contentMode = .scaleAspectFill
  //  filter7View.addTarget(self, action: #selector(openFilter7(_:)), for: .touchUpInside)
    filter7View.translatesAutoresizingMaskIntoConstraints = false
 //   filter7View.backgroundColor = .white
    view.addSubview(filter7View)
    
    
    

    
    let stackView = UIStackView(arrangedSubviews: [filter1View, filter2View, filter3View, filter4View, filter5View, filter6View, filter7View])
    stackView.axis = .vertical
    stackView.alignment = .fill
    stackView.distribution = .fill
    
    
    stackView.spacing = 10
   // stackView.backgroundColor = .white
    stackView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(stackView)
   

    
     scrollView = UIScrollView()
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.showsVerticalScrollIndicator = false
    scrollView.showsHorizontalScrollIndicator = false
    view.addSubview(scrollView)
    scrollView.addSubview(stackView)
    print("Navigation Bar Height: \(navigationController?.navigationBar.frame.size.height ?? 0)")
    print("Content Inset: \(scrollView.contentInset)")

    NSLayoutConstraint.activate([
           scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
           scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
           scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 60),
           scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
           
           stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
           stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
           stackView.topAnchor.constraint(equalTo: scrollView.topAnchor ),
           stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
           stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
       ])
   
}



@objc func handleCustomBack() {
    // Custom action when the custom back button is pressed
    // For example, you can navigate back or perform any other action
    navigationController?.popViewController(animated: true)
}


@objc func openCamera(_ sender: UIButton) {
    
    let CameraViewController = cameraViewController()
  //  CameraViewController.updateExposure(value: 0.5)// Assuming the class name is "CameraViewController"
    navigationController?.pushViewController(CameraViewController, animated: true)
   
}

    @objc func useButtonPressed(_ sender: UIButton) {
        // Check the tag to determine which function to call
        switch sender.tag {
        case 1:
           
         openFilter1()
       
        case 2:
            
           openFilter2()
            
        case 3 :
            openFilter3()
            
        case 4 :

            openFilter4()
            
        case 5:
            
            openFilter5()
            
        case 6:
            
            openFilter6()
            
        case 7:
            
            openFilter7()
            
            
        
        default:
            break
        }
    }

  func openFilter1() {
       
      let view = firstview
        view.updateExposure2(0.3474)
     //   view.toggleButtonsVisibility(true)
    
        navigationController?.pushViewController(seventhview, animated: true)
      
    
    }
  

  func openFilter2() {
        
      let view = secondview
        view.updateExposure2(0.3224)
      //  view.toggleButtonsVisibility(true)
        view.updateZoomFactor(1.5)
      view.aspectControll.selectedSegmentIndex = 1
    navigationController?.pushViewController(secondview, animated: true)
    }
    
 func openFilter3() {
       
      let view = thirdview
       view.updateExposure2(0.2434)
    //    view.toggleButtonsVisibility(true)
        view.updateZoomFactor(1.2)
    
        navigationController?.pushViewController(thirdview, animated: true)
        
    }
    
   func openFilter4() {
       
      let view = fourthview
        view.updateExposure2(0.4434)
      //  view.toggleButtonsVisibility(true)
        view.updateZoomFactor(2.5)
       view.exposureSlider?.value = 4.0
        navigationController?.pushViewController(fourthview, animated: true)
    }
 func openFilter5() {
       
      let view = fifthview
    view.updateExposure2(0.5434)
      //  view.toggleButtonsVisibility(true)
     
        navigationController?.pushViewController(fifthview, animated: true)
    }
   
    func openFilter6() {
       
      let view = sixthview
       view.updateExposure2(0.3434)
        view.toggleButtonsVisibility(true)
        navigationController?.pushViewController(sixthview, animated: true)
    }
    func openFilter7() {
       
      let view = seventhview
       view.updateExposure2(0.4474)
        view.toggleButtonsVisibility(true)
    
        navigationController?.pushViewController(seventhview, animated: true)
    }
  

   

}
