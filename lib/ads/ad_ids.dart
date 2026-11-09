import 'package:flutter/foundation.dart';

/// AdMob identifiers. Debug builds always use Google's published test units
/// so a developer never clicks a live ad.
abstract final class AdIds {
  static const _testBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const _testInterstitial = 'ca-app-pub-3940256099942544/1033173712';

  // Real units from the HomiLabs AdMob account (homilabs.smc@gmail.com); see config/admob.json.
  // Still Google's sample units until the LCAT app is created in AdMob: check-release-ad-ids.sh fails until then.
  static const _liveBanner = _testBanner;
  static const _liveInterstitial = _testInterstitial;

  static String get banner => kReleaseMode ? _liveBanner : _testBanner;
  static String get interstitial => kReleaseMode ? _liveInterstitial : _testInterstitial;
}
