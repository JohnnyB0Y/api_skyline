//  i18n.dart
//
//
//  Created by JohnnyB0Y on 2020/8/6.
//  Copyright © 2020 JohnnyB0Y. All rights reserved.

//  国际化

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

extension LocalizationsContext on BuildContext {
  LocalizationsManager localizationsManager() {
    return Localizations.of<LocalizationsManager>(this, LocalizationsManager)!;
  }
}

class LocalizationsManager {

  // 用于获取全局context
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  late GeneratedLocalizationsDelegate delegate;

  LocalizationsManager() {
    delegate = GeneratedLocalizationsDelegate(this);
    currentLocale = Locale('zh');
  }

  /// 当前的 locale
  late Locale currentLocale;

}

class GeneratedLocalizationsDelegate extends LocalizationsDelegate<LocalizationsManager> {
  LocalizationsManager manager;
  GeneratedLocalizationsDelegate(this.manager);

  @override
  Future<LocalizationsManager> load(Locale locale) {
    this.manager.currentLocale = locale;
    return SynchronousFuture(this.manager);
  }

  @override
  bool isSupported(Locale locale) => true;

  @override
  bool shouldReload(GeneratedLocalizationsDelegate old) => false;

}

String? getLang(Locale? l) => l == null
    ? null
    : l.countryCode != null && l.countryCode!.isEmpty
    ? l.languageCode
    : l.toString();
