//
//  HomeViewController.swift
//  PersonRez
//
//  Created by Hồ Sĩ Tuấn on 09/09/2020.
//  Copyright © 2020 Hồ Sĩ Tuấn. All rights reserved.
//

import UIKit
import AVFoundation
import RealmSwift
import ProgressHUD

class HomeViewController: UIViewController {
    @IBOutlet weak var finalFrame: UIImageView!

    private var generator:AVAssetImageGenerator!
    
    @IBOutlet weak var vectorsLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        if !NetworkChecker.isConnectedToInternet {
            showDialog(message: "You have not connected to internet. Using local data.")
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true

    }
    override func viewDidAppear(_ animated: Bool) {
        fnet.clean()
        loadData()
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated);
        super.viewWillDisappear(animated)
        fnet.load()
    }
    
    @IBAction func tapStart(_ sender: UIButton) {
        self.performSegue(withIdentifier: "startPredict", sender: nil)
    }
    @IBAction func tapPredictImage(_ sender: UIButton) {
        self.performSegue(withIdentifier: "openPredictImage", sender: nil)
    }
    @IBAction func tapAddUser(_ sender: UIButton) {
        self.performSegue(withIdentifier: "openAddUser", sender: nil)
    }
    @IBAction func tapViewData(_ sender: UIButton) {
        self.performSegue(withIdentifier: "viewFace", sender: nil)
    }
    @IBAction func tapViewLog(_ sender: UIButton) {
        self.performSegue(withIdentifier: "viewLog", sender: nil)
    }
    @IBAction func tapSyncData(_ sender: UIButton) {
        //loadData()
        kMeanVectors.append(contentsOf: kMeanVectors)
        kMeanVectors.append(contentsOf: kMeanVectors)
        if !NetworkChecker.isConnectedToInternet {
            showDialog(message: "You have not connected to internet. Using local data.")
        }
    }
    
    func loadData() {
        if NetworkChecker.isConnectedToInternet {
            ProgressHUD.show("Loading users...")
            fb.loadVector { [self] (result) in
                kMeanVectors = result
                print("Number of k-Means vectors: \(kMeanVectors.count)")
                vectorsLabel.text = "You have \(kMeanVectors.count / NUMBER_OF_K) users."
                ProgressHUD.dismiss()
                try! realm.write {
                    realm.deleteAll()
                }
                for vector in kMeanVectors {
                    vectorHelper.saveVector(vector)
                }
            }
            fb.loadLogTimes { (result) in
                attendList = result
                for user in attendList {
                    let u = User(name: user.name, image: UIImage(named: "LaunchImage")!, time: user.time)
                    localUserList.append(u)
                }
            }
        }
        else {
            //code for local data
            let result = realm.objects(SavedVector.self)
            print(result.count)
            kMeanVectors = []
            for vector in result {
                let v = Vector(name: vector.name, vector: stringToArray(string: vector.vector), distance: vector.distance)
                kMeanVectors.append(v)
            }
            vectorsLabel.text = "You have \(kMeanVectors.count / NUMBER_OF_K) users."
        }
    }
    
}

