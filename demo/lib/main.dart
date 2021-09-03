import 'package:api_skyline/api_skyline.dart';
import 'package:demo/case_increment/pages/increment.dart';
import 'package:demo/case_network_data/pages/data_list.dart';
import 'package:demo/network_request/demo_service.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skyline Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Skyline Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  final items = [
    ReactModel({
      RMK.title: "Skyline版 计数器",
    }),
    ReactModel({
      RMK.title: "Skyline版 网络请求",
    }),

  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // 注册网络库
    DemoAPIService().registerForDefault();
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? "Demo"),
      ),
      
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {

          var rm = items[index];

          return ListTile(
            title: Text('${rm.strVal(RMK.title)}'),
            onTap: () {

              Widget nextPage;
              if (index == 0) {
                nextPage = IncrementPage();
              }
              else {
                nextPage = ItemListPage();
              }

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => nextPage),
              );
            },
          );
        },
      ),
    );
  }
}
