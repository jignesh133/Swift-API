//
//  ViewController.swift
//  D-War
//
//  Created by MCA 2 on 06/12/18.
//  Copyright © 2018 stratecore. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire

class HomeViewController: UIViewController {

    // DECLARE VARIABLE
    @IBOutlet var myMapView: GMSMapView!
    @IBOutlet var subCategoryClView: UICollectionView!
    @IBOutlet var storeClView: UICollectionView!
    @IBOutlet var buttonCategory: UIButton!
    @IBOutlet var corosalView:iCarousel!
    
    @IBOutlet var corosalItem:UIView!

    var locationManager = CLLocationManager()
    var latitude: CLLocationDegrees = 0.0
    var longitude: CLLocationDegrees = 0.0
    var markerList:[GMSMarker] = [GMSMarker]()
    var arrCategory:[Model_Category] = [Model_Category]()
    var arrSubcategory:[Model_Subcategory] = [Model_Subcategory]()
    var arrStores:[Model_store] = [Model_store]()
    
    var selectedCategory:Model_Category?
    var selectedSubCategory:Model_Subcategory?
    var selectedStore:Model_store?
    var bounds = GMSCoordinateBounds()
    var corosolIndex = 0
    
    //init ViewController
    class func initViewController() -> HomeViewController? {
        let viewController:HomeViewController = STORYBOARD_MAIN.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        return viewController
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupMap()
        corosalView.type = .linear
        corosalView.isPagingEnabled = true;
        do {
            if let styleURL = Bundle.main.url(forResource: "map_style", withExtension: "json") {
                myMapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                print("Unable to find map_style.json")
            }
        } catch {
            print("One or more of the map styles failed to load. \(error)")
        }
        
        self.corosalView.delegate=self
        self.corosalView.dataSource=self
        self.setuplocation()
        self.methodGetCategoryData()
    }
    override func viewDidAppear(_ animated: Bool) {
    
    }
    // MARK:- API METHODS
    func methodGetStoreData(){

        appDelegate?.startLoadingview()
        var param:[String:Any] = [String:Any]()
        param["action"] = "getStoreList"
        if selectedSubCategory == nil{
            param["cat_id"] = selectedCategory?.catId
        }else {
            param["subcat_id"] = selectedSubCategory?.subcatId
        }
        Alamofire.request(BASEAPI, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil)
            .responseJSON(completionHandler: { (response) in
                appDelegate?.stopLoadingView()
                if(response.result.isSuccess){
                    let response = response.result.value as? [String:Any]
                    let data = response?["storelist"]
                    self.arrStores = try! JSONDecoder().decode([Model_store].self, from: jsonToData(json: data ?? []) ?? Data.init())
                    self.methodShowOnMapData()
                    self.corosalView.reloadData()
                }else{
                    print("NO response found")
                }
            })
    }
    
    func methodGetCategoryData(){
        appDelegate?.startLoadingview()
        
        var param:[String:Any] = [String:Any]()
        param["action"] = "getCategoryAndSubcategory"
        
        Alamofire.request(BASEAPI, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil)
            .responseJSON(completionHandler: { (response) in
                if(response.result.isSuccess){
                    appDelegate?.stopLoadingView()
                    let response = response.result.value as? [String:Any]
                    let data = response?["data"]
                    self.arrCategory = try! JSONDecoder().decode([Model_Category].self, from: jsonToData(json: data ?? []) ?? Data.init())
                    // RELOAD DATA
                    self.subCategoryClView.reloadData()
                    
                    self.methodGetStoreData()
                }else{
                    print("NO response found")
                     appDelegate?.stopLoadingView()
                }
            })
    }
 
    // MARK:- CUSTOM METHODS
    func setupMap(){
        let camera = GMSCameraPosition.camera(withLatitude: 24.4539 , longitude: 54.3773, zoom: 15)
        myMapView.camera = camera
        myMapView.delegate = self
    }
    func methodShowOnMapData(){
        bounds = GMSCoordinateBounds()
        self.myMapView.clear()
        var index:Int = 0
        for data in arrStores {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: getDoubleFromAny(data.storeLatitude), longitude: getDoubleFromAny(data.storeLongitude))
            if (index == corosolIndex){
                   marker.icon =  #imageLiteral(resourceName: "biPin")
            } else{
                marker.icon =  #imageLiteral(resourceName: "smallPin")
            }
            marker.title = data.storeName
            marker.snippet = data.storeAddress
            bounds = bounds.includingCoordinate(marker.position)
            marker.map = self.myMapView
            self.markerList.append(marker)
            index = index + 1
        }
        DispatchQueue.main.async {
            let update = GMSCameraUpdate.fit(self.bounds, withPadding: 100)
            self.myMapView.setMinZoom(0, maxZoom: 12)
            self.myMapView.animate(with: update)
    
            if self.markerList.count > 0{
                let marker = self.markerList[self.corosolIndex]
                self.myMapView.animate(toLocation: CLLocationCoordinate2D(latitude: marker.position.latitude, longitude: marker.position.longitude))
            }
        }
    }
    func setuplocation(){
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    //MARK: ACTIN METHODS
    @IBAction func buttonCategoryClicked(_ sender: Any) {
        let controller = SelectCategoryVC.initViewController()!
        controller.delegate = self
        controller.arrCategory = arrCategory
        let navController = UINavigationController(rootViewController: controller)
        self.present(navController, animated:true, completion: nil)
    }
    
    
}
// MARK: GMSMapViewDelegate
extension HomeViewController:GMSMapViewDelegate{
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        return true
    }
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
    }
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
    }
}
// MARK: CLLocationManagerDelegate
extension HomeViewController:CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.setupMap()
        //self.latitude = (manager.location?.coordinate.latitude) ?? 0.0
        //self.longitude = (manager.location?.coordinate.longitude) ?? 0.0
//        if (self.latitude == 0 && self.longitude == 0){
//            self.locationManager.requestLocation()
//        }else{
//            self.setupMap()
//        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
}
// MARK: UICollectionViewDelegate
extension HomeViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if  collectionView == subCategoryClView {
            return arrSubcategory.count
        }else{
            return arrStores.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if  collectionView == subCategoryClView {
            // FONT
            let font = appDelegate?.setTheFontSize(UIFont.init(name: Montserrat_Medium, size:   13.3)!, valueFontSizeForX: 13.3)
            let strWidth = self.arrSubcategory[indexPath.row].subcatName.width(withConstrainedHeight: 1000.0, font: font!)
            return CGSize(width: max(strWidth + 16, 50), height: 44)
        }else{
            return CGSize(width: 210, height: 200)
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == subCategoryClView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "subCategoryCell", for: indexPath) as! subCategoryCell
            cell.labelName.text = arrSubcategory[indexPath.row].subcatName.capitalized
            cell.labelName.methodSetFontsForAll(val: 13.3)
            if selectedSubCategory == nil && indexPath.item == 0{
                cell.labelName.textColor = UIColor().appYelloColor()
                cell.imgViewBox.image = #imageLiteral(resourceName: "box_selected")
            }
            else if selectedSubCategory?.subcatId == arrSubcategory[indexPath.row].subcatId{
                cell.labelName.textColor = UIColor().appYelloColor()
                cell.imgViewBox.image = #imageLiteral(resourceName: "box_selected")
            }else{
                cell.labelName.textColor = UIColor.black
                cell.imgViewBox.image =  #imageLiteral(resourceName: "box_unselected")
            }
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "storeItemCell", for: indexPath) as! storeItemCell
            cell.methodSetRatingColor(borderColor: UIColor.black)
            cell.labelRating.text = arrStores[indexPath.row].storeTotalRating
            cell.labelName.text = arrStores[indexPath.row].storeName.capitalized
            cell.labelSubName.text = arrStores[indexPath.row].storeAddress
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == storeClView{
            let controller:DetailsViewController = DetailsViewController.initViewController()!
            controller.selectedStore = arrStores[indexPath.item]
            self.navigationController?.pushViewController(controller, animated: true)
        }else{
            if indexPath.item == 0{
                    selectedSubCategory = nil
            }else{
                  selectedSubCategory = arrSubcategory[indexPath.item]
            }
             subCategoryClView.reloadData()
             self.methodGetStoreData()
        }
    }
}
extension HomeViewController:selectCategoryProtocol{

    func methodSelectedCategory(selectedModel: Model_Category) {
        selectedCategory = selectedModel

        arrSubcategory.removeAll()
        arrSubcategory = selectedModel.subcategory

        var json:[String:Any] = [String:Any]()
        json["cat_id"] = "0"
        json["subcat_id"] = "0"
        json["subcat_name"] = "All"
        arrSubcategory.insert(Model_Subcategory.init(json), at: 0)
        buttonCategory.setTitle(selectedCategory?.catName.capitalized, for: .normal)

        selectedSubCategory = nil
        self.subCategoryClView.reloadData()
        self.methodGetStoreData()
    }
}

class subCategoryCell: UICollectionViewCell {
   
    // DECLARE VAR
    @IBOutlet var labelName:UILabel!
    @IBOutlet var imgViewBox:UIImageView!

    override func awakeFromNib() {
        
    }
}
class storeItemCell: UICollectionViewCell {
    // DECLARE VAR
    @IBOutlet var labelName:UILabel!
    @IBOutlet var labelDistance :UILabel!
    @IBOutlet var labelSubName:UILabel!
    @IBOutlet var labelRating:UILabel!
    @IBOutlet var imageViewLogo:UIImageView!
    @IBOutlet var viewBg: UIView!
    
    override func awakeFromNib() {
      self.imageViewLogo.layer.cornerRadius = 15
      self.imageViewLogo.layer.masksToBounds = true
      self.imageViewLogo.clipsToBounds = true
    }
    func methodSetRatingColor(borderColor:UIColor){
        self.labelRating.layer.cornerRadius = 4
        self.labelRating.layer.borderColor = borderColor.cgColor
        self.labelRating.layer.borderWidth = 1.0
    }
}

extension HomeViewController:iCarouselDataSource,iCarouselDelegate{

    func numberOfItems(in carousel: iCarousel) -> Int {
        return arrStores.count
    }
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        let corosalItem = Bundle.main.loadNibNamed("corosolView", owner: nil, options: nil)![0] as! corosolView
        corosalItem.methodSetRatingColor(borderColor: UIColor.black)
        corosalItem.labelRating.text = arrStores[index].storeTotalRating
        corosalItem.labelName.text = arrStores[index].storeName.capitalized
        corosalItem.labelSubName.text = arrStores[index].storeAddress
        let arrIamges = arrStores[index].storePhotos.components(separatedBy: ",")
        if (arrIamges.count > 0){
            corosalItem.imageViewLogo.loadImageFromServer(imgPath: arrIamges.first ?? "")
        }
        if(arrStores[index].storeTotalRating.isEmpty){
            corosalItem.labelRating.text = "0"
        }
        return corosalItem
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        return value * 1.05; 
    }
    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
        let controller:DetailsViewController = DetailsViewController.initViewController()!
        controller.selectedStore = arrStores[index]
        self.navigationController?.pushViewController(controller, animated: true)
    }
    func carouselCurrentItemIndexDidChange(_ carousel: iCarousel) {
        if (corosalView.currentItemIndex >= 0 && corosalView.currentItemIndex < self.markerList.count){
            print(corosalView.currentItemIndex)
            corosolIndex = corosalView.currentItemIndex
            self.methodShowOnMapData()
        }
    }
    func carouselDidEndDragging(_ carousel: iCarousel, willDecelerate decelerate: Bool) {

    }

}

