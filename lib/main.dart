import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

part 'core/constants.dart';
part 'core/api_service.dart';
part 'models/helpers.dart';
part 'providers/auth_provider.dart';
part 'screens/account_screen.dart';
part 'screens/app.dart';
part 'screens/archive_screen.dart';
part 'screens/detail_screen.dart';
part 'screens/home_screen.dart';
part 'screens/madrasha_detail_screen.dart';
part 'screens/main_shell.dart';
part 'screens/pdf_reader_screen.dart';
part 'screens/static_screens.dart';
part 'widgets/common_widgets.dart';
part 'widgets/detail_widgets.dart';
part 'widgets/event_widgets.dart';
part 'widgets/institution_widgets.dart';

void main() {
  runApp(const ShahpurApp());
}
