import 'package:flutter/material.dart';

import '../models/worker.dart';

class ItemDetails extends StatefulWidget {
  final Worker worker;

  const ItemDetails({super.key, required this.worker});

  @override
  State<StatefulWidget> createState() => _ItemDetailsState();
}

class _ItemDetailsState extends State<ItemDetails> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> imagePaths = [
    'assets/funny1.jpg',
    'assets/funny2.jpg',
    'assets/funny3.jpg',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 300,
                  child: Stack(
                    children: [
                      PageView(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        children: imagePaths.map((path) {
                          return Image.asset(
                            path,
                            fit: BoxFit.cover,
                          );
                        }).toList(),
                      ),
                      Positioned(
                        bottom: 16.0,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: _buildPageIndicator(),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Text(
                            "About",
                            style: TextStyle(fontSize: 24),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              child: Text(
                                softWrap: true,
                                widget.worker.toString(),
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Text(
                            "Service providers",
                            style: TextStyle(fontSize: 24),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Card(
                        elevation: 3,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Image.asset(
                                'assets/funny1.jpg',
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 5),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("John Doe", style: TextStyle(fontSize: 16)),
                                        Text("Off 15%", style: TextStyle(fontSize: 12, color: Color(0xFFfd6b6d))),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(top: 20),
                                          decoration: BoxDecoration(
                                            color: Color(0xFFfef9e4),
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(5),
                                            child: Row(
                                              children: [
                                                Icon(Icons.star, color: Color(0xFFe8bc23), size: 15),
                                                SizedBox(width: 3),
                                                Text("4.1")
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                        Container(
                                          margin: EdgeInsets.only(top: 20),
                                          decoration: BoxDecoration(
                                            color: Color(0xFFf0edfb),
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(5),
                                            child: Row(
                                              children: [
                                                Icon(Icons.attach_money_outlined, color: Color(0xFF1a253f), size: 15),
                                                Text("10/h")
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Card(
                        elevation: 3,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Image.asset(
                                'assets/funny2.jpg',
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 5),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("John Doe", style: TextStyle(fontSize: 16)),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(top: 20),
                                          decoration: BoxDecoration(
                                            color: Color(0xFFfef9e4),
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(5),
                                            child: Row(
                                              children: [
                                                Icon(Icons.star, color: Color(0xFFe8bc23), size: 15),
                                                SizedBox(width: 3),
                                                Text("4.1")
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                        Container(
                                          margin: EdgeInsets.only(top: 20),
                                          decoration: BoxDecoration(
                                            color: Color(0xFFf0edfb),
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(5),
                                            child: Row(
                                              children: [
                                                Icon(Icons.attach_money_outlined, color: Color(0xFF1a253f), size: 15),
                                                Text("10/h")
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Card(
                        elevation: 3,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Image.asset(
                                'assets/funny3.jpg',
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 5),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("John Doe", style: TextStyle(fontSize: 16)),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(top: 20),
                                          decoration: BoxDecoration(
                                            color: Color(0xFFfef9e4),
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(5),
                                            child: Row(
                                              children: [
                                                Icon(Icons.star, color: Color(0xFFe8bc23), size: 15),
                                                SizedBox(width: 3),
                                                Text("4.1")
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                        Container(
                                          margin: EdgeInsets.only(top: 20),
                                          decoration: BoxDecoration(
                                            color: Color(0xFFf0edfb),
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(5),
                                            child: Row(
                                              children: [
                                                Icon(Icons.attach_money_outlined, color: Color(0xFF1a253f), size: 15),
                                                Text("10/h")
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Positioned(
            top: 50.0,
            left: 20.0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white, // Background color
                borderRadius: BorderRadius.circular(12.0), // Rounded corners
              ),
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back_ios_outlined, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < imagePaths.length; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: EdgeInsets.symmetric(horizontal: 3.0),
      height: 3.0,
      width: isActive ? 16.0 : 8.0,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.grey,
        borderRadius: BorderRadius.all(Radius.circular(0)),
      ),
    );
  }
}
