class ApiResponseModel<T> {
  final bool success;
  final String? message;
  final T? data;
  final Map<String, dynamic>? errors;

  ApiResponseModel({
    required this.success,
    this.message,
    this.data,
    this.errors,
  });

  factory ApiResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    return ApiResponseModel(
      success: json['success'] ?? true,
      message: json['message'],
      data: fromJson != null && json['data'] != null
          ? fromJson(json['data'])
          : null,
      errors: json['errors'],
    );
  }

  factory ApiResponseModel.success({
    String? message,
    T? data,
  }) {
    return ApiResponseModel(
      success: true,
      message: message,
      data: data,
    );
  }

  factory ApiResponseModel.error({
    String? message,
    Map<String, dynamic>? errors,
  }) {
    return ApiResponseModel(
      success: false,
      message: message,
      errors: errors,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
      'errors': errors,
    };
  }
}

class PaginatedResponseModel<T> {
  final List<T> data;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  PaginatedResponseModel({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory PaginatedResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    return PaginatedResponseModel(
      data: (json['data'] as List).map((item) => fromJson(item)).toList(),
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 10,
      total: json['total'] ?? 0,
    );
  }

  bool get hasNextPage => currentPage < lastPage;
  bool get hasPreviousPage => currentPage > 1;
  bool get isEmpty => data.isEmpty;
  bool get isNotEmpty => data.isNotEmpty;
}
