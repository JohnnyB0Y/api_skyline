//  api_hubs.dart
//  demo
//
//  Created by JohnnyB0Y on 12/9/20.
//  Copyright © 2020 JohnnyB0Y. All rights reserved.

//  

import 'package:api_skyline/api_skyline.dart';
import 'package:demo/network_request/api/item.dart';
import 'package:demo/network_request/api/serial.dart';

class ItemAPIHub extends APIHub {

  // item list api manager
  ItemListAPIManager _itemList;
  ItemListAPIManager get itemList {
    if (_itemList == null) {
      _itemList = ItemListAPIManager();
      _itemList.callDelegate = callDelegate;
    }
    return _itemList;
  }

  // item api manager
  ItemAPIManager _item;
  ItemAPIManager get item {
    if (_item == null) {
      _item = ItemAPIManager();
      _item.callDelegate = callDelegate;
    }
    return _item;
  }

}

class DependAPIHub extends APIHub {
  //  有前后依赖的API

  Depend1APIManager _depend1;
  Depend1APIManager get depend1 {
    if (_depend1 == null) {
      _depend1 = Depend1APIManager();
      _depend1.callDelegate = callDelegate;
    }
    return _depend1;
  }

  Depend2APIManager _depend2;
  Depend2APIManager get depend2 {
    if (_depend2 == null) {
      _depend2 = Depend2APIManager();
      _depend2.callDelegate = callDelegate;
    }
    return _depend2;
  }

  Depend3APIManager _depend3;
  Depend3APIManager get depend3 {
    if (_depend3 == null) {
      _depend3 = Depend3APIManager();
      _depend3.callDelegate = callDelegate;
    }
    return _depend3;
  }

  FinalAPIManager _final;
  FinalAPIManager get finalAPI {
    if (_final == null) {
      _final = FinalAPIManager();
      _final.callDelegate = callDelegate;
    }
    return _final;
  }

}
