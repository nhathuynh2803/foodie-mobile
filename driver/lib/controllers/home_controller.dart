import 'dart:async';
import 'dart:math';
import 'package:driver/constant/collection_name.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/constant/send_notification.dart';
import 'package:driver/constant/show_toast_dialog.dart';
import 'package:driver/models/user_model.dart';
import 'package:driver/themes/app_them_data.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/order_model.dart';

class HomeController extends GetxController {
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    if (Constant.selectedMapType == 'osm' &&
        (Constant.isDriverVerification == true && Constant.userModel!.isDocumentVerify == true)) {
      mapOsmController = MapController(
          initPosition: GeoPoint(latitude: 20.9153, longitude: -100.7439), useExternalTracking: false); //OSM
    }
    getArgument();
    setIcons();
    getDriver();

    super.onInit();
  }

  Rx<OrderModel> orderModel = OrderModel().obs;
  Rx<OrderModel> currentOrder = OrderModel().obs;
  Rx<UserModel> driverModel = UserModel().obs;

  getArgument() {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      orderModel.value = argumentData['orderModel'];
    }
  }

  acceptOrder() async {
    ShowToastDialog.showLoader("Please wait");
    driverModel.value.inProgressOrderID ?? [];
    driverModel.value.orderRequestData!.remove(currentOrder.value.id);
    driverModel.value.inProgressOrderID!.add(currentOrder.value.id);

    await FireStoreUtils.updateUser(driverModel.value);

    currentOrder.value.status = Constant.driverAccepted;
    currentOrder.value.driverID = driverModel.value.id;
    currentOrder.value.driver = driverModel.value;

    await FireStoreUtils.setOrder(currentOrder.value);
    ShowToastDialog.closeLoader();
    await SendNotification.sendFcmMessage(
        Constant.driverAcceptedNotification, currentOrder.value.author!.fcmToken.toString(), {});
    await SendNotification.sendFcmMessage(
        Constant.driverAcceptedNotification, currentOrder.value.vendor!.fcmToken.toString(), {});
  }

  rejectOrder() async {
    currentOrder.value.rejectedByDrivers ??= [];

    currentOrder.value.rejectedByDrivers!.add(driverModel.value.id);
    currentOrder.value.status = Constant.driverRejected;
    await FireStoreUtils.setOrder(currentOrder.value);

    driverModel.value.orderRequestData!.remove(currentOrder.value.id);
    await FireStoreUtils.updateUser(driverModel.value);

    currentOrder.value = OrderModel();
    markers.clear();
    polyLines.clear();
    if (Constant.singleOrderReceive == false) {
      Get.back();
    }
  }

  getCurrentOrder() async {
    if (Constant.singleOrderReceive == true) {
      if (driverModel.value.inProgressOrderID != null && driverModel.value.inProgressOrderID!.isNotEmpty) {
        FireStoreUtils.fireStore
            .collection(CollectionName.restaurantOrders)
            .doc(driverModel.value.inProgressOrderID!.first.toString())
            .snapshots()
            .listen(
          (event) async {
            if (event.exists) {
              currentOrder.value = OrderModel.fromJson(event.data()!);
              changeData();
            }
          },
        );
      } else if (driverModel.value.orderRequestData != null && driverModel.value.orderRequestData!.isNotEmpty) {
        FireStoreUtils.fireStore
            .collection(CollectionName.restaurantOrders)
            .doc(driverModel.value.orderRequestData!.first.toString())
            .snapshots()
            .listen(
          (event) async {
            if (event.exists) {
              currentOrder.value = OrderModel.fromJson(event.data()!);
              changeData();
            }
          },
        );
      }
    } else {
      FireStoreUtils.fireStore.collection(CollectionName.restaurantOrders).doc(orderModel.value.id).snapshots().listen(
        (event) async {
          if (event.exists) {
            currentOrder.value = OrderModel.fromJson(event.data()!);
            changeData();
          }
        },
      );
    }
  }

  RxBool isChange = false.obs;

  changeData() {
    if (Constant.mapType == "inappmap") {
      if (Constant.selectedMapType == "osm") {
        print("0000====>0");
        getOSMPolyline();
      } else {
        getDirections();
      }
    }
  }

  getDriver() {
    FireStoreUtils.fireStore.collection(CollectionName.users).doc(FireStoreUtils.getCurrentUid()).snapshots().listen(
      (event) async {
        if (event.exists) {
          driverModel.value = UserModel.fromJson(event.data()!);
          changeData();
          getCurrentOrder();
        }
      },
    );
    isLoading.value = false;
  }

  GoogleMapController? mapController;

  Rx<PolylinePoints> polylinePoints = PolylinePoints().obs;
  RxMap<PolylineId, Polyline> polyLines = <PolylineId, Polyline>{}.obs;
  RxMap<String, Marker> markers = <String, Marker>{}.obs;

  BitmapDescriptor? departureIcon;
  BitmapDescriptor? destinationIcon;
  BitmapDescriptor? taxiIcon;

  setIcons() async {
    if (Constant.selectedMapType == 'google') {
      final Uint8List departure = await Constant().getBytesFromAsset('assets/images/location_black3x.png', 100);
      final Uint8List destination = await Constant().getBytesFromAsset('assets/images/location_orange3x.png', 100);
      final Uint8List driver = await Constant().getBytesFromAsset('assets/images/food_delivery.png', 120);

      departureIcon = BitmapDescriptor.fromBytes(departure);
      destinationIcon = BitmapDescriptor.fromBytes(destination);
      taxiIcon = BitmapDescriptor.fromBytes(driver);
    } else {
      departureOsmIcon = Image.asset("assets/images/location_black3x.png", width: 30, height: 30); //OSM
      destinationOsmIcon = Image.asset("assets/images/location_orange3x.png", width: 30, height: 30); //OSM
      driverOsmIcon = Image.asset("assets/images/food_delivery.png", width: 80, height: 80); //OSM
    }
  }

  getDirections() async {
    if (currentOrder.value.id != null) {
      if (currentOrder.value.status != Constant.driverPending) {
        if (currentOrder.value.status == Constant.orderShipped) {
          List<LatLng> polylineCoordinates = [];

          PolylineResult result = await polylinePoints.value.getRouteBetweenCoordinates(
              googleApiKey: Constant.mapAPIKey,
              request: PolylineRequest(
                  origin: PointLatLng(
                      driverModel.value.location!.latitude ?? 0.0, driverModel.value.location!.longitude ?? 0.0),
                  destination: PointLatLng(
                      currentOrder.value.vendor!.latitude ?? 0.0, currentOrder.value.vendor!.longitude ?? 0.0),
                  mode: TravelMode.driving));
          if (result.points.isNotEmpty) {
            for (var point in result.points) {
              polylineCoordinates.add(LatLng(point.latitude, point.longitude));
            }
          }
          markers.remove("Departure");
          markers['Departure'] = Marker(
              markerId: const MarkerId('Departure'),
              infoWindow: const InfoWindow(title: "Departure"),
              position: LatLng(currentOrder.value.vendor!.latitude ?? 0.0, currentOrder.value.vendor!.longitude ?? 0.0),
              icon: departureIcon!);

          markers.remove("Destination");
          markers['Destination'] = Marker(
              markerId: const MarkerId('Destination'),
              infoWindow: const InfoWindow(title: "Destination"),
              position: LatLng(currentOrder.value.address!.location!.latitude ?? 0.0,
                  currentOrder.value.address!.location!.longitude ?? 0.0),
              icon: destinationIcon!);

          markers.remove("Driver");
          markers['Driver'] = Marker(
              markerId: const MarkerId('Driver'),
              infoWindow: const InfoWindow(title: "Driver"),
              position:
                  LatLng(driverModel.value.location!.latitude ?? 0.0, driverModel.value.location!.longitude ?? 0.0),
              icon: taxiIcon!,
              rotation: double.parse(driverModel.value.rotation.toString()));

          addPolyLine(polylineCoordinates);
        } else if (currentOrder.value.status == Constant.orderInTransit) {
          List<LatLng> polylineCoordinates = [];

          PolylineResult result = await polylinePoints.value.getRouteBetweenCoordinates(
              googleApiKey: Constant.mapAPIKey,
              request: PolylineRequest(
                  origin: PointLatLng(
                      driverModel.value.location!.latitude ?? 0.0, driverModel.value.location!.longitude ?? 0.0),
                  destination: PointLatLng(currentOrder.value.address!.location!.latitude ?? 0.0,
                      currentOrder.value.address!.location!.longitude ?? 0.0),
                  mode: TravelMode.driving));

          if (result.points.isNotEmpty) {
            for (var point in result.points) {
              polylineCoordinates.add(LatLng(point.latitude, point.longitude));
            }
          }
          markers.remove("Departure");
          markers['Departure'] = Marker(
              markerId: const MarkerId('Departure'),
              infoWindow: const InfoWindow(title: "Departure"),
              position: LatLng(currentOrder.value.vendor!.latitude ?? 0.0, currentOrder.value.vendor!.longitude ?? 0.0),
              icon: departureIcon!);

          markers.remove("Destination");
          markers['Destination'] = Marker(
              markerId: const MarkerId('Destination'),
              infoWindow: const InfoWindow(title: "Destination"),
              position: LatLng(currentOrder.value.address!.location!.latitude ?? 0.0,
                  currentOrder.value.address!.location!.longitude ?? 0.0),
              icon: destinationIcon!);

          markers.remove("Driver");
          markers['Driver'] = Marker(
              markerId: const MarkerId('Driver'),
              infoWindow: const InfoWindow(title: "Driver"),
              position:
                  LatLng(driverModel.value.location!.latitude ?? 0.0, driverModel.value.location!.longitude ?? 0.0),
              icon: taxiIcon!,
              rotation: double.parse(driverModel.value.rotation.toString()));
          addPolyLine(polylineCoordinates);
        }
      } else {
        List<LatLng> polylineCoordinates = [];

        PolylineResult result = await polylinePoints.value.getRouteBetweenCoordinates(
            googleApiKey: Constant.mapAPIKey,
            request: PolylineRequest(
                origin: PointLatLng(currentOrder.value.author!.location!.latitude ?? 0.0,
                    currentOrder.value.author!.location!.longitude ?? 0.0),
                destination: PointLatLng(
                    currentOrder.value.vendor!.latitude ?? 0.0, currentOrder.value.vendor!.longitude ?? 0.0),
                mode: TravelMode.driving));

        if (result.points.isNotEmpty) {
          for (var point in result.points) {
            polylineCoordinates.add(LatLng(point.latitude, point.longitude));
          }
        }

        markers.remove("Departure");
        markers['Departure'] = Marker(
            markerId: const MarkerId('Departure'),
            infoWindow: const InfoWindow(title: "Departure"),
            position: LatLng(currentOrder.value.vendor!.latitude ?? 0.0, currentOrder.value.vendor!.longitude ?? 0.0),
            icon: departureIcon!);

        markers.remove("Destination");
        markers['Destination'] = Marker(
            markerId: const MarkerId('Destination'),
            infoWindow: const InfoWindow(title: "Destination"),
            position: LatLng(currentOrder.value.address!.location!.latitude ?? 0.0,
                currentOrder.value.address!.location!.longitude ?? 0.0),
            icon: destinationIcon!);

        markers.remove("Driver");
        markers['Driver'] = Marker(
            markerId: const MarkerId('Driver'),
            infoWindow: const InfoWindow(title: "Driver"),
            position: LatLng(driverModel.value.location!.latitude ?? 0.0, driverModel.value.location!.longitude ?? 0.0),
            icon: taxiIcon!,
            rotation: double.parse(driverModel.value.rotation.toString()));
        addPolyLine(polylineCoordinates);
      }
    }
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: AppThemeData.secondary300,
      points: polylineCoordinates,
      width: 8,
      geodesic: true,
    );
    polyLines[id] = polyline;
    updateCameraLocation(polylineCoordinates.first, mapController);
  }

  Future<void> updateCameraLocation(
    LatLng source,
    GoogleMapController? mapController,
  ) async {
    mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: source,
          zoom: currentOrder.value.id == null || currentOrder.value.status == Constant.driverPending ? 16 : 20,
          bearing: double.parse(driverModel.value.rotation.toString()),
        ),
      ),
    );
  }

  //OSM
  late MapController mapOsmController;
  Rx<RoadInfo> roadInfo = RoadInfo().obs;
  Map<String, GeoPoint> osmMarkers = <String, GeoPoint>{};
  Image? departureOsmIcon; //OSM
  Image? destinationOsmIcon; //OSM
  Image? driverOsmIcon;

  void getOSMPolyline() async {
    try {
      if (currentOrder.value.id != null) {
        if (currentOrder.value.status != Constant.driverPending) {
          if (currentOrder.value.status == Constant.orderShipped) {
            GeoPoint sourceLocation = GeoPoint(
              latitude: driverModel.value.location!.latitude ?? 0.0,
              longitude: driverModel.value.location!.longitude ?? 0.0,
            );
            GeoPoint destinationLocation = GeoPoint(
              latitude: currentOrder.value.vendor!.latitude ?? 0.0,
              longitude: currentOrder.value.vendor!.longitude ?? 0.0,
            );
            await mapOsmController.removeLastRoad();
            setOsmMarker(departure: sourceLocation, destination: destinationLocation);
            roadInfo.value = await mapOsmController.drawRoad(
              sourceLocation,
              destinationLocation,
              roadType: RoadType.car,
              roadOption: RoadOption(
                roadWidth: 40,
                roadColor: AppThemeData.driverApp300,
                zoomInto: false,
              ),
            );
            mapOsmController.moveTo(
              GeoPoint(latitude: sourceLocation.latitude, longitude: sourceLocation.longitude),
              animate: true,
            );
          }
          else if (currentOrder.value.status == Constant.orderInTransit) {
            GeoPoint sourceLocation = GeoPoint(
                latitude: driverModel.value.location!.latitude ?? 0.0,
                longitude: driverModel.value.location!.longitude ?? 0.0);

            GeoPoint destinationLocation = GeoPoint(
                latitude: currentOrder.value.address!.location!.latitude ?? 0.0,
                longitude: currentOrder.value.address!.location!.longitude ?? 0.0);
            setOsmMarker(departure: sourceLocation, destination: destinationLocation);
            roadInfo.value = await mapOsmController.drawRoad(
              sourceLocation,
              destinationLocation,
              roadType: RoadType.car,
              roadOption: RoadOption(
                roadWidth: 40,
                roadColor: AppThemeData.driverApp300,
                zoomInto: false,
              ),
            );
            mapOsmController.moveTo(
              GeoPoint(latitude: sourceLocation.latitude, longitude: sourceLocation.longitude),
              animate: true,
            );
          }
        } else {
          print("====>5");
          GeoPoint sourceLocation = GeoPoint(
            latitude: currentOrder.value.author!.location!.latitude ?? 0.0,
            longitude: currentOrder.value.author!.location!.longitude ?? 0.0,
          );

          GeoPoint destinationLocation = GeoPoint(
              latitude: currentOrder.value.vendor!.latitude ?? 0.0,
              longitude: currentOrder.value.vendor!.longitude ?? 0.0);
          await mapOsmController.removeLastRoad();
          setOsmMarker(departure: sourceLocation, destination: destinationLocation);
          roadInfo.value = await mapOsmController.drawRoad(
            sourceLocation,
            destinationLocation,
            roadType: RoadType.car,
            roadOption: RoadOption(
              roadWidth: 40,
              roadColor: AppThemeData.driverApp300,
              zoomInto: false,
            ),
          );
          mapOsmController.moveTo(
            GeoPoint(latitude: sourceLocation.latitude, longitude: sourceLocation.longitude),
            animate: true,
          );
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> updateOSMCameraLocation({required GeoPoint source, required GeoPoint destination}) async {
    BoundingBox bounds;

    if (source.latitude > destination.latitude && source.longitude > destination.longitude) {
      bounds = BoundingBox(
        north: source.latitude,
        south: destination.latitude,
        east: source.longitude,
        west: destination.longitude,
      );
    } else if (source.longitude > destination.longitude) {
      bounds = BoundingBox(
        north: destination.latitude,
        south: source.latitude,
        east: source.longitude,
        west: destination.longitude,
      );
    } else if (source.latitude > destination.latitude) {
      bounds = BoundingBox(
        north: source.latitude,
        south: destination.latitude,
        east: destination.longitude,
        west: source.longitude,
      );
    } else {
      bounds = BoundingBox(
        north: destination.latitude,
        south: source.latitude,
        east: destination.longitude,
        west: source.longitude,
      );
    }

    await mapOsmController.zoomToBoundingBox(bounds, paddinInPixel: 100);
  }

  setOsmMarker({required GeoPoint departure, required GeoPoint destination}) async {
    try{
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await mapOsmController
            .addMarker(departure,
            markerIcon: MarkerIcon(iconWidget: departureOsmIcon),
            angle: pi / 3,
            iconAnchor: IconAnchor(
              anchor: Anchor.top,
            ))
            .then((v) {
          osmMarkers['Source'] = departure;
        });
        await mapOsmController
            .addMarker(destination,
            markerIcon: MarkerIcon(iconWidget: destinationOsmIcon),
            angle: pi / 3,
            iconAnchor: IconAnchor(
              anchor: Anchor.top,
            ))
            .then((v) {
          osmMarkers['Destination'] = destination;
        });
      });
    } catch(e){
      print("=====>${e}");
      throw Exception(e);
    }

  }
}
