import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'custom_app_bar.dart';
import 'custom_shape_clipper.dart';
import 'flight_listing.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cached_network_image/cached_network_image.dart';

Future<void> main() async {
  final FirebaseApp app = await FirebaseApp.configure(
      name: "flutter-flight-tickets",
      options: const FirebaseOptions(
          googleAppID: "1:819031335006:android:cff97fcb54784160",
          apiKey: 'AIzaSyBxjGinfVC_sCA1rUZ_0UCntEDsp2ziBKw',
          databaseURL: "https://flutter-flight-tickets.firebaseio.com/"));

  runApp(MaterialApp(
    theme: appTheme,
    title: 'Flutter Demo',
    debugShowCheckedModeBanner: false,
    home: HomeScreen(),
  ));
}

Color firstColor = Color(0xFFF47D15);
Color secondColor = Color(0xFFEF772C);

ThemeData appTheme = ThemeData(
    primaryColor: Color(0xFFF3791A),
    fontFamily: 'Oxygen',
    platform: TargetPlatform.iOS);

List<String> locations = List();

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            HomeScreenTopPart(),
            homeScreenBottomPart,
            homeScreenBottomPart
          ],
        ),
      ),
    );
  }
}

const TextStyle dropDownLabelStyle =
    TextStyle(color: Colors.white, fontSize: 16);
const TextStyle dropDownMenuItemStyle =
    TextStyle(color: Colors.black, fontSize: 16);

final _searchFieldController = TextEditingController();

class HomeScreenTopPart extends StatefulWidget {
  @override
  _HomeScreenTopPartState createState() => _HomeScreenTopPartState();
}

class _HomeScreenTopPartState extends State<HomeScreenTopPart> {
  var selectedLocationIndex = 0;
  var isFlightSelected = true;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        ClipPath(
          clipper: CustomShapeClipper(),
          child: Container(
            height: 340.0,
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [firstColor, secondColor])),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 40.0,
                ),
                StreamBuilder(
                  stream:
                      Firestore.instance.collection("locations").snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData)
                      addLocations(context, snapshot.data.documents);
                    return !snapshot.hasData
                        ? Container()
                        : Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: 16.0,
                                ),
                                PopupMenuButton(
                                  onSelected: (index) {
                                    setState(() {
                                      selectedLocationIndex = index;
                                    });
                                  },
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        locations[selectedLocationIndex],
                                        style: dropDownLabelStyle,
                                      ),
                                      Icon(
                                        Icons.keyboard_arrow_down,
                                        color: Colors.white,
                                      )
                                    ],
                                  ),
                                  itemBuilder: (context) => _buildPopupMenuItem()
                                ),
                                Spacer(),
                                Icon(
                                  Icons.settings,
                                  color: Colors.white,
                                )
                              ],
                            ),
                          );
                  },
                ),
                SizedBox(
                  height: 20.0,
                ),
                Text(
                  "Where would\nyou want to go?",
                  style: TextStyle(
                      fontSize: 22.0,
                      color: Colors.white,
                      fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Material(
                    elevation: 5,
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    child: TextField(
                      controller: _searchFieldController,
                      style: dropDownMenuItemStyle,
                      cursorColor: appTheme.primaryColor,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 32.0, vertical: 14.0),
                          suffixIcon: Material(
                            elevation: 2.0,
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            InheritedFlightListing(
                                              fromLocation: locations[
                                                  selectedLocationIndex],
                                              toLocation:
                                                  _searchFieldController.text,
                                              child: FlightListing(),
                                            )));
                              },
                              child: Icon(
                                Icons.search,
                                color: Colors.black,
                              ),
                            ),
                          )),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        setState(() {
                          isFlightSelected = true;
                        });
                      },
                      child: ChoiceChip(
                          Icons.flight_takeoff, "Flights", isFlightSelected),
                    ),
                    InkWell(
                        onTap: () {
                          setState(() {
                            isFlightSelected = false;
                          });
                        },
                        child: ChoiceChip(
                            Icons.hotel, "Hotels", !isFlightSelected))
                  ],
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  void addLocations(BuildContext context, List<DocumentSnapshot> snapshots) {
    for (int i = 0; i < snapshots.length; i++) {
      final Location location = Location.fromSnapshot(snapshots[i]);
      locations.add(location.name);
    }
  }
}

List<PopupMenuItem<int>> _buildPopupMenuItem() {
  List<PopupMenuItem<int>> popupMenuItems = List();
  for (int i = 0; i < locations.length; i++) {
    popupMenuItems.add(
      PopupMenuItem(
        child: Text(
          locations[i],
          style: dropDownMenuItemStyle,
        ),
        value: i,
      ),
    );
  }

  return popupMenuItems;
}

class ChoiceChip extends StatefulWidget {
  final IconData icon;
  final String text;
  final bool isFlightSelected;

  ChoiceChip(this.icon, this.text, this.isFlightSelected);

  @override
  _ChoiceChipState createState() => _ChoiceChipState();
}

class _ChoiceChipState extends State<ChoiceChip> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
      decoration: widget.isFlightSelected
          ? BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.all(Radius.circular(20.0)))
          : null,
      child: Row(
        children: <Widget>[
          Icon(
            widget.icon,
            size: 18.0,
            color: Colors.white,
          ),
          SizedBox(
            width: 4.0,
          ),
          Text(
            widget.text,
            style: TextStyle(color: Colors.white, fontSize: 14),
          )
        ],
      ),
    );
  }
}

var viewAllStyle = TextStyle(fontSize: 14, color: appTheme.primaryColor);

var homeScreenBottomPart = Container(
    child: Column(
  children: <Widget>[
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            "Currently Whatched Items",
            style: dropDownMenuItemStyle,
          ),
          Text(
            "VIEW ALL(12)",
            style: viewAllStyle,
          ),
        ],
      ),
    ),
    Container(
        height: 240,
        child: StreamBuilder(
          stream: Firestore.instance
              .collection("cities")
              .orderBy("newPrice")
              .snapshots(),
          builder: (context, snapshot) {
            return !snapshot.hasData
                ? CircularProgressIndicator()
                : _buildCitiesList(context, snapshot.data.documents);
          },
        ))
  ],
));

Widget _buildCitiesList(
    BuildContext context, List<DocumentSnapshot> snapshots) {
  return ListView.builder(
    shrinkWrap: true,
    physics: ClampingScrollPhysics(),
    scrollDirection: Axis.horizontal,
    itemCount: snapshots.length,
    itemBuilder: (context, index) {
      return CityCard(
        city: City.fromSnapshot(snapshots[index]),
      );
    },
  );
}

class Location {
  final String name;

  Location.fromMap(Map<String, dynamic> map)
      : assert(map['name'] != null),
        name = map['name'];

  Location.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data);
}

class City {
  final String imagePath, cityName, monthYear, discount;
  final int oldPrice, newPrice;

  City.fromMap(Map<String, dynamic> map)
      : assert(map['cityName'] != null),
        assert(map['monthYear'] != null),
        assert(map['discount'] != null),
        assert(map['imagePath'] != null),
        imagePath = map['imagePath'],
        cityName = map['cityName'],
        monthYear = map['monthYear'],
        discount = map['discount'],
        oldPrice = map['oldPrice'],
        newPrice = map['newPrice'];

  City.fromSnapshot(DocumentSnapshot snapshot) : this.fromMap(snapshot.data);
}

final formatCurrency = new NumberFormat.simpleCurrency();

class CityCard extends StatelessWidget {
  final City city;

  CityCard({this.city});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            child: Stack(
              children: <Widget>[
                Container(
                    height: 200.0,
                    width: 150,
                    child: CachedNetworkImage(
                      imageUrl: '${city.imagePath}',
                      fit: BoxFit.cover,
                      fadeInDuration: Duration(milliseconds: 2000),
                      fadeInCurve: Curves.easeIn,
                    )),
                Positioned(
                  left: 0,
                  bottom: 0,
                  width: 150,
                  height: 50,
                  child: Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [
                          Colors.black,
                          Colors.black.withOpacity(0.0)
                        ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter)),
                  ),
                ),
                Positioned(
                  left: 8,
                  bottom: 8,
                  right: 8.0,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            city.cityName,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 16.0),
                          ),
                          Text(
                            city.monthYear,
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Colors.white,
                                fontSize: 12.0),
                          )
                        ],
                      ),
                      Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.0, vertical: 2.0),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.rectangle,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          child: Text(
                            "${city.discount}%",
                            style:
                                TextStyle(fontSize: 14.0, color: Colors.black),
                          ))
                    ],
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 5,
              ),
              Text(
                '${formatCurrency.format(city.newPrice)}',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                '(${formatCurrency.format(city.oldPrice)})',
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    decoration: TextDecoration.lineThrough),
              )
            ],
          )
        ],
      ),
    );
  }
}
