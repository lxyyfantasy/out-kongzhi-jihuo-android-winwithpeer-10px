import 'dart:async';
import 'dart:convert';

import 'package:flutter_hbb/consts.dart';
import 'package:flutter_hbb/utils/http_service.dart' as http;

class AccountApiResult {
  final String code;
  final String msg;
  AccountApiResult(this.code, this.msg);

  bool get isOk => code == 'OK';

  factory AccountApiResult.fromJson(Map<String, dynamic> json) {
    return AccountApiResult(
      (json['code'] ?? '').toString(),
      (json['msg'] ?? '').toString(),
    );
  }
}

class AccountApi {
  static const _timeout = Duration(seconds: 10);

  static Future<AccountApiResult> register(
      String username, String password) async {
    final base = await kAccountApiBase;
    final resp = await http
        .post(
          Uri.parse('$base/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'username': username, 'password': password}),
        )
        .timeout(_timeout);
    return _parse(resp);
  }

  static Future<AccountApiResult> changePassword(
      String username, String oldPassword, String newPassword) async {
    final base = await kAccountApiBase;
    final resp = await http
        .post(
          Uri.parse('$base/change-password'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'username': username,
            'old_password': oldPassword,
            'new_password': newPassword,
          }),
        )
        .timeout(_timeout);
    return _parse(resp);
  }

  static AccountApiResult _parse(http.Response resp) {
    try {
      final data = jsonDecode(resp.body);
      if (data is Map<String, dynamic>) {
        return AccountApiResult.fromJson(data);
      }
    } catch (_) {}
    return AccountApiResult('SERVER_ERROR', '服务器异常');
  }
}