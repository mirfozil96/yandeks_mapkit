import 'dart:math';

import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import 'widgets/control_button.dart';
import 'widgets/map_page.dart';

class PolygonMapObjectPage extends MapPage {
  const PolygonMapObjectPage({Key? key}) : super('Polygon example', key: key);

  @override
  Widget build(BuildContext context) {
    return _PolygonMapObjectExample();
  }
}

class _PolygonMapObjectExample extends StatefulWidget {
  @override
  _PolygonMapObjectExampleState createState() =>
      _PolygonMapObjectExampleState();
}

class _PolygonMapObjectExampleState extends State<_PolygonMapObjectExample> {
  final List<MapObject> mapObjects = [];

  final MapObjectId mapObjectId = const MapObjectId('polygon');

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(child: YandexMap(mapObjects: mapObjects)),
          const SizedBox(height: 20),
          Expanded(
              child: SingleChildScrollView(
                  child: Column(children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                ControlButton(
                    onPressed: () async {
                      if (mapObjects.any((el) => el.mapId == mapObjectId)) {
                        return;
                      }

                      final mapObject = PolygonMapObject(
                        mapId: mapObjectId,
                        polygon: const Polygon(
                            outerRing: LinearRing(points: [
                              Point(latitude: 41.326577, longitude: 69.228404),
                              Point(latitude: 21.422481, longitude: 39.826128),
                              Point(
                                latitude: 46.548619,
                                longitude: 33.141160,
                              ),
                            ]),
                            innerRings: [
                              LinearRing(points: [
                                Point(
                                    latitude: 41.326577, longitude: 69.228404),
                                Point(
                                    latitude: 21.422481, longitude: 39.826128),
                                Point(
                                  latitude: 46.548619,
                                  longitude: 33.141160,
                                ),
                              ])
                            ]),
                        strokeColor: Colors.orange[700]!,
                        strokeWidth: 3.0,
                        fillColor: Colors.yellow[200]!,
                        onTap: (PolygonMapObject self, Point point) =>
                            print('Tapped me at $point'),
                      );

                      setState(() {
                        mapObjects.add(mapObject);
                      });
                    },
                    title: 'Add'),
                ControlButton(
                    onPressed: () async {
                      if (!mapObjects.any((el) => el.mapId == mapObjectId)) {
                        return;
                      }

                      final mapObject =
                          mapObjects.firstWhere((el) => el.mapId == mapObjectId)
                              as PolygonMapObject;

                      setState(() {
                        mapObjects[mapObjects.indexOf(mapObject)] =
                            mapObject.copyWith(
                          strokeColor: Colors.orange[700]!,
                          strokeWidth: 3.0,
                          fillColor: Colors.primaries[
                              Random().nextInt(Colors.primaries.length)],
                        );
                      });
                    },
                    title: 'Update'),
                ControlButton(
                    onPressed: () async {
                      setState(() {
                        mapObjects.removeWhere((el) => el.mapId == mapObjectId);
                      });
                    },
                    title: 'Remove')
              ],
            )
          ])))
        ]);
  }
}
