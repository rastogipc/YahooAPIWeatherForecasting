//
//  APIHandler.swift
//  WeatherFinder
//
//  Created by Prakash Kumar Rastogi on 05/09/18.
//  Copyright © 2018 Futuremind Technology Solutions. All rights reserved.
//

import Foundation
import Alamofire
import MapKit

typealias ServiceResponse = (Any?, Error?, Bool) -> Void

protocol APICompletionHandlerProtocol {
    func apiCallFinish(data : Dictionary<String, Any>?, success : Bool, error : Error?)
}

class APIHandler: NSObject {
    
    static let SharedManager = APIHandler()
    
    var yqlObj:YQL?
    
    var delegate : APICompletionHandlerProtocol!
    
    override init() {
        super.init()
        if self.yqlObj == nil {
            self.yqlObj = YQL.init()
        }
    }
    
    func getWeatherInfoAtLocation(_ selectecLocation:CLLocationCoordinate2D, _ completion: @escaping ServiceResponse) -> Void{
        
        let latlongString = String(format: "(%f,%f)", selectecLocation.latitude,selectecLocation.longitude)
        let queryURL = self.yqlObj?.prepareUrl(forQuery: latlongString)
        if let queryObj = queryURL{
            print("Query URL = %@",queryObj)
            Alamofire.request(queryObj).responseJSON { response in
                debugPrint(response)
                switch response.result {
                case .success:
                    print("Validation Successful")
                    let jsonReponseObj = response.result.value as? Dictionary<String,Any>
                    if let jsonDict = jsonReponseObj {
                        print("JSON: \(jsonDict)")
                        let resultDict = self.yqlObj?.getResultForResponseDict(jsonDict) as! Dictionary<String, Any>
                        if resultDict.isEmpty == false {
                            completion(resultDict, nil, true)
                        }else{
                            completion(nil, nil, false)
                        }
                    }else{
                        completion(nil, nil, false)
                    }
                case .failure(let error):
                    print(error)
                    completion(nil, error, false)
                }
            }
        }
        
    }
    
}
