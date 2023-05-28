import 'dart:collection';

import 'feature_flag_enum.dart';
import 'feature_flag_helper.dart';

class FeatureFlag {
  bool? addPeopleEnabled;
  bool? audioFocusDisabled;
  bool? audioMuteButtonEnabled;
  bool? audioOnlyButtonEnabled;
  bool? calendarEnabled;
  bool? callIntegrationEnabled;
  bool? carModeEnabled;
  bool? closeCaptionsEnabled;
  bool? conferenceTimerEnabled;
  bool? chatEnabled;
  bool? filmstripEnabled;
  bool? fullscreenEnabled;
  bool? helpButtonEnabled;
  bool? inviteEnabled;
  bool? iOSRecordingEnabled;
  bool? iOSScreenSharingEnabled;
  bool? androidScreenSharingEnabled;
  bool? speakerStatsEnabled;
  bool? kickOutEnabled;
  bool? liveStreamingEnabled;
  bool? lobbyModeEnabled;
  bool? meetingNameEnabled;
  bool? meetingPasswordEnabled;
  bool? notificationsEnabled;
  bool? overflowMenuEnabled;
  bool? pipEnabled;
  bool? prejoinPageEnabled;
  bool? raiseHandEnabled;
  bool? reactionsEnabled;
  bool? recordingEnabled;
  bool? replaceParticipant;
  int? _resolution;
  bool? securityOptionsEnabled;
  bool? serverURLChangeEnabled;
  bool? settingsEnabled;
  bool? tileViewEnabled;
  bool? toolboxAlwaysVisible;
  bool? toolboxEnabled;
  bool? videoMuteButtonEnabled;
  bool? videoShareButtonEnabled;
  bool? welcomePageEnabled;

  int? get resoulution {
    return _resolution;
  }

  set resolution(int videoResolution) {
    assert(
        videoResolution == FeatureFlagVideoResolution.LD_RESOLUTION ||
            videoResolution == FeatureFlagVideoResolution.MD_RESOLUTION ||
            videoResolution == FeatureFlagVideoResolution.SD_RESOLUTION ||
            videoResolution == FeatureFlagVideoResolution.HD_RESOLUTION,
        """Use FeatureFlagVideoResolution.LD_RESOLUTION for 180p\n
        Use FeatureFlagVideoResolution.MD_RESOLUTION for 360p\n
        Use FeatureFlagVideoResolution.SD_RESOLUTION for 480p\n
        Use FeatureFlagVideoResolution.HD_RESOLUTION for 720p""");
    _resolution = videoResolution;
  }

  Map<String?, dynamic> allFeatureFlags() {
    Map<String?, dynamic> featureFlags = new HashMap();

    if (addPeopleEnabled != null)
      featureFlags[FeatureFlagHelper
          .featureFlags[FeatureFlagEnum.ADD_PEOPLE_ENABLED]] = addPeopleEnabled;

    if (audioFocusDisabled != null)
      featureFlags[FeatureFlagHelper
              .featureFlags[FeatureFlagEnum.AUDIO_FOCUS_DISABLED]] =
          audioFocusDisabled;

    if (audioMuteButtonEnabled != null)
      featureFlags[FeatureFlagHelper
              .featureFlags[FeatureFlagEnum.AUDIO_MUTE_BUTTON_ENABLED]] =
          audioMuteButtonEnabled;

    if (audioOnlyButtonEnabled != null)
      featureFlags[FeatureFlagHelper
              .featureFlags[FeatureFlagEnum.AUDIO_ONLY_BUTTON_ENABLED]] =
          audioOnlyButtonEnabled;

    if (calendarEnabled != null)
      featureFlags[FeatureFlagHelper
          .featureFlags[FeatureFlagEnum.CALENDAR_ENABLED]] = calendarEnabled;

    if (callIntegrationEnabled != null)
      featureFlags[FeatureFlagHelper
              .featureFlags[FeatureFlagEnum.CALL_INTEGRATION_ENABLED]] =
          callIntegrationEnabled;

    if (carModeEnabled != null)
      featureFlags[FeatureFlagHelper
          .featureFlags[FeatureFlagEnum.CAR_MODE_ENABLED]] = carModeEnabled;

    if (closeCaptionsEnabled != null)
      featureFlags[FeatureFlagHelper
              .featureFlags[FeatureFlagEnum.CLOSE_CAPTIONS_ENABLED]] =
          closeCaptionsEnabled;

    if (conferenceTimerEnabled != null)
      featureFlags[FeatureFlagHelper
              .featureFlags[FeatureFlagEnum.CONFERENCE_TIMER_ENABLED]] =
          conferenceTimerEnabled;

    if (chatEnabled != null)
      featureFlags[FeatureFlagHelper
          .featureFlags[FeatureFlagEnum.CHAT_ENABLED]] = chatEnabled;

    if (filmstripEnabled != null)
      featureFlags[FeatureFlagHelper
          .featureFlags[FeatureFlagEnum.FILMSTRIP_ENABLED]] = filmstripEnabled;

    if (fullscreenEnabled != null)
      featureFlags[FeatureFlagHelper
              .featureFlags[FeatureFlagEnum.FULLSCREEN_ENABLED]] =
          fullscreenEnabled;

    if (helpButtonEnabled != null)
      featureFlags[FeatureFlagHelper
              .featureFlags[FeatureFlagEnum.HELP_BUTTON_ENABLED]] =
          helpButtonEnabled;

    if (inviteEnabled != null)
      featureFlags[FeatureFlagHelper
          .featureFlags[FeatureFlagEnum.INVITE_ENABLED]] = inviteEnabled;

    if (iOSRecordingEnabled != null)
      featureFlags[FeatureFlagHelper
              .featureFlags[FeatureFlagEnum.IOS_RECORDING_ENABLED]] =
          iOSRecordingEnabled;

    if (iOSScreenSharingEnabled != null)
      featureFlags[FeatureFlagHelper
              .featureFlags[FeatureFlagEnum.IOS_SCREENSHARING_ENABLED]] =
          iOSScreenSharingEnabled;

    if (androidScreenSharingEnabled != null)
      featureFlags[FeatureFlagHelper
              .featureFlags[FeatureFlagEnum.ANDROID_SCREENSHARING_ENABLED]] =
          androidScreenSharingEnabled;

    if (speakerStatsEnabled != null)
      featureFlags[FeatureFlagHelper
              .featureFlags[FeatureFlagEnum.SPEAKERSTATS_ENABLED]] =
          speakerStatsEnabled;

    if (kickOutEnabled != null)
      featureFlags[FeatureFlagHelper
          .featureFlags[FeatureFlagEnum.KICK_OUT_ENABLED]] = kickOutEnabled;

    if (liveStreamingEnabled != null)
      featureFlags[FeatureFlagHelper
              .featureFlags[FeatureFlagEnum.LIVE_STREAMING_ENABLED]] =
          liveStreamingEnabled;

    if (lobbyModeEnabled != null)
      featureFlags[FeatureFlagHelper
          .featureFlags[FeatureFlagEnum.LOBBY_MODE_ENABLED]] = lobbyModeEnabled;

    if (meetingNameEnabled != null)
      featureFlags[FeatureFlagHelper
              .featureFlags[FeatureFlagEnum.MEETING_NAME_ENABLED]] =
          meetingNameEnabled;

    if (meetingPasswordEnabled != null)
      featureFlags[FeatureFlagHelper
              .featureFlags[FeatureFlagEnum.MEETING_PASSWORD_ENABLED]] =
          meetingPasswordEnabled;

    if (notificationsEnabled != null)
      featureFlags[FeatureFlagHelper
              .featureFlags[FeatureFlagEnum.NOTIFICATIONS_ENABLED]] =
          notificationsEnabled;

    if (overflowMenuEnabled != null)
      featureFlags[FeatureFlagHelper
              .featureFlags[FeatureFlagEnum.OVERFLOW_MENU_ENABLED]] =
          overflowMenuEnabled;

    if (pipEnabled != null)
      featureFlags[FeatureFlagHelper
          .featureFlags[FeatureFlagEnum.PIP_ENABLED]] = pipEnabled;

    if (prejoinPageEnabled != null)
      featureFlags[FeatureFlagHelper
              .featureFlags[FeatureFlagEnum.PREJOIN_PAGE_ENABLED]] =
          prejoinPageEnabled;

    if (raiseHandEnabled != null)
      featureFlags[FeatureFlagHelper
          .featureFlags[FeatureFlagEnum.RAISE_HAND_ENABLED]] = raiseHandEnabled;

    if (reactionsEnabled != null)
      featureFlags[FeatureFlagHelper
          .featureFlags[FeatureFlagEnum.REACTIONS_ENABLED]] = reactionsEnabled;

    if (recordingEnabled != null)
      featureFlags[FeatureFlagHelper
          .featureFlags[FeatureFlagEnum.RECORDING_ENABLED]] = recordingEnabled;

    if (replaceParticipant != null)
      featureFlags[FeatureFlagHelper
              .featureFlags[FeatureFlagEnum.REPLACE_PARTICIPANT]] =
          replaceParticipant;

    if (_resolution != null)
      featureFlags[FeatureFlagHelper.featureFlags[FeatureFlagEnum.RESOLUTION]] =
          _resolution;

    if (securityOptionsEnabled != null)
      featureFlags[FeatureFlagHelper
              .featureFlags[FeatureFlagEnum.SECURITY_OPTIONS_ENABLED]] =
          securityOptionsEnabled;

    if (serverURLChangeEnabled != null)
      featureFlags[FeatureFlagHelper
              .featureFlags[FeatureFlagEnum.SERVER_URL_CHANGE_ENABLED]] =
          serverURLChangeEnabled;

    if (settingsEnabled != null)
      featureFlags[FeatureFlagHelper
          .featureFlags[FeatureFlagEnum.SETTINGS_ENABLED]] = settingsEnabled;

    if (tileViewEnabled != null)
      featureFlags[FeatureFlagHelper
          .featureFlags[FeatureFlagEnum.TILE_VIEW_ENABLED]] = tileViewEnabled;

    if (toolboxAlwaysVisible != null)
      featureFlags[FeatureFlagHelper
              .featureFlags[FeatureFlagEnum.TOOLBOX_ALWAYS_VISIBLE]] =
          toolboxAlwaysVisible;

    if (toolboxEnabled != null)
      featureFlags[FeatureFlagHelper
          .featureFlags[FeatureFlagEnum.TOOLBOX_ENABLED]] = toolboxEnabled;

    if (videoMuteButtonEnabled != null)
      featureFlags[FeatureFlagHelper
              .featureFlags[FeatureFlagEnum.VIDEO_MUTE_BUTTON_ENABLED]] =
          videoMuteButtonEnabled;

    if (videoShareButtonEnabled != null)
      featureFlags[FeatureFlagHelper
              .featureFlags[FeatureFlagEnum.VIDEO_SHARE_BUTTON_ENABLED]] =
          videoShareButtonEnabled;

    if (welcomePageEnabled != null)
      featureFlags[FeatureFlagHelper
              .featureFlags[FeatureFlagEnum.WELCOME_PAGE_ENABLED]] =
          welcomePageEnabled;

    return featureFlags;
  }
}

class FeatureFlagVideoResolution {
  /// Video resolution at 180p
  static const LD_RESOLUTION = 180;

  /// Video resolution at 360p
  static const MD_RESOLUTION = 360;

  /// Video resolution at 480p (SD)
  static const SD_RESOLUTION = 480;

  /// Video resolution at 720p (HD)
  static const HD_RESOLUTION = 720;
}
