//
//  LoginViewController.swift
//  rockmotion
//
//  Created by John A. Cristobal on 6/10/19.
//  Copyright © 2019 rockmotion. All rights reserved.
//

import UIKit
import MediaPlayer
import AVKit
import AVFoundation
import SafariServices

class LoginViewController: UIViewController {

    @IBOutlet var videoView: UIView!
    @IBOutlet var dataView: UIView!
    @IBOutlet var joinButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        joinButton.roundCorner()
        // Do any additional setup after loading the view.
        guard let videoURL = Bundle.main.url(forResource: "fondo", withExtension:".mp4") else {
            debugPrint("video.m4v not found")
            return
        }
        
        let player = AVPlayer(url: videoURL)
        player.isMuted = true
        
        let playerLayer = AVPlayerLayer(player: player)
        self.videoView.layer.addSublayer(playerLayer)
        playerLayer.frame = self.view.layer.bounds
        playerLayer.videoGravity = AVLayerVideoGravity.resize
        
        player.play()
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { [weak self] _ in
            player.seek(to: CMTime.zero)
            player.play()
        }
        //player.play()
    }
    
    @IBAction func openWebSiteRoock(_ sender: Any) {
        if let url = URL(string: "https://rookmotion.com/aviso.html") {
            let svc = SFSafariViewController(url: url)
            present(svc, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func terminosSiteAction(_ sender: Any) {
        if let url = URL(string: "https://rookmotion.com/terminos.html") {
            let svc = SFSafariViewController(url: url)
            present(svc, animated: true, completion: nil)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
