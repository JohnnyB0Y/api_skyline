//  data_list.dart
//  demo
//
//  Created by JohnnyB0Y on 12/9/20.
//  Copyright © 2020 JohnnyB0Y. All rights reserved.

//  

import 'package:api_skyline/api_skyline.dart';
import 'package:demo/case_network_data/services/api_hubs.dart';
import 'package:flutter/material.dart';

class ItemListPage extends StatefulWidget {
  @override
  _ItemListPageState createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage> {

  final _model = ReactModel();
  final _itemAPIHub = ItemAPIHub();

  Map<String, Object> _onApiCallParams(APIManager manager) {
    // 请求参数
    var params = {};
    if (manager == _itemAPIHub.item) {
      params["param1"] = "1";
    }
    else if (manager == _itemAPIHub.itemList) {
      params["param2"] = "2";
    }
    return params;
  }

  _onApiCallSuccess(APIManager manager) {
    // 请求成功回调
    if (manager == _itemAPIHub.item) {

    }
    else if (manager == _itemAPIHub.itemList) {

    }

  }

  onApiCallFailure(APIManager manager) {
    // 请求失败回调
    if (manager == _itemAPIHub.item) {

    }
    else if (manager == _itemAPIHub.itemList) {

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("网络请求骨架"),
      ),
      body: ReactWidget.apiHub(
        apiHubs: [_itemAPIHub],
        onApiCallParams: _onApiCallParams,
        onApiCallSuccess: _onApiCallSuccess,
        onApiCallFailure: _onApiCallSuccess,
        builder: (ctx, params, child) {
          return Text("item");
        },
        binding: _model,
      ),
    );
  }
}

