import 'dart:collection';

import 'feature_flag/feature_flag_enum.dart';
import 'feature_flag/feature_flag_helper.dart';

class JitsiMeetingOptions {
  final String room;
  final String? serverURL;
  final String? subject;
  final String? token;
  final bool? audioMuted;
  final bool? audioOnly;
  final bool? videoMuted;
  final String? userAvatarURL;
  final String? userDisplayName;
  final String? userEmail;
  final String? iosAppBarRGBAColor;
  final Map<String, Object?>? webOptions; // options for web
  final Map<FeatureFlagEnum, Object?>? featureFlags;
  final Map<String, Object?>? configOverrides;

  JitsiMeetingOptions({
    required this.room,
    this.serverURL,
    this.subject,
    this.token,
    this.audioMuted,
    this.audioOnly,
    this.videoMuted,
    this.userAvatarURL,
    this.userDisplayName,
    this.userEmail,
    this.iosAppBarRGBAColor,
    this.webOptions,
    this.featureFlags,
    this.configOverrides,
  });

  /// Get feature flags Map with keys as String instead of Enum
  /// Useful as an argument sent to the Kotlin/Swift code
  Map<String?, dynamic> getFeatureFlags() {
    Map<String?, dynamic> featureFlagsWithStrings = HashMap();

    featureFlags?.forEach((key, value) {
      featureFlagsWithStrings[FeatureFlagHelper.featureFlags[key]] = value;
    });

    return featureFlagsWithStrings;
  }

  @override
  String toString() {
    return 'OMNI_JITSI - JitsiMeetingOptions { room: $room, serverURL: $serverURL, '
        'subject: $subject, token: $token, audioMuted: $audioMuted, '
        'audioOnly: $audioOnly, videoMuted: $videoMuted, '
        'userDisplayName: $userDisplayName, userEmail: $userEmail }';
  }
}
