import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:evento_core/core/models/api_data.dart';
import 'package:evento_core/core/utils/logger.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as path;

class ApiHandler {
  static const _baseUrl = 'https://eventotracker.com';
  static String midpathApi = '/api/v3/api.cfm/';
  static late Dio _dio;

  static Future<void> init() async {
    _dio = Dio();
  }

  static Future<ApiData> postHttp(
      {String endPoint = '',
      required dynamic body,
      int? timeout,
      Map<String, dynamic>? header,
      String? baseUrl}) async {
    final url = baseUrl ?? (_baseUrl + midpathApi + endPoint);
    Logger.i('POST Request to: $url');
    Logger.d('Request Body: $body');
    Logger.d('Request Headers: $header');

    try {
      final response = await _dio
          .post(
            url,
            options: Options(
              headers: header ?? {'content-Type': 'application/json'},
            ),
            data: body,
          )
          .timeout(Duration(seconds: timeout ?? 10));

      Logger.i('POST Response from: $url');
      Logger.d('Response Data: ${response.data}');
      return ApiData(
          data: response.data,
          statusCode: response.statusCode,
          statusMessage: response.statusMessage);
    } on DioException catch (e) {
      Logger.e('POST Error for $url: ${e.response?.data ?? e.message}');
      FirebaseCrashlytics.instance.recordError(e, e.stackTrace, reason: {
        'url': url,
        'data': body,
        'error': e.response?.data ?? e.response?.statusMessage ?? ''
      });
      return ApiData(
          data: e.response?.data ?? {},
          statusCode: e.response?.statusCode ?? 500,
          statusMessage: e.response?.statusMessage ?? 'Error');
    }
  }

  static Future<ApiData> patchHttp(
      {String endPoint = '',
      required dynamic body,
      Map<String, dynamic>? header,
      String? baseUrl}) async {
    final url = baseUrl ?? (_baseUrl + midpathApi + endPoint);
    Logger.i('PATCH Request to: $url');
    Logger.d('Request Body: $body');
    Logger.d('Request Headers: $header');

    try {
      final response = await _dio
          .patch(
            url,
            options: Options(
              headers: header ?? {'content-Type': 'application/json'},
            ),
            data: body,
          )
          .timeout(const Duration(seconds: 10));

      Logger.i('PATCH Response from: $url');
      Logger.d('Response Data: ${response.data}');
      return ApiData(
          data: response.data,
          statusCode: response.statusCode,
          statusMessage: response.statusMessage);
    } on DioException catch (e) {
      Logger.e('PATCH Error for $url: ${e.response?.data ?? e.message}');
      FirebaseCrashlytics.instance.recordError(e, e.stackTrace, reason: {
        'url': url,
        'data': body,
        'error': e.response?.data ?? e.response?.statusMessage ?? ''
      });
      return ApiData(
          data: e.response?.data ?? {},
          statusCode: e.response?.statusCode ?? 500,
          statusMessage: e.response?.statusMessage ?? 'Error');
    }
  }

  static Future<ApiData> downloadImageFile({required String baseUrl}) async {
    try {
      debugPrint(baseUrl);
      final docDir = await path.getApplicationDocumentsDirectory();
      final savePath =
          '${docDir.path}${Platform.pathSeparator}event_splash.png';
      final response = await _dio.download(baseUrl, savePath);
      return ApiData(
          data: {
            'file_path': savePath,
          },
          statusCode: response.statusCode,
          statusMessage: response.statusMessage);
    } on DioException catch (e) {
      debugPrint('$baseUrl STATUS CODE: ${e.response?.statusCode}');
      FirebaseCrashlytics.instance.recordError(e, e.stackTrace, reason: {
        'url': baseUrl,
        'data': e,
        'error': e.response?.data ?? e.response?.statusMessage ?? ''
      });
      debugPrint('$baseUrl STATUS CODE: ${e.response?.statusCode}');
      FirebaseCrashlytics.instance
          .recordError(e, e.stackTrace, reason: e.message);
      debugPrint(e.toString());
      return ApiData(
          data: e.response?.data ??
              {
                'file_path': 'DEFAULT',
              },
          statusCode: e.response?.statusCode ?? 500,
          statusMessage: e.response?.statusMessage ?? 'Error');
    }
  }

  static Future<ApiData> downloadFile({required String baseUrl}) async {
    try {
      final docDir = await path.getApplicationDocumentsDirectory();
      Uri uri = Uri.parse(baseUrl);
      final fileName = p.basename(uri.path);
      final savePath = '${docDir.path}${Platform.pathSeparator}$fileName';
      final response = await _dio.download(baseUrl, savePath);
      return ApiData(
          data: {
            'file_path': savePath,
          },
          statusCode: response.statusCode,
          statusMessage: response.statusMessage);
    } on DioException catch (e) {
      FirebaseCrashlytics.instance.recordError(e, e.stackTrace, reason: {
        'url': baseUrl,
        'data': e,
        'error': e.response?.data ?? e.response?.statusMessage ?? ''
      });
      debugPrint('$baseUrl STATUS CODE: ${e.response?.statusCode}');
      FirebaseCrashlytics.instance
          .recordError(e, e.stackTrace, reason: e.message);
      debugPrint(e.toString());
      return ApiData(
          data: e.response?.data ??
              {
                'file_path': 'DEFAULT',
              },
          statusCode: e.response?.statusCode ?? 500,
          statusMessage: e.response?.statusMessage ?? 'Error');
    }
  }

  static Future<ApiData> genericGetHttp(
      {required String url,
      Map<String, dynamic>? header,
      Options? options,
      Duration? apiTimeout}) async {
    Logger.i('GET Request to: $url');
    Logger.d('Request Headers: $header');

    try {
      final response = await _dio
          .get(
            url,
            options: options ??
                Options(
                  headers: header ?? {'content-Type': 'application/json'},
                ),
          )
          .timeout(apiTimeout ?? const Duration(seconds: 30));

      Logger.i('GET Response from: $url');
      Logger.d('Response Data: ${response.data}');
      return ApiData(
          data: response.data,
          statusCode: response.statusCode,
          statusMessage: response.statusMessage);
    } on DioException catch (e) {
      Logger.e('GET Error for $url: ${e.response?.data ?? e.message}');
      FirebaseCrashlytics.instance.recordError(e, e.stackTrace, reason: {
        'url': url,
        'error': e.response?.data ?? e.response?.statusMessage ?? ''
      });
      return ApiData(
          data: e.response?.data ?? {},
          statusCode: e.response?.statusCode ?? 500,
          statusMessage: e.response?.statusMessage ?? 'Error');
    } on TimeoutException catch (e) {
      Logger.e('GET Timeout for $url: $e');
      return ApiData(data: {}, statusCode: 500, statusMessage: 'Error');
    }
  }

  static Future<ApiData> getHttp(
      {required String endPoint,
      String? params,
      Map<String, dynamic>? header}) async {
    params = params == null ? '' : '/$params';
    final url = _baseUrl + midpathApi + endPoint + params;
    Logger.i('GET Request to: $url');
    Logger.d('Request Headers: $header');

    try {
      final response = await _dio.get(
        url,
        options: Options(
          headers: header ?? {'content-Type': 'application/json'},
        ),
      );

      Logger.i('GET Response from: $url');
      Logger.d('Response Data: ${response.data}');
      return ApiData(
          data: response.data,
          statusCode: response.statusCode,
          statusMessage: response.statusMessage);
    } on DioException catch (e) {
      Logger.e('GET Error for $url: ${e.response?.data ?? e.message}');
      FirebaseCrashlytics.instance.recordError(e, e.stackTrace, reason: {
        'url': url,
        'error': e.response?.data ?? e.response?.statusMessage ?? ''
      });
      return ApiData(
          data: e.response?.data ?? {},
          statusCode: e.response?.statusCode ?? 500,
          statusMessage: e.response?.statusMessage ?? 'Error');
    }
  }

  static Future<ApiData> putHttp(
      {required String endPoint,
      dynamic body,
      Map<String, dynamic>? header,
      String? baseUrl}) async {
    final url = baseUrl ?? (_baseUrl + midpathApi + endPoint);
    Logger.i('PUT Request to: $url');
    Logger.d('Request Body: $body');
    Logger.d('Request Headers: $header');

    try {
      final response = await _dio.put(
        url,
        options: Options(
          headers: header ?? {'content-Type': 'application/json'},
        ),
        data: body,
      );

      Logger.i('PUT Response from: $url');
      Logger.d('Response Data: ${response.data}');
      return ApiData(
          data: response.data,
          statusCode: response.statusCode,
          statusMessage: response.statusMessage);
    } on DioException catch (e) {
      Logger.e('PUT Error for $url: ${e.response?.data ?? e.message}');
      FirebaseCrashlytics.instance.recordError(e, e.stackTrace, reason: {
        'url': url,
        'data': body,
        'error': e.response?.data ?? e.response?.statusMessage ?? ''
      });
      return ApiData(
          data: e.response?.data ?? {},
          statusCode: e.response?.statusCode ?? 500,
          statusMessage: e.response?.statusMessage ?? 'Error');
    }
  }

  static Future<ApiData> deleteHttp(
      {required String endPoint,
      required dynamic body,
      String? params,
      Map<String, dynamic>? header,
      String? baseUrl}) async {
    params = params == null ? '' : '/$params';
    final url = baseUrl ?? (_baseUrl + midpathApi + endPoint);
    Logger.i('DELETE Request to: $url');
    Logger.d('Request Body: $body');
    Logger.d('Request Headers: $header');

    try {
      final response = await _dio.delete(
        url,
        data: body,
        options: Options(
          headers: header ?? {'content-Type': 'application/json'},
        ),
      );

      Logger.i('DELETE Response from: $url');
      Logger.d('Response Data: ${response.data}');
      return ApiData(
          data: response.data,
          statusCode: response.statusCode,
          statusMessage: response.statusMessage);
    } on DioException catch (e) {
      Logger.e('DELETE Error for $url: ${e.response?.data ?? e.message}');
      FirebaseCrashlytics.instance.recordError(e, e.stackTrace, reason: {
        'url': url,
        'error': e.response?.data ?? e.response?.statusMessage ?? ''
      });
      return ApiData(
          data: e.response?.data ?? {},
          statusCode: e.response?.statusCode ?? 500,
          statusMessage: e.response?.statusMessage ?? 'Error');
    }
  }
}
