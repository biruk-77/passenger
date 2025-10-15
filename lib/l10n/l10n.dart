// lib/l10n/l10n.dart (CONTENT TO USE INSTEAD OF ORIGINAL)

import 'package:flutter/widgets.dart';
import 'app_localizations.dart'; // Note: Your file structure may require '../../l10n/app_localizations.dart' if this file is in 'lib/l10n'

// A global variable to hold the latest localizations object
AppLocalizations? l10n;

// ✅ ADD THIS GLOBAL SETTER FUNCTION
void setL10n(AppLocalizations loc) {
  l10n = loc;
}

// A helper widget that you will wrap your MaterialApp with.
// It keeps the `l10n` variable updated whenever the language changes.
class L10nUpdater extends StatefulWidget {
  final Widget child;
  const L10nUpdater({super.key, required this.child});

  @override
  State<L10nUpdater> createState() => _L10nUpdaterState();
}

class _L10nUpdaterState extends State<L10nUpdater> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update the global variable whenever dependencies change (like locale)
    setL10n(AppLocalizations.of(context)!); // Use the global setter
  }

  @override
  Widget build(BuildContext context) {
    // Update it one more time during build, just in case.
    setL10n(AppLocalizations.of(context)!); // Use the global setter
    return widget.child;
  }
}
