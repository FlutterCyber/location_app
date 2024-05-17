import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:device_information/device_information.dart';
import 'package:permission_handler/permission_handler.dart';

class GetDeviceInfo {
  static Future<String> getDeviceInfo() async {
    String info = "";
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    if (await Permission.phone.request().isGranted) {
      try {
        String platformVersion = await DeviceInformation.platformVersion;
        String imeiNo = await DeviceInformation.deviceIMEINumber;
        String modelName = await DeviceInformation.deviceModel;
        String manufacturer = await DeviceInformation.deviceManufacturer;
        String apiLevel = await DeviceInformation.apiLevel.toString();
        String deviceName = await DeviceInformation.deviceName;
        String productName = await DeviceInformation.productName;
        String cpuType = await DeviceInformation.cpuName;
        String hardware = await DeviceInformation.hardware;
        info = "IMEI номер: $imeiNo\n"
            "ID телефона: ${androidInfo.id}\n"
            "Серийный номер: ${androidInfo.serialNumber}\n"
            "Версия платформы: $platformVersion\n"
            "Название модели: $modelName\n"
            "Производитель: $manufacturer\n"
            "API level: ${apiLevel.length}\n"
            "Имя устройства: $deviceName\n"
            "Наименование устройства: $productName\n"
            "Тип процессора: $cpuType\n"
            "Аппаратное обеспечение: $hardware";
      } on PlatformException catch (e) {
        info = '${e.message}';
      }
    } else {
      // Permission is not granted yet. Request it from the user.
      if (await Permission.phone.request().isGranted) {
        try {
          String platformVersion = await DeviceInformation.platformVersion;
          String imeiNo = await DeviceInformation.deviceIMEINumber;
          String modelName = await DeviceInformation.deviceModel;
          String manufacturer = await DeviceInformation.deviceManufacturer;
          String apiLevel = await DeviceInformation.apiLevel.toString();
          String deviceName = await DeviceInformation.deviceName;
          String productName = await DeviceInformation.productName;
          String cpuType = await DeviceInformation.cpuName;
          String hardware = await DeviceInformation.hardware;
          info =
              "\nPlatform Version: $platformVersion\nIMEI number: $imeiNo\nModel name: $modelName\nManufacturer: $manufacturer\nAPI level; $apiLevel\nDevice name: $deviceName\nProduct name: $productName\nCPU type: $cpuType\nHardware: $hardware";
        } on PlatformException catch (e) {
          info = '${e.message}';
        }
      } else {
        info = "NULL";
      }
    }

    return info;
  }
}
