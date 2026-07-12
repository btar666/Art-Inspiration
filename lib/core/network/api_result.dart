import 'api_exception.dart';

/// نتيجة آمنة للعمليات — بدلاً من ابتلاع الأخطاء بصمت
sealed class ApiResult<T> {
  const ApiResult();

  bool get isSuccess => this is ApiSuccess<T>;
  bool get isFailure => this is ApiFailure<T>;

  T? get dataOrNull => switch (this) {
        ApiSuccess<T>(:final data) => data,
        ApiFailure<T>() => null,
      };

  ApiException? get errorOrNull => switch (this) {
        ApiSuccess<T>() => null,
        ApiFailure<T>(:final error) => error,
      };

  R when<R>({
    required R Function(T data) success,
    required R Function(ApiException error) failure,
  }) =>
      switch (this) {
        ApiSuccess<T>(:final data) => success(data),
        ApiFailure<T>(:final error) => failure(error),
      };
}

final class ApiSuccess<T> extends ApiResult<T> {
  const ApiSuccess(this.data);
  final T data;
}

final class ApiFailure<T> extends ApiResult<T> {
  const ApiFailure(this.error);
  final ApiException error;
}
