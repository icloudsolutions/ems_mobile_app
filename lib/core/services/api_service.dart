import 'package:odoo_rpc/odoo_rpc.dart';
import '../config/app_config.dart';

class ApiService {
  OdooClient? _client;
  String? _baseUrl;
  OdooSession? _session;

  ApiService() {
    // Initialize with default URL, will be updated on login
    _baseUrl = AppConfig.baseUrl;
  }

  /// Initialize or update the Odoo client with new URL and database
  void updateBaseUrl(String baseUrl, String database) {
    _baseUrl = baseUrl;
    
    // Create or update client with new URL
    _client ??= OdooClient(
      baseUrl,
      sessionId: _session,
    );
    
    if (_client!.baseURL != baseUrl) {
      _client = OdooClient(
        baseUrl,
        sessionId: _session,
      );
    }
  }

  /// Set the session after authentication
  void setSession(OdooSession session, {String? password}) {
    _session = session;
    if (_client != null) {
      // Update existing client with new session
      _client = OdooClient(
        _client!.baseURL,
        sessionId: session,
      );
    }
  }

  /// Clear the session
  void clearSession() {
    _session = null;
    if (_client != null) {
      _client!.close();
      _client = null;
    }
  }

  /// Get the Odoo client (creates if needed)
  OdooClient get client {
    if (_client == null) {
      _client = OdooClient(
        _baseUrl ?? AppConfig.baseUrl,
        sessionId: _session,
      );
    }
    return _client!;
  }

  /// Call RPC method (for execute_kw)
  Future<dynamic> callRPC(String model, String method, List<dynamic> args, {Map<String, dynamic>? kwargs}) async {
    try {
      return await client.callKw({
        'model': model,
        'method': method,
        'args': args,
        'kwargs': kwargs ?? {},
      });
    } on OdooException catch (e) {
      throw Exception('API call failed: ${e.message}');
    } catch (e) {
      throw Exception('API call failed: ${e.toString()}');
    }
  }

  /// Search and read records
  Future<dynamic> searchRead(
    String model, {
    List<List<dynamic>>? domain,
    List<String>? fields,
    int? limit,
    int? offset,
    String? order,
  }) async {
    // Odoo search_read signature: search_read(domain, fields, kwargs)
    final args = [
      domain ?? [],
      fields ?? [],
    ];
    
    final kwargs = <String, dynamic>{};
    if (limit != null) kwargs['limit'] = limit;
    if (offset != null) kwargs['offset'] = offset;
    if (order != null) kwargs['order'] = order;

    return await callRPC(model, 'search_read', args, kwargs: kwargs);
  }

  /// Create a new record
  Future<int> create(String model, Map<String, dynamic> values) async {
    final result = await callRPC(model, 'create', [[values]]);
    return result as int;
  }

  /// Update records
  Future<bool> write(String model, List<int> ids, Map<String, dynamic> values) async {
    await callRPC(model, 'write', [ids, values]);
    return true;
  }

  /// Delete records
  Future<bool> unlink(String model, List<int> ids) async {
    await callRPC(model, 'unlink', [ids]);
    return true;
  }

  /// Read records
  Future<List<dynamic>> read(String model, List<int> ids, {List<String>? fields}) async {
    // Odoo read signature: read(ids, fields)
    final args = [
      ids,
      fields ?? [],
    ];
    return await callRPC(model, 'read', args) as List;
  }

  /// Authenticate with Odoo
  Future<OdooSession> authenticate(String database, String username, String password) async {
    try {
      final session = await client.authenticate(database, username, password);
      _session = session;
      return session;
    } on OdooException catch (e) {
      throw Exception('Authentication failed: ${e.message}');
    } catch (e) {
      throw Exception('Authentication failed: ${e.toString()}');
    }
  }

  /// Check if session is valid
  Future<bool> checkSession() async {
    try {
      await client.checkSession();
      return true;
    } on OdooSessionExpiredException {
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get session stream for tracking session changes
  Stream<OdooSession> get sessionStream => client.sessionStream;

  /// Get login stream (for web platform)
  Stream<OdooLoginEvent> get loginStream => client.loginStream;
}
