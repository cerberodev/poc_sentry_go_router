// Copyright (c) 2023, Very Good Ventures
// https://verygood.ventures
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    log('onChange(${bloc.runtimeType}, $change)');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }
}

Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  Bloc.observer = AppBlocObserver();

  await runZonedGuarded(
    () async {
      await SentryFlutter.init(
        (options) {
          options
            ..dsn =
                'https://3b7cc3ff394246dcbd751be0c5b8360e@o4504516372201472.ingest.sentry.io/4504516373184512'
            ..environment = 'POC'
            ..enableAppLifecycleBreadcrumbs = true
            ..autoAppStart = true
            ..enableAutoNativeBreadcrumbs = true
            ..considerInAppFramesByDefault = false
            ..tracesSampleRate = 1.0
            ..reportPackages = false
            ..platformChecker;
        },
      );

      runApp(await builder());
    },
    (error, stackTrace) async {
      await Sentry.captureException(error, stackTrace: stackTrace);

      log(error.toString(), stackTrace: stackTrace);
    },
  );
}
