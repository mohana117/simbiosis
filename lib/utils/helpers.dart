import 'dart:math' as math;
import 'package:latlong2/latlong.dart';

const Map<String, LatLng> stateCoordinates = {
  'Johor': LatLng(1.4927, 103.7414),
  'Kedah': LatLng(6.1184, 100.3685),
  'Kelantan': LatLng(6.1254, 102.2381),
  'Melaka': LatLng(2.1896, 102.2501),
  'Negeri Sembilan': LatLng(2.7258, 101.9424),
  'Pahang': LatLng(3.8126, 103.3256),
  'Penang': LatLng(5.4141, 100.3288),
  'Perak': LatLng(4.5921, 101.0901),
  'Perlis': LatLng(6.4449, 100.2048),
  'Sabah': LatLng(5.9804, 116.0735),
  'Sarawak': LatLng(1.5533, 110.3592),
  'Selangor': LatLng(3.0738, 101.5183),
  'Terengganu': LatLng(5.3117, 103.1324),
  'W.P. Kuala Lumpur': LatLng(3.1390, 101.6869),
};

double calculateDistance(LatLng point1, LatLng point2) {
  const Distance distance = Distance();
  return distance.as(LengthUnit.Kilometer, point1, point2);
}