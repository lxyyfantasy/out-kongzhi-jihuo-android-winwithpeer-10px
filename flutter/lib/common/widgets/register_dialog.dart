import 'package:flutter/material.dart';
import 'package:flutter_hbb/common.dart';
import 'package:flutter_hbb/common/widgets/account_api.dart';
import 'package:flutter_hbb/common/widgets/dialog.dart';
import 'package:get/get.dart';

/// 打开注册弹窗。返回 true 表示注册成功。
Future<bool?> registerDialog() async {
  final username = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();

  String? usernameMsg;
  String? passwordMsg;
  String? confirmMsg;
  var isInProgress = false;

  final res = await gFFI.dialogManager.show<bool>((setState, close, context) {
    onCancel() {
      if (isInProgress) return;
      close(false);
    }

    onSubmit() async {
      final u = username.text.trim();
      final p = password.text;
      final c = confirm.text;

      usernameMsg = null;
      passwordMsg = null;
      confirmMsg = null;

      if (u.isEmpty) {
        setState(() => usernameMsg = translate('账号不能为空'));
        return;
      }
      if (p.isEmpty) {
        setState(() => passwordMsg = translate('密码不能为空'));
        return;
      }
      if (p.length < 6) {
        setState(() => passwordMsg = translate('密码太短'));
        return;
      }
      if (p != c) {
        setState(() => confirmMsg = translate('密码不一致'));
        return;
      }

      setState(() => isInProgress = true);
      try {
        final r = await AccountApi.register(u, p);
        if (r.code == 'OK') {
          close(true);
          return;
        }
        if (r.code == 'DUPLICATE') {
          setState(() => usernameMsg = translate('账号重复请重新设置'));
        } else if (r.code == 'BAD_REQUEST') {
          setState(() => usernameMsg = translate('账号或密码格式不正确'));
        } else {
          setState(() => passwordMsg = translate('网络异常，请稍后重试'));
        }
      } catch (_) {
        setState(() => passwordMsg = translate('网络异常，请稍后重试'));
      }
      setState(() => isInProgress = false);
    }

    final title = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(translate('注册')).marginOnly(top: MyTheme.dialogPadding),
        InkWell(
          child: Icon(
            Icons.close,
            size: 25,
            color: Theme.of(context)
                .textTheme
                .titleLarge
                ?.color
                ?.withOpacity(0.55),
          ),
          onTap: onCancel,
        ).marginOnly(top: 10, right: 15),
      ],
    );

    return CustomAlertDialog(
      title: title,
      titlePadding: EdgeInsets.fromLTRB(MyTheme.dialogPadding, 0, 0, 0),
      contentBoxConstraints: BoxConstraints(minWidth: 400),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 8),
          DialogTextField(
            title: translate(DialogTextField.kUsernameTitle),
            controller: username,
            prefixIcon: DialogTextField.kUsernameIcon,
            errorText: usernameMsg,
          ),
          PasswordWidget(
            controller: password,
            autoFocus: false,
            reRequestFocus: true,
            errorText: passwordMsg,
          ),
          PasswordWidget(
            title: translate('确认密码'),
            controller: confirm,
            autoFocus: false,
            reRequestFocus: true,
            errorText: confirmMsg,
          ),
          if (isInProgress) const LinearProgressIndicator(),
          const SizedBox(height: 12),
          SizedBox(
            height: 38,
            width: 200,
            child: ElevatedButton(
              child: Text(translate('注册'), style: TextStyle(fontSize: 16)),
              onPressed: isInProgress ? null : onSubmit,
            ),
          ),
        ],
      ),
      onCancel: onCancel,
      onSubmit: onSubmit,
    );
  });

  if (res == true) {
    showToast(translate('注册成功，待分配'));
  }
  return res;
}