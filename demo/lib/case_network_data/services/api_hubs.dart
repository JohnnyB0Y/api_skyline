//  api_hubs.dart
//  demo
//
//  Created by JohnnyB0Y on 12/9/20.
//  Copyright © 2020 JohnnyB0Y. All rights reserved.

//  

import 'package:api_skyline/api_skyline.dart';
import 'package:demo/network_request/api/item.dart';

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
