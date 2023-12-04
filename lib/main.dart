import 'dart:convert';

import 'package:bitcoin_app_repo/core/size_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyHomePage(),
  ));
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _bitcoinRate = "Price";
  bool isLoaderShow = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchBitcoinPrice(); //Call api function
  }

  List<Map<String, dynamic>> bpiLists = []; // Access list

  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        backgroundColor:const Color(0xFF009973),
        body: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                getTopBarLayout(
                    SizeConfig.screenHeight, SizeConfig.screenWidth),
                getCupertinoLayout(
                    SizeConfig.screenHeight, SizeConfig.screenWidth),
              ],
            ),
            Positioned.fill(child: CommonWidget.isLoader(isLoaderShow)),
          ],
        ));
  }

  Widget getTopBarLayout(double parentHeight, double parentWidth) {
    return Padding(
      padding: EdgeInsets.only(top: parentHeight * .06),
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: parentHeight * .20,
              width: parentHeight * .20,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage('assets/images/bitcoin_logo.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: parentHeight * .04),
                child: Center(
                  child: Text(
                    _bitcoinRate,
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: SizeConfig.blockSizeVertical * 6,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          ],
        )
      ]),
    );
  }

  Widget getCupertinoLayout(double parentHeight, double parentWidth) {
    return Container(
      width: double.infinity,
      height: parentHeight*.3,
      child: CupertinoPicker(
        backgroundColor: const Color(0xFF009973),
        itemExtent: 30,
        scrollController: FixedExtentScrollController(initialItem: 0),
        children: List.generate(
          bpiLists.length,
          (index) => Center(
            child: Text(
              bpiLists[index]['code'],
              style: TextStyle(fontSize: 20.0),
            ),
          ),
        ),
        onSelectedItemChanged: (int value) {
          setState(() {
            _bitcoinRate = bpiLists[value]['rate'];
          });
        },
      ),
    );
  }

  // Function to fetch data
  fetchBitcoinPrice() async {
    setState(() {
      isLoaderShow = true;//Loader function true
    });
    final response = await http.get(Uri.parse('https://api.coindesk.com/v1/bpi/currentprice.json'));
    if (response.statusCode == 200) {
      // Parse the JSON string into a Dart object
      Map<String, dynamic> jsonDataMap = json.decode(response.body);

      // Extract the 'bpi' data from the Dart object
      Map<String, dynamic> bpiData = jsonDataMap['bpi'];

      // List<Map<String, dynamic>> bpiList = bpiData.values.toList();
      List<Map<String, dynamic>> bpiList =
          bpiData.values.map((value) => value as Map<String, dynamic>).toList();
      setState(() {
        bpiLists = bpiList;
        isLoaderShow = false;// Loader function false
      });

      // Print the resulting list
      print("bpiList    $bpiList   $bpiLists");
    } else {
      setState(() {
        isLoaderShow = false;
      });
      throw Exception('Failed to load Bitcoin price');
    }
  }
}

class CommonWidget {
  static isLoader(bool isLoaderShows) {
    return Visibility(
      visible: isLoaderShows,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 800,
            width: 800,
            color: Colors.transparent,
          ),
          Padding(
            padding: const EdgeInsets.all(140.0),
            child: Container(
              height: 80,
              width: 80,
              decoration: const BoxDecoration(
                color: Colors.transparent,
                image: DecorationImage(
                  image: AssetImage("assets/images/rounded_blocks.gif"),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
