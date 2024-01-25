import 'package:flutter/material.dart';
import 'package:google_sign_in_web/web_only.dart' as web;

import 'stub.dart';

Widget buildSignInButton({HandleSignInFn? onPressed}) {
  final config = web.GSIButtonConfiguration(
    type: web.GSIButtonType.icon,
    shape: web.GSIButtonShape.pill,
    size: web.GSIButtonSize.large,
  );
  return web.renderButton(configuration: config);
}
