import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hacknroll2021/Carpark.dart';
import 'package:hacknroll2021/DataSource.dart';
import 'package:hacknroll2021/Location.dart';

class MapWidget extends StatefulWidget {
  Function(Carpark) selectCallback;

  MapWidget({this.selectCallback});

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  GoogleMapController mapController;
  Future<List<Carpark>> _carparkList;

  final LatLng _center = const LatLng(1.3521, 103.8198);

  String _mapStyle;
  BitmapDescriptor _availableIcon;
  BitmapDescriptor _notAvailableIcon;
  Location _locationHandler;

  @override
  void initState() {
    super.initState();
    rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });

//    DataSource ds = new DataSource();
//    _carparkList = ds.fetchData();
    _locationHandler = new Location();
    _carparkList = _locationHandler.returnNearestCarparkList();

    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/GreenMarker.png').then((onValue) {
      _availableIcon = onValue;
    });

    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/RedMarker.png').then((onValue) {
      _notAvailableIcon = onValue;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController.setMapStyle(_mapStyle);
  }


  Set<Marker> generateMarkers(List<Carpark> carparkList) {
    return carparkList.map((carpark) {
      return Marker(
        markerId: MarkerId(carpark.carparkId),
        position: carpark.location,
        infoWindow: InfoWindow(
          title: carpark.development,
          snippet: carpark.availableLots.toString() + " Lots Available"
        ),
        icon: carpark.availableLots > 10 ? _availableIcon : _notAvailableIcon,
        onTap: () => widget.selectCallback(carpark),
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Carpark>>(
        future: _carparkList,
        builder: (BuildContext context, AsyncSnapshot<List<Carpark>> snapshot) {
      if(snapshot.hasData) {
        List<Carpark> data = snapshot.data;
        Set<Marker> markers = generateMarkers(data);
        return GoogleMap(
          onMapCreated: _onMapCreated,
          tiltGesturesEnabled: false,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 11.0,
          ),
          markers: markers,
          myLocationEnabled: true,
        );
      } else if(snapshot.hasError) {
        return Text(snapshot.error.toString());
      } else {
        return CircularProgressIndicator();
      }
    });
  }
}
