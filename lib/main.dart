import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
        home: CurrentLocation());
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late GoogleMapController _mapController;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(22.842394814029056, 89.29769910255115),
          zoom: 17
        ),
        onMapCreated: (GoogleMapController controller){
          _mapController = controller;
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        mapType: MapType.normal,
        onCameraMove: (CameraPosition cameraPosition){
          print('Camera Position');
        },
        onCameraIdle: (){
          print('Fetching position');
        },
        zoomControlsEnabled: true,
        zoomGesturesEnabled:true,
        mapToolbarEnabled: true,
        markers: <Marker>{
          Marker(markerId: MarkerId('My Home'),
            position: LatLng(22.843440462310205, 89.29899734672063),
            draggable: true,
            flat: false,
            onTap: (){
            print('On Tapped on my HOME');
            },
            onDrag: (LatLng latlang){
            print(latlang);
            },
            onDragStart: (LatLng latlang){
            print(latlang);
            },
            infoWindow: InfoWindow(
              title: 'My Home',
              onTap: (){print('Tapped on Info Window');}
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)
          ),
          Marker(markerId: MarkerId('My Shop'),
            position: LatLng(22.842467946157882, 89.29654402382424),
            infoWindow: InfoWindow(
              title: 'My Shop'
            )
          )
        },
        circles: <Circle>{
          Circle(
            circleId: CircleId('red zone'),
            center: LatLng(22.843440462310205, 89.29899734672063),
            radius: 30,
            onTap: (){
              print('Tapped On Circle');
            },
            fillColor: Colors.transparent,
            strokeColor: Colors.red,
            strokeWidth: 3,
            consumeTapEvents: true,
            visible: true,
          )
        },
        polygons: <Polygon>{
          Polygon(
            polygonId: PolygonId('my_home'),
            points: [
              LatLng(22.843506284337682, 89.29897660482771),
              LatLng(22.843499837217394, 89.29901741372481),
              LatLng(22.843223700116738, 89.29902011230914),
              LatLng(22.843235935123655, 89.29892528190484),
              LatLng(22.843307597284966, 89.2989195920806),
              LatLng(22.843311092999198, 89.29897933523529)
            ],
            fillColor: Colors.deepOrangeAccent,
            strokeWidth: 2,
            strokeColor: Colors.greenAccent,
            onTap: (){},
            consumeTapEvents: true
          ),
        },
        polylines: <Polyline>{
          Polyline(
            polylineId: PolylineId('road_from_home_to_shop'),
            points: [
              LatLng(22.842493900670902, 89.29648434467518),
              LatLng(22.843568828758077, 89.29899189922308)
            ],
            width: 6,
            jointType: JointType.round,
            endCap: Cap.buttCap,
          )
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: (){
        // _mapController.moveCamera(
        //     CameraUpdate.newCameraPosition(
        //         CameraPosition(
        //             target: LatLng(22.842394814029056, 89.29769910255115),
        //             zoom: 17
        //         )
        //     )
        // );
        _mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(23.79348696073093, 90.40612976653253),
              zoom: 16,
            ),
          ),
        );
      },
        child: Icon(Icons.location_history),
      ),
    );
  }
}

class CurrentLocation extends StatefulWidget {
  const CurrentLocation({super.key});

  @override
  State<CurrentLocation> createState() => _CurrentLocationState();
}

class _CurrentLocationState extends State<CurrentLocation> {
  Position? _currentPosition;
  Position? _liveLocation;

  // check location permission
  Future<bool> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      return true;
    } else {
      return false;
    }
  }

  // request location permission
  Future<bool> _requestLocationPermission() async {
    LocationPermission requestPermission = await Geolocator.requestPermission();
    if (requestPermission == LocationPermission.always ||
        requestPermission == LocationPermission.whileInUse) {
      return true;
    } else {
      return false;
    }
  }

  // GPS is enabled or not
  Future<bool> _checkIfGPSEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  //get current location
  Future<void> _getCurrentLocation() async {
    if (await _checkLocationPermission()) {
      if (await _checkIfGPSEnabled()) {
        Position position = await Geolocator.getCurrentPosition();
        _currentPosition = position;
        setState(() {});
      }
      else {
        Geolocator.openAppSettings();
      }
    } else {
      print("Location is not Available");
      if (await _requestLocationPermission()) {
        _getCurrentLocation();
      } else {
        Geolocator.openAppSettings();
      }
    }
  }

    Future<void> _listenCurrentLocation() async {
      if (await _checkLocationPermission()) {
        if (await _checkIfGPSEnabled()) {
          Geolocator.getPositionStream().listen((location) {
            {
              _liveLocation = location;
              setState(() {});
            }
          });
        }
        else {
          Geolocator.openAppSettings();
        }
      } else {
        print("Location is not Available");
        if (await _requestLocationPermission()) {
          _getCurrentLocation();
        } else {
          Geolocator.openAppSettings();
        }
      }
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
          appBar: AppBar(
            title: Text('Current Location'),
            centerTitle: true,
          ),
          body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Latitude:${_currentPosition
                      ?.latitude}, Longitude:${_currentPosition?.longitude}"),
                  //Text(_currentPosition?.isMocked.toString() ?? ''),
                  Text("Live Location: $_liveLocation")
                ],
              )
          ),
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              FloatingActionButton(
                onPressed: () {
                  _getCurrentLocation();
                },
                child: Icon(Icons.my_location_outlined),
              ),
              FloatingActionButton(
                onPressed: () {
                  _listenCurrentLocation();
                },
                child: Icon(Icons.location_history),
              ),
            ],
          )
      );
    }
  }