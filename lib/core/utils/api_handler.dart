import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:evento_core/core/models/api_data.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as path;

class ApiHandler {
  static const _baseUrl = 'https://eventotracker.com';
  // static const _baseUrl = 'http://www.eventotracker.com/';
  // static String midpathApi = '/api/v3/api.cfm/';
  static String midpathApi = '/cdn/config/';
  static late Dio _dio;

  static Future<void> init() async {
    _dio = Dio();
  }

  static Future<ApiData> postHttp(
      {String endPoint = '',
      required dynamic body,
      Map<String, dynamic>? header,
      String? baseUrl}) async {
    try {
      debugPrint(baseUrl ?? (_baseUrl + midpathApi + endPoint));

      final response = await _dio.post(
        baseUrl ?? (_baseUrl + midpathApi + endPoint),
        options: Options(
          headers: header ?? {'content-Type': 'application/json'},
        ),
        data: body,
      );
      return ApiData(
          data: response.data,
          statusCode: response.statusCode,
          statusMessage: response.statusMessage);
    } on DioException catch (e) {
      FirebaseCrashlytics.instance.recordError(e, e.stackTrace, reason: {
        'url': baseUrl ?? (_baseUrl + midpathApi + endPoint),
        'data': body,
        'error': e.response?.data ?? e.response?.statusMessage ?? ''
      });
      FirebaseCrashlytics.instance
          .recordError(e, e.stackTrace, reason: e.message);
      debugPrint(e.toString());
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
      FirebaseCrashlytics.instance.recordError(e, e.stackTrace, reason: {
        'url': baseUrl,
        'data': e,
        'error': e.response?.data ?? e.response?.statusMessage ?? ''
      });
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
      debugPrint(baseUrl);
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
      return ApiData(
          data: response.data,
          statusCode: response.statusCode,
          statusMessage: response.statusMessage);
    } on DioException catch (e) {
      FirebaseCrashlytics.instance.recordError(e, e.stackTrace, reason: {
        'url': url,
        'error': e.response?.data ?? e.response?.statusMessage ?? ''
      });
      debugPrint(e.toString());
      return ApiData(
          data: e.response?.data ?? {},
          statusCode: e.response?.statusCode ?? 500,
          statusMessage: e.response?.statusMessage ?? 'Error');
    } on TimeoutException catch (e) {
      return ApiData(data: {}, statusCode: 500, statusMessage: 'Error');
    }
  }

  static Future<ApiData> getHttp(
      {required String endPoint,
      String? params,
      Map<String, dynamic>? header}) async {
    params = params == null ? '' : '/$params';
    debugPrint(_baseUrl + midpathApi + endPoint + params);
    try {
      final response = await _dio.get(
        _baseUrl + midpathApi + endPoint + params,
        options: Options(
          headers: header ?? {'content-Type': 'application/json'},
        ),
      );
      return ApiData(
          data: response.data,
          statusCode: response.statusCode,
          statusMessage: response.statusMessage);
    } on DioException catch (e) {
      FirebaseCrashlytics.instance.recordError(e, e.stackTrace, reason: {
        'url': _baseUrl + midpathApi + endPoint + params,
        'error': e.response?.data ?? e.response?.statusMessage ?? ''
      });
      debugPrint(e.toString());
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
    try {
      final response = await _dio.put(
        _baseUrl + midpathApi + endPoint,
        options: Options(
          headers: header ?? {'content-Type': 'application/json'},
        ),
        data: body,
      );
      return ApiData(
          data: response.data,
          statusCode: response.statusCode,
          statusMessage: response.statusMessage);
    } on DioException catch (e) {
      FirebaseCrashlytics.instance.recordError(e, e.stackTrace, reason: {
        'url': _baseUrl + midpathApi + endPoint,
        'data': body,
        'error': e.response?.data ?? e.response?.statusMessage ?? ''
      });
      debugPrint(e.toString());
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
    try {
      debugPrint(baseUrl ?? (_baseUrl + midpathApi + endPoint));

      final response = await _dio.delete(
        baseUrl ?? (_baseUrl + midpathApi + endPoint),
        data: body,
        options: Options(
          headers: header ?? {'content-Type': 'application/json'},
        ),
      );
      return ApiData(
          data: response.data,
          statusCode: response.statusCode,
          statusMessage: response.statusMessage);
    } on DioException catch (e) {
      FirebaseCrashlytics.instance.recordError(e, e.stackTrace, reason: {
        'url': _baseUrl + midpathApi + endPoint + params,
        'error': e.response?.data ?? e.response?.statusMessage ?? ''
      });
      debugPrint(e.toString());
      return ApiData(
          data: e.response?.data ?? {},
          statusCode: e.response?.statusCode ?? 500,
          statusMessage: e.response?.statusMessage ?? 'Error');
    }
  }
}
