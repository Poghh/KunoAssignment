import 'package:flutter/widgets.dart';

import 'l10n_extension.dart';

extension ErrorLocalizationExtension on BuildContext {
  String localizeErrorMessage(
    String? rawMessage, {
    String? fallback,
  }) {
    final String defaultFallback = fallback ?? l10n.somethingWentWrongTryAgain;
    if (rawMessage == null || rawMessage.trim().isEmpty) {
      return defaultFallback;
    }

    final String message = rawMessage.trim();
    switch (message) {
      case 'Request failed':
        return l10n.requestFailed;
      case 'Something went wrong. Please try again.':
        return l10n.somethingWentWrongTryAgain;
      case 'Request timeout. Please try again.':
        return l10n.requestTimeoutTryAgain;
      case 'Unable to connect to server. Please check your network.':
        return l10n.networkUnavailableCheckConnection;
      case 'Request cancelled.':
        return l10n.requestCancelled;
      case 'Unauthorized request.':
        return l10n.unauthorizedRequest;
      case 'Forbidden request.':
        return l10n.forbiddenRequest;
      case 'Resource not found.':
        return l10n.resourceNotFound;
      case 'Invalid request data.':
        return l10n.invalidRequestData;
      case 'Unexpected network error.':
        return l10n.unexpectedNetworkError;
      case 'Cannot delete category with existing transactions':
        return l10n.deleteCategoryInUse;
      default:
        break;
    }

    final RegExp serverErrorPattern =
        RegExp(r'^Server error \((\d+)\)\. Please try again later\.$');
    final Match? matched = serverErrorPattern.firstMatch(message);
    if (matched != null) {
      return l10n.serverErrorTryLater(matched.group(1)!);
    }

    return message;
  }
}
