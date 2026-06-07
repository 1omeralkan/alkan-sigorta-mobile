import 'package:dio/dio.dart';

class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Bağlantı zaman aşımına uğradı. Lütfen tekrar deneyin.';

        case DioExceptionType.connectionError:
          return 'İnternet bağlantınızı kontrol edin ve tekrar deneyin.';

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode != null) {
            switch (statusCode) {
              case 400:
                return 'Geçersiz istek. Lütfen bilgilerinizi kontrol edin.';
              case 401:
                return 'Oturum süreniz dolmuş. Lütfen tekrar giriş yapın.';
              case 403:
                return 'Bu işlem için yetkiniz bulunmuyor.';
              case 404:
                return 'İstenilen kaynak bulunamadı.';
              case 500:
              case 502:
              case 503:
                return 'Sunucu hatası. Lütfen daha sonra tekrar deneyin.';
              default:
                return 'Bir hata oluştu. (Kod: $statusCode)';
            }
          }
          return error.response?.data['message'] ?? 'Bir hata oluştu.';

        case DioExceptionType.cancel:
          return 'İstek iptal edildi.';

        case DioExceptionType.unknown:
          if (error.message?.contains('SocketException') ?? false) {
            return 'İnternet bağlantınızı kontrol edin.';
          }
          return 'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.';

        default:
          return 'Bir hata oluştu. Lütfen tekrar deneyin.';
      }
    }

    return error.toString();
  }
}
