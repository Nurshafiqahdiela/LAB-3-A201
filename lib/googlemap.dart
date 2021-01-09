import 'dart:async';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapScreen extends StatefulWidget {
  @override
  _GoogleMapScreenState createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  List cartData;
  double screenHeight, screenWidth;

  Position _currentPosition;
  String curaddress;
  Completer<GoogleMapController> _controller = Completer();
  static const LatLng _center = const LatLng(6.4676929, 100.5067673);

  LatLng _lastMapPosition = _center;
  MapType _currentMapType = MapType.normal;

  GoogleMapController gmcontroller;
  CameraPosition _home;
  MarkerId markerId1 = MarkerId("12");
  Set<Marker> markers = Set();
  double latitude = 6.4676929;
  double longitude = 100.5067673;
  String label;
  CameraPosition _userpos;

  @override
  void initState() {
    super.initState();
    _getLocation();
    //_getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: AppBar(title: Text('My Maps'), actions: <Widget>[]),
        body: Container(
            child: Column(
          children: <Widget>[
            cartData == null
                ? Flexible(
                    child: Container(
                        child: Center(
                            child: Text(
                    '',
                    style: TextStyle(
                        color: Color.fromRGBO(101, 255, 218, 50),
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ))))
                : Expanded(
                    child: ListView.builder(
                        itemCount: cartData == null ? 1 : cartData.length + 2,
                        itemBuilder: (context, index) {
                          if (index == cartData.length) {
                            return Container(
                                height: screenHeight / 2.4,
                                width: screenWidth / 2.5,
                                child: InkWell(
                                  child: Card(
                                    //color: Colors.yellow,
                                    elevation: 5,
                                    child: Column(
                                      children: <Widget>[
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Expanded(
                                            child: Row(
                                          children: <Widget>[
                                            Expanded(
                                                child: Container(
                                              //color: Colors.blue,

                                              //height: screenHeight / 3,
                                              child: Column(
                                                children: <Widget>[
                                                  FlatButton(
                                                    color: Color.fromRGBO(
                                                        101, 255, 218, 50),
                                                    onPressed: () =>
                                                        {_loadMapDialog()},
                                                  ),
                                                  Text("Current Address:",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black)),
                                                  Row(
                                                    children: <Widget>[
                                                      Text("  "),
                                                      Flexible(
                                                        child: Text(
                                                          curaddress ??
                                                              "Address not set",
                                                          maxLines: 3,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            )),
                                          ],
                                        ))
                                      ],
                                    ),
                                  ),
                                ));
                          }
                        })),
          ],
        )));
  }

  _getLocation() async {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
    _currentPosition = await geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    //debugPrint('location: ${_currentPosition.latitude}');
    final coordinates =
        new Coordinates(_currentPosition.latitude, _currentPosition.longitude);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    setState(() {
      curaddress = first.addressLine;
      if (curaddress != null) {
        latitude = _currentPosition.latitude;
        longitude = _currentPosition.longitude;
        return;
      }
    });

    print("${first.featureName} : ${first.addressLine}");
  }

  _getLocationfromlatlng(double lat, double lng, newSetState) async {
    final Geolocator geolocator = Geolocator()
      ..placemarkFromCoordinates(lat, lng);
    _currentPosition = await geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    //debugPrint('location: ${_currentPosition.latitude}');
    final coordinates = new Coordinates(lat, lng);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    newSetState(() {
      curaddress = first.addressLine;
      if (curaddress != null) {
        latitude = _currentPosition.latitude;
        longitude = _currentPosition.longitude;
        return;
      }
    });
    setState(() {
      curaddress = first.addressLine;
      if (curaddress != null) {
        latitude = _currentPosition.latitude;
        longitude = _currentPosition.longitude;
        return;
      }
    });

    print("${first.featureName} : ${first.addressLine}");
  }

  _loadMapDialog() {
    try {
      if (_currentPosition.latitude == null) {
        Toast.show("Location not available. Please wait...", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        _getLocation(); //_getCurrentLocation();
        return;
      }
      _controller = Completer();
      _userpos = CameraPosition(
        target: LatLng(latitude, longitude),
        zoom: 17,
      );

      markers.add(Marker(
          markerId: markerId1,
          position: LatLng(latitude, longitude),
          infoWindow: InfoWindow(
            title: 'Current Location',
          )));

      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, newSetState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),

                titlePadding: EdgeInsets.all(5),
                //content: Text(curaddress),
                actions: <Widget>[
                  Text(
                    curaddress,
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  Container(
                    height: screenHeight / 2 ?? 600,
                    width: screenWidth ?? 360,
                    child: GoogleMap(
                        mapType: MapType.normal,
                        initialCameraPosition: _userpos,
                        markers: markers.toSet(),
                        onMapCreated: (controller) {
                          _controller.complete(controller);
                        },
                        onTap: (newLatLng) {
                          _loadLoc(newLatLng, newSetState);
                        }),
                  ),
                  Positioned(
                    top: 590,
                    left: 50,
                    width: 300,
                    child: Text(
                      ("Current Latitude      :  ") + (latitude).toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black, fontSize: 13),
                    ),
                  ),
                  Positioned(
                    top: 610,
                    left: 50,
                    width: 300,
                    child: Text(
                      ("Current Longitude   :  ") + (longitude).toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black, fontSize: 13),
                    ),
                  ),
                  Positioned(
                    top: 510,
                    left: 50,
                    width: 300,
                    child: Text(
                      ("Latest Pinned Address :"),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)),
                    //minWidth: 200,
                    height: 30,
                    child: Text('Close'),
                    color: Color.fromRGBO(101, 255, 218, 50),
                    textColor: Colors.black,
                    elevation: 10,
                    onPressed: () =>
                        {markers.clear(), Navigator.of(context).pop(false)},
                  ),
                ],
              );
            },
          );
        },
      );
    } catch (e) {
      print(e);
      return;
    }
  }

  void _loadLoc(LatLng loc, setState) async {
    setState(() {
      print("insetstate");
      markers.clear();
      latitude = loc.latitude;
      longitude = loc.longitude;
      _getLocationfromlatlng(latitude, longitude, setState);
      _home = CameraPosition(
        target: loc,
        zoom: 17,
      );
      markers.add(Marker(
          markerId: markerId1,
          position: LatLng(latitude, longitude),
          infoWindow: InfoWindow(
            title: 'New Location',
            snippet: 'New Delivery Location',
          )));
    });
    _userpos = CameraPosition(
      target: LatLng(latitude, longitude),
      zoom: 17,
    );
    _newhomeLocation();
  }

  Future<void> _newhomeLocation() async {
    gmcontroller = await _controller.future;
    gmcontroller.animateCamera(CameraUpdate.newCameraPosition(_home));
    //Navigator.of(context).pop(false);
    //_loadMapDialog();
  }
}
