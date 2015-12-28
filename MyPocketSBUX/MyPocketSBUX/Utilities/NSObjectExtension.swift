//
//  NSObjectExtension.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/12/28.
//  Copyright © 2015年 Takashi Ikeda. All rights reserved.
//

import Foundation

extension NSObject {
    
    //
    // Retrieves an array of property names found on the current object
    // using Objective-C runtime functions for introspection:
    // https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html
    //
    func propertyNames() -> [String] {
        var results: [String] = [];
        
        // retrieve the properties via the class_copyPropertyList function
        var count: UInt32 = 0;
        let myClass: AnyClass = self.classForCoder;
        let properties = class_copyPropertyList(myClass, &count);
        
        // iterate each objc_property_t struct
        for var i: UInt32 = 0; i < count; i++ {
            let property = properties[Int(i)];
            
            // retrieve the property name by calling property_getName function
            let cname = property_getName(property);
            
            // covert the c string into a Swift string
            let name = String.fromCString(cname);
            results.append(name!);
        }
        
        // release objc_property_t structs
        free(properties);
        
        return results;
    }
    
    func propertyTypeName(propName: String) -> String {
        var propertyType = ""
        
        // retrieve the properties via the class_copyPropertyList function
        var count: UInt32 = 0;
        let myClass: AnyClass = self.classForCoder;
        let properties = class_copyPropertyList(myClass, &count);
        
        // iterate each objc_property_t struct
        for var i: UInt32 = 0; i < count; i++ {
            let property = properties[Int(i)];
            
            // retrieve the property name by calling property_getName function
            let cname = property_getName(property);
            
            // covert the c string into a Swift string
            let name = String.fromCString(cname);
            if name == propName {
                let cpropName = property_getAttributes(property)
                propertyType = String.fromCString(cpropName)!
                break
            }
        }
        
        // release objc_property_t structs
        free(properties);
        
        return propertyType
        
    }
    
    // TODO: NSManagedObjectだとうまく機能しない
    //    func typeFromPropertyName(propName : String) -> Any? {
    //        let mirror = Mirror(reflecting: self)
    //        for child in mirror.children {
    //            if child.label! == propName {
    //                return child.value.dynamicType
    //            }
    //        }
    ////        for case let (label?, value) in mirror.children {
    ////            if label == propName {
    ////                return value
    ////            }
    ////        }
    ////        let type = mirror.children.filter { (prop: (label: String?, value: Any)) -> Bool in
    ////            return prop.label == propName
    ////        }.first?.value
    //
    //        return nil
    //    }
    
}

import CoreData
extension NSManagedObject {
    // リレーションのオブジェクトの型がうまいこと取れない
    //    func typeFromPropertyName(propName : String) -> Any? {
    //        if let desc = self.entity.attributesByName[propName] {
    //            print(desc.attributeType)
    //            if let propValueClassName = desc.attributeValueClassName {
    //                return NSClassFromString(propValueClassName) as! NSObject.Type
    //            }
    //        }
    //
    //        return nil
    //    }
    
    // リレーションに設定されていれば、NSManagedObjectとする（リレーションが張られていない場合もあるが…）
    func isPropertyTypeNSManagedObject(propName : String) -> Bool {
        return self.entity.relationshipsByName[propName] != nil
    }
}