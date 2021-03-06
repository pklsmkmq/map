import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class LocationService {
  final String key = "AIzaSyBu2PRPA1n4miz1ZWZ7to8P589d1t3_Iew";

  Future<String> getPlaceId(String input) async {
    final String url = "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=$input&inputtype=textquery&key=$key";

    var response = await http.get(Uri.parse(url));

    var json = convert.jsonDecode(response.body);
    var placeId = json['candidates'][0]['places_id'] as String;

    // ignore: avoid_print
    print(placeId);

    return placeId;
  }

  Future<Map<String, dynamic>> getPlace(String input) async{
    final placeId = await getPlaceId(input);

    final String url = "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$key";

    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var results = json['result'] as Map<String, dynamic>;

    // ignore: avoid_print
    print(results);
    return results;
  }

  Future<Map<String, dynamic>> getDirections(String origin, String destination) async{
    final String url = "https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=$key";
  
    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);

    var result = {
      'bounds_ne' : json["routes"][0]["bounds"]["northeast"],
      'bounds_sw' : json["routes"][0]["bounds"]["southwest"],
      'start_location' : json["routes"][0]["legs"][0]["start_location"],
      'end_location' : json["routes"][0]["legs"][0]["end_location"],
      'polyline' : json["routes"][0]["overview_polyline"]["points"],
      'polyline_decoded' : PolylinePoints().decodePolyline(json["routes"][0]["overview_polyline"]["points"]),
    };
    // ignore: avoid_print
    print(result);
    return result;
  }
}