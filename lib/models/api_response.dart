/// Generic API response model
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final int? statusCode;
  final String? error;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.statusCode,
    this.error,
  });

  factory ApiResponse.success(T data, {String? message, int? statusCode}) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.error(String error, {int? statusCode, String? message}) {
    return ApiResponse(
      success: false,
      error: error,
      statusCode: statusCode,
      message: message,
    );
  }

  factory ApiResponse.loading() {
    return ApiResponse(
      success: true,
      message: 'Loading...',
    );
  }

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>)? fromJson) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'],
      statusCode: json['statusCode'],
      error: json['error'],
      data: json['data'] != null && fromJson != null ? fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T)? toJson) {
    final Map<String, dynamic> result = {
      'success': success,
    };

    if (message != null) result['message'] = message;
    if (statusCode != null) result['statusCode'] = statusCode;
    if (error != null) result['error'] = error;
    if (data != null && toJson != null) result['data'] = toJson(data!);

    return result;
  }
}