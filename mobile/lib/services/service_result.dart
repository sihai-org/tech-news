import '../models/api_response.dart';

// Service Result wrapper
class ServiceResult<T> {
  final T? data;
  final ApiError? error;
  final bool isSuccess;

  const ServiceResult.success(this.data) 
      : error = null, 
        isSuccess = true;

  const ServiceResult.failure(this.error) 
      : data = null, 
        isSuccess = false;
}