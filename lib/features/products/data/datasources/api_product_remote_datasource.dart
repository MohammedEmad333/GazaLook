import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../models/product_model.dart';
import 'product_remote_datasource.dart';

/// Real catalog source backed by the GazaLook products API (see /backend).
///
/// The endpoints return JSON already in the [ProductModel] shape:
///   GET {base}/api/products        → { ok, data: { products: [ ... ] } }
///   GET {base}/api/products/{id}   → { ok, data: { product: { ... } } }
///
/// This is the single, isolated replacement point the catalog card calls for —
/// the repository, domain and UI layers are untouched. Selection between this
/// and [MockProductRemoteDataSource] happens once in the DI container, based on
/// whether an API base URL is configured.
class ApiProductRemoteDataSource implements ProductRemoteDataSource {
  ApiProductRemoteDataSource({required Dio dio, required String baseUrl})
      : _dio = dio,
        _baseUrl = _stripTrailingSlash(baseUrl);

  final Dio _dio;
  final String _baseUrl;

  @override
  Future<List<ProductModel>> fetchProducts() async {
    try {
      final Response<dynamic> res =
          await _dio.get<dynamic>('$_baseUrl/api/products');
      final List<dynamic> raw = _unwrapList(res.data, 'products');
      return raw
          .map((dynamic e) =>
              ProductModel.fromMap(_asMap(e)))
          .toList(growable: false);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'تعذّر تحميل المنتجات');
    } catch (_) {
      throw const ServerException('استجابة غير صالحة من الخادم');
    }
  }

  @override
  Future<ProductModel> fetchProductById(String id) async {
    try {
      final Response<dynamic> res =
          await _dio.get<dynamic>('$_baseUrl/api/products/$id');
      final Map<String, dynamic> product =
          _asMap(_unwrap(res.data)['product']);
      return ProductModel.fromMap(product);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const ServerException('Product not found');
      }
      throw ServerException(e.message ?? 'تعذّر تحميل المنتج');
    } catch (_) {
      throw const ServerException('استجابة غير صالحة من الخادم');
    }
  }

  /// Returns the `data` object of a `{ ok, data }` envelope.
  Map<String, dynamic> _unwrap(dynamic body) {
    final Map<String, dynamic> map = _asMap(body);
    if (map['ok'] == false) {
      throw ServerException((map['error'] ?? 'Server error').toString());
    }
    return _asMap(map['data']);
  }

  List<dynamic> _unwrapList(dynamic body, String key) {
    final Object? list = _unwrap(body)[key];
    return list is List<dynamic> ? list : const <dynamic>[];
  }

  static Map<String, dynamic> _asMap(dynamic value) =>
      value is Map<String, dynamic>
          ? value
          : Map<String, dynamic>.from(value as Map<dynamic, dynamic>);

  static String _stripTrailingSlash(String url) =>
      url.endsWith('/') ? url.substring(0, url.length - 1) : url;
}
