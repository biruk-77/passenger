// lib/utils/api_exception.dart
import 'package:dio/dio.dart';

/// A custom exception class to handle all API-related errors in a structured way.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() {
    return 'ApiException: $message (Status Code: ${statusCode ?? 'N/A'})';
  }

  /// A factory constructor to create an ApiException from a DioException.
  /// This helps in centralizing error message parsing.
  factory ApiException.fromDioError(DioException dioError) {
    String message = "An unexpected error occurred.";
    if (dioError.response?.data != null && dioError.response!.data is Map) {
      // Try to get the 'message' field from the JSON response body
      message =
          dioError.response!.data['message'] ??
          "Server error without a message.";
    } else {
      switch (dioError.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          message = "Connection timed out. Please check your network.";
          break;
        case DioExceptionType.badResponse:
          message =
              "Received an invalid status code: ${dioError.response?.statusCode}";
          break;
        case DioExceptionType.cancel:
          message = "Request to the server was cancelled.";
          break;
        case DioExceptionType.connectionError:
          message = "Connection error. Please check your internet connection.";
          break;
        case DioExceptionType.unknown:
          message = "An unknown error occurred. Please try again.";
          break;
        default:
          message = "Something went wrong.";
          break;
      }
    }
    return ApiException(message, statusCode: dioError.response?.statusCode);
  }
}
