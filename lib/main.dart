// ignore_for_file: prefer_const_constructors, duplicate_ignore, empty_statements

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latihan_map/location_service.dart';

void main() => runApp(MyApp());

// ignore: use_key_in_widget_constructors
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps Demo',
      home: MapSample(),
    );
  }
}

// ignore: use_key_in_widget_constructors
class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  // ignore: prefer_final_fields
  Completer<GoogleMapController> _controller = Completer();
  // ignore: prefer_final_fields
  TextEditingController _searchController = TextEditingController();
  final TextEditingController _destController = TextEditingController();

  final Set<Marker> _markers = <Marker>{};
  final Set<Polygon> _polygons = <Polygon>{};
  Set<Polyline> _polylines = <Polyline>{};
  List<LatLng> polygonLatLng = <LatLng>[];
  bool status = false;

  int _polygonIdCounter = 1;
  int _polylineIdCounter = 1;

  static const CameraPosition _kGooglePlex = CameraPosition(
    // ignore: unnecessary_const
    target: const LatLng(-6.49352, 107.0060572),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
    // ignore: prefer_const_constructors
    _setMarkerAwal(LatLng(-6.49352, 107.0060572));
  }

  void _setMarkerAwal(LatLng point) {
    setState(() {
      // ignore: prefer_const_constructors
      _markers.add(Marker(markerId: MarkerId('marker'), position: point));
    });
  }

  void _setMarker(LatLng point, LatLng point2) {
    setState(() {
      // ignore: prefer_const_constructors
      _markers.add(Marker(markerId: MarkerId('marker'), position: point, icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)));
      // _markers.add(Marker(markerId: MarkerId('marker'), position: point2, icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)));
    });
  }

  // void _setPolygon() {
  //   final String polygonIdVal = 'polygon_$_polygonIdCounter';
  //   _polygonIdCounter++;

    // _polygons.add(Polygon(
    //     polygonId: PolygonId(polygonIdVal),
    //     points: polygonLatLng,
    //     strokeWidth: 2,
    //     fillColor: Colors.transparent));
  // }

  void _setPolyline(List<PointLatLng> point) {
    final String polylineIdVal = 'polyline_$_polylineIdCounter';
    _polylineIdCounter++;

    setState(() {
      _polylines = <Polyline>{};
    });

    _polylines.add(Polyline(
        polylineId: PolylineId(polylineIdVal),
        width: 5,
        color: Colors.blue,
        points: point
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList()));
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unnecessary_new
    return new Scaffold(
      appBar: AppBar(
        // ignore: prefer_const_constructors
        title: Text("Google Maps"),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: Column(
                children: [
                  TextFormField(
                    controller: _searchController,
                    // ignore: prefer_const_constructors
                    decoration: InputDecoration(hintText: "Origin"),
                    onChanged: (value) {
                      // ignore: avoid_print
                      print(value);
                    },
                  ),
                  TextFormField(
                    controller: _destController,
                    // ignore: prefer_const_constructors
                    decoration: InputDecoration(hintText: "Destination"),
                    onChanged: (value) {
                      // ignore: avoid_print
                      print(value);
                    },
                  ),
                ],
              )),
              IconButton(
                  onPressed: () async {
                    var directions = await LocationService().getDirections(
                        _searchController.text, _destController.text);

                    // var place = await LocationService()
                    //     .getPlace(_searchController.text);
                    _goToPlace(directions['start_location']['lat'],
                        directions['start_location']['lng'], directions['end_location']['lat'],
                        directions['end_location']['lng'], directions['bounds_ne'], directions['bounds_sw']);

                    _setPolyline(directions['polyline_decoded']);
                  },
                  icon: Icon(Icons.search)),
            ],
          ),
          Expanded(
            child: GoogleMap(
              mapType: MapType.normal,
              markers: _markers,
              polygons: _polygons,
              polylines: _polylines,
              initialCameraPosition: _kGooglePlex,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              onTap: (point) {
                setState(() {
                  polygonLatLng.add(point);
                });
              },
            ),
          ),
        ],
      ),
      // flo
    );
  }

  Future<void> _goToPlace(double lat, double lng, double endlat, double endlng, Map<String, dynamic> boundsNe, Map<String, dynamic> boundsSw) async {
    // final double lat = place['geometry']['location']['lat'];
    // final double lng = place['geometry']['location']['lng'];

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: LatLng(lat, lng), zoom: 12),
    ));

    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(boundsSw['lat'], boundsSw['lng']),
          northeast: LatLng(boundsNe['lat'], boundsSw['lng'])), 
        25));

    _setMarker(LatLng(lat, lng), LatLng(endlat, endlng));
  }
}
