import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'custom_shape_clipper.dart';
import 'main.dart';

final Color discountBackgroundColor = Color(0xFFFFE08D);
final Color flightBorderColor = Color(0xFFE6E6E6);
final Color chipBackgroundColor = Color(0xFFF6F6F6);

class InheritedFlightListing extends InheritedWidget {
  final String toLocation, fromLocation;

  InheritedFlightListing({this.fromLocation, this.toLocation, Widget child})
      : super(child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }

  static InheritedFlightListing of(BuildContext context) =>
      context.inheritFromWidgetOfExactType(InheritedFlightListing);
}

class FlightListing extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: appTheme.primaryColor,
        title: Text("Search Result"),
        centerTitle: true,
        leading: InkWell(
          child: Icon(Icons.arrow_back),
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            FlightListTopPart(),
            SizedBox(
              height: 20.0,
            ),
            FlightListBottomPart()
          ],
        ),
      ),
    );
  }
}

class FlightListTopPart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        ClipPath(
          clipper: CustomShapeClipper(),
          child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [firstColor, secondColor])),
            height: 160.0,
          ),
        ),
        Column(
          children: <Widget>[
            SizedBox(
              height: 30.0,
            ),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              margin: EdgeInsets.symmetric(horizontal: 16),
              elevation: 10.0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 22),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Expanded(
                      flex: 5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "${InheritedFlightListing.of(context).fromLocation}",
                            style: TextStyle(fontSize: 16),
                          ),
                          Divider(
                            color: Colors.grey,
                            height: 20,
                          ),
                          Text(
                            "${InheritedFlightListing.of(context).toLocation}",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    Expanded(
                        flex: 1,
                        child: Icon(
                          Icons.import_export,
                          color: Colors.black,
                          size: 32,
                        ))
                  ],
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}

class FlightListBottomPart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Best Deals for Next 6 Months",
              style: dropDownMenuItemStyle,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          StreamBuilder(
            stream: Firestore.instance.collection('deals').snapshots(),
            builder: (context, snapshot) {
              return !snapshot.hasData
                  ? CircularProgressIndicator()
                  : _buildDealsList(context, snapshot.data.documents);
            },
          )
//          ListView(
//            shrinkWrap: true,
//            physics: ClampingScrollPhysics(),
//            scrollDirection: Axis.vertical,
//            children: <Widget>[
//              FlightCard(),
//              FlightCard(),
//              FlightCard(),
//              FlightCard(),
//              FlightCard(),
//            ],
//          )
        ],
      ),
    );
  }
}

Widget _buildDealsList(BuildContext context, List<DocumentSnapshot> snapshot) {
  return ListView.builder(
      shrinkWrap: true,
      itemCount: snapshot.length,
      physics: ClampingScrollPhysics(),
      scrollDirection: Axis.vertical,
      itemBuilder: (context, index) {
        return FlightCard(flightDetails: FlightDetails.fromSnapshot(snapshot[index]));
      });
}

class FlightDetails {
  final String airlines, date, discount, rating;
  final int oldPrice, newPrice;

  FlightDetails.fromMap(Map<String, dynamic> map)
      : assert(map['airlines'] != null),
        assert(map['date'] != null),
        assert(map['discount'] != null),
        assert(map['rating'] != null),
        airlines = map["airlines"],
        date = map["date"],
        discount = map["discount"],
        rating = map["rating"],
        oldPrice = map["oldPrice"],
        newPrice = map["newPrice"];

  FlightDetails.fromSnapshot(DocumentSnapshot snapshot) : this.fromMap(snapshot.data);
}

class FlightCard extends StatelessWidget {

  final FlightDetails flightDetails;

  FlightCard({this.flightDetails});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Stack(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 16.0),
            height: 100,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                border: Border.all(color: flightBorderColor)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        '${formatCurrency.format(flightDetails.newPrice)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(
                        width: 4.0,
                      ),
                      Text(
                        '(${formatCurrency.format(flightDetails.oldPrice)})',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey),
                      )
                    ],
                  ),
                  Wrap(
                    spacing: 8.0,
                    children: <Widget>[
                      FlightDetailChip(Icons.calendar_today, '${flightDetails.date}'),
                      FlightDetailChip(Icons.flight_takeoff, '${flightDetails.airlines}'),
                      FlightDetailChip(Icons.star, '${flightDetails.rating}')
                    ],
                  )
                ],
              ),
            ),
          ),
          Positioned(
            top: 10.0,
            right: 5,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              child: Text(
                '${flightDetails.discount}',
                style: TextStyle(
                    color: appTheme.primaryColor,
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold),
              ),
              decoration: BoxDecoration(
                  color: appTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.all(Radius.circular(8.0))),
            ),
          )
        ],
      ),
    );
  }
}

class FlightDetailChip extends StatelessWidget {
  final IconData iconData;
  final String label;

  FlightDetailChip(this.iconData, this.label);

  @override
  Widget build(BuildContext context) {
    return RawChip(
      label: Text(label),
      labelStyle: TextStyle(color: Colors.black, fontSize: 14.0),
      backgroundColor: chipBackgroundColor,
      avatar: Icon(
        iconData,
        size: 16,
      ),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
    );
  }
}
