//
//  RecentImagesViewController.swift
//  Markdown
//
//  Created by 朱炳程 on 2019/11/10.
//  Copyright © 2019 zhubch. All rights reserved.
//

import UIKit
import Kingfisher

private let reuseIdentifier = "Cell"

class RecentImagesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var items = Configure.shared.recentImages
    
    var collectionView: UICollectionView!
    
    var didPickRecentImage: ((URL)->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = /"RecentUpload"
        
        let layout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { maker in
            maker.top.bottom.equalTo(0)
            maker.left.equalTo(2)
            maker.right.equalTo(-2)
        }
        collectionView.register(RecentImageCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.setBackgroundColor(.tableBackground)
        view.setBackgroundColor(.tableBackground)
        navBar?.setTintColor(.navTint)
        navBar?.setBackgroundColor(.navBar)
        navBar?.setTitleColor(.navTitle)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(close))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: /"Clear", style: .plain, target: self, action: #selector(clear))
    }
    
    @objc func close() {
        impactIfAllow()
        dismiss(animated: true, completion: nil)
    }
    
    @objc func clear() {
        impactIfAllow()
        showDestructiveAlert(title: nil, message: /"ClearMessage", actionTitle: /"Clear") {
            Configure.shared.recentImages.removeAll()
            self.items = []
            self.collectionView.reloadData()
            KingfisherManager.shared.cache.clearDiskCache()
            KingfisherManager.shared.cache.clearMemoryCache()
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! RecentImageCell
        cell.setBackgroundColor(.background)
        cell.imageView.kf.setImage(with: items[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = (view.w - 2 * 4) / 3
        let h = w
        return CGSize(width: w, height: h)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didPickRecentImage?(items[indexPath.item])
        dismiss(animated: true, completion: nil)
        impactIfAllow()
    }
}
