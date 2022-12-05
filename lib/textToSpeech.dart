// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:iot/playAudio.dart';

class TextToSpeech {
  static textToSpeech(String text) async {
    var dateTime = DateTime.now().toUtc();
    var date = "${dateTime.year}-${dateTime.month}-${dateTime.day}";
    var Timestamp = dateTime.millisecondsSinceEpoch.toString().substring(0, 10);
    var Algorithm = "TC3-HMAC-SHA256";
    var CredentialScope = "$date/tts/tc3_request";
    String SecretKey = "Ulqma9C5mGWhkkfOtBYuBKGxPi5Tipmj";
    String SecretId = "AKIDxkIbjfOvG4f17zhCRSFmDMPK3Zu1uZ9i";

    String HTTPRequestMethod = "POST";
    String CanonicalURI = "/";
    String CanonicalQueryString = "";
    String contentType = "application/json; charset=utf-8";
    String CanonicalHeaders =
        "content-type:$contentType\nhost:tts.tencentcloudapi.com\n";
    String SignedHeaders = "content-type;host";
    var requestBody = {
      "Text": text,
      "ModelType": 1,
      "Volume": 5,
      "Codec": "wav",
      "SampleRate": 16000,
      "PrimaryLanguage": 1,
    };
    var jsonRequestBody = jsonEncode(requestBody);
    String HashedRequestPayload =
        sha256.convert(utf8.encode(jsonRequestBody)).toString().toLowerCase();
    String CanonicalRequest =
        "$HTTPRequestMethod\n$CanonicalURI\n$CanonicalQueryString\n$CanonicalHeaders\n$SignedHeaders\n$HashedRequestPayload";
    String HashedCanonicalRequest =
        sha256.convert(utf8.encode(CanonicalRequest)).toString().toLowerCase();
    String StringToSign =
        "$Algorithm\n$Timestamp\n$CredentialScope\n$HashedCanonicalRequest";

    var SecretDate = Hmac(sha256, utf8.encode("TC3$SecretKey"))
        .convert(utf8.encode(date))
        .bytes;
    var SecretService =
        Hmac(sha256, SecretDate).convert(utf8.encode("tts")).bytes;
    var SecretSigning =
        Hmac(sha256, SecretService).convert(utf8.encode("tc3_request")).bytes;
    String Signature = Hmac(sha256, SecretSigning)
        .convert(utf8.encode(StringToSign))
        .toString()
        .toLowerCase();
    String Authorization =
        "$Algorithm Credential=$SecretId/$CredentialScope, SignedHeaders=$SignedHeaders, Signature=$Signature";
    Map<String, String> requestHeader = {
      "Host": "tts.tencentcloudapi.com",
      "Content-Type": contentType,
      "X-TC-Version": "2019-08-23",
      "X-TC-Region": "ap-shanghai",
      "X-TC-Action": "CreateTtsTask",
      "X-TC-Timestamp": Timestamp,
      "Authorization": Authorization
    };
    var response = await http.post(Uri.parse("https://tts.tencentcloudapi.com"),
        body: jsonRequestBody, headers: requestHeader);
    var utf8ResponseBody = utf8.decode(response.bodyBytes);
    Map<String, dynamic> responseBody = jsonDecode(utf8ResponseBody);
    print(responseBody);
    Map<String, dynamic> responseBody2 = responseBody["Response"];
    Map<String, dynamic> data = responseBody2["Data"];
    String taskId = data["TaskId"];
    bool flag = true;
    while (flag) {
      queryResult(taskId).then((value) {
        if (value != "error") {
          PlayAudio.play(value);
          flag = false;
        }
      });
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  static Future<String> queryResult(String taskId) async {
    var dateTime = DateTime.now().toUtc();
    var date = "${dateTime.year}-${dateTime.month}-${dateTime.day}";
    var Timestamp = dateTime.millisecondsSinceEpoch.toString().substring(0, 10);
    var Algorithm = "TC3-HMAC-SHA256";
    var CredentialScope = "$date/tts/tc3_request";
    String SecretKey = "Ulqma9C5mGWhkkfOtBYuBKGxPi5Tipmj";
    String SecretId = "AKIDxkIbjfOvG4f17zhCRSFmDMPK3Zu1uZ9i";

    String HTTPRequestMethod = "POST";
    String CanonicalURI = "/";
    String CanonicalQueryString = "";
    String contentType = "application/json; charset=utf-8";
    String CanonicalHeaders =
        "content-type:$contentType\nhost:tts.tencentcloudapi.com\n";
    String SignedHeaders = "content-type;host";
    var requestBody = {"TaskId": taskId};
    var jsonRequestBody = jsonEncode(requestBody);
    String HashedRequestPayload =
        sha256.convert(utf8.encode(jsonRequestBody)).toString().toLowerCase();
    String CanonicalRequest =
        "$HTTPRequestMethod\n$CanonicalURI\n$CanonicalQueryString\n$CanonicalHeaders\n$SignedHeaders\n$HashedRequestPayload";
    String HashedCanonicalRequest =
        sha256.convert(utf8.encode(CanonicalRequest)).toString().toLowerCase();
    String StringToSign =
        "$Algorithm\n$Timestamp\n$CredentialScope\n$HashedCanonicalRequest";

    var SecretDate = Hmac(sha256, utf8.encode("TC3$SecretKey"))
        .convert(utf8.encode(date))
        .bytes;
    var SecretService =
        Hmac(sha256, SecretDate).convert(utf8.encode("tts")).bytes;
    var SecretSigning =
        Hmac(sha256, SecretService).convert(utf8.encode("tc3_request")).bytes;
    String Signature = Hmac(sha256, SecretSigning)
        .convert(utf8.encode(StringToSign))
        .toString()
        .toLowerCase();
    String Authorization =
        "$Algorithm Credential=$SecretId/$CredentialScope, SignedHeaders=$SignedHeaders, Signature=$Signature";
    Map<String, String> requestHeader = {
      "Host": "tts.tencentcloudapi.com",
      "Content-Type": contentType,
      "X-TC-Version": "2019-08-23",
      "X-TC-Region": "ap-shanghai",
      "X-TC-Action": "DescribeTtsTaskStatus",
      "X-TC-Timestamp": Timestamp,
      "Authorization": Authorization
    };
    var response = await http.post(Uri.parse("https://tts.tencentcloudapi.com"),
        body: jsonRequestBody, headers: requestHeader);
    var utf8ResponseBody = utf8.decode(response.bodyBytes);
    Map<String, dynamic> responseBody = jsonDecode(utf8ResponseBody);
    print(responseBody);
    Map<String, dynamic> responseBody2 = responseBody["Response"];
    Map<String, dynamic> data = responseBody2["Data"];
    if (data["StatusStr"] == "success") {
      return data["ResultUrl"];
    } else {
      return "error";
    }
  }
}
