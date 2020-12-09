//  increment.dart
//  demo
//
//  Created by JohnnyB0Y on 12/9/20.
//  Copyright © 2020 JohnnyB0Y. All rights reserved.

//  

import 'package:flutter/material.dart';
import 'package:api_skyline/api_skyline.dart';

class IncrementPage extends StatelessWidget {

  static final counterKey = "counter_key";

  final _model = ReactModel({
    counterKey: 0,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("模型刷新UI"),
      ),
      body: ReactWidget.binding(builder: (ctx, params, child) {

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'You have pushed the button this many times:',
              ),
              Text(
                '${_model.numVal(counterKey)}',
                style: Theme.of(context).textTheme.headline4,
              ),
            ],
          ),
        );
      }, binding: _model),

      floatingActionButton: FloatingActionButton(
        onPressed:() {
          _model.refreshUIByUpdateModel((model) => {
            model.increaseNum(2, counterKey)
          });
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );

  }
}

