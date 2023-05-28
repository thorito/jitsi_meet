import 'package:flutter/material.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'jitsi_meet_options.dart';
import 'jitsi_meet_response.dart';
import 'jitsi_meeting_listener.dart';
import 'method_channel_jitsi_meet.dart';

export 'feature_flag/feature_flag_enum.dart';
export 'feature_flag/feature_flag_helper.dart';
export 'feature_flag/feature_flag_video_resolution.dart';
export 'jitsi_meet_options.dart';
export 'jitsi_meet_response.dart';
export 'jitsi_meeting_listener.dart';

abstract class JitsiMeetPlatform extends PlatformInterface {
  /// Constructs a JitsiMeetPlatform.
  JitsiMeetPlatform() : super(token: _token);

  static final Object _token = Object();

  static JitsiMeetPlatform _instance = MethodChannelJitsiMeet();

  /// The default instance of [JitsiMeetPlatform] to use.
  ///
  /// Defaults to [MethodChannelJitsiMeet].
  static JitsiMeetPlatform get instance => _instance;

  static set instance(JitsiMeetPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Joins a meeting based on the JitsiMeetingOptions passed in.
  /// A JitsiMeetingListener can be attached to this meeting that
  /// will automatically be removed when the meeting has ended
  Future<JitsiMeetingResponse> joinMeeting(JitsiMeetingOptions options,
      {JitsiMeetingListener? listener}) async {
    throw UnimplementedError(
        'OMNI_JITSI: joinMeeting has not been implemented.');
  }

  Future<JitsiMeetingResponse> setAudioMuted(bool isMuted) async {
    throw UnimplementedError(
        'OMNI_JITSI: setAudioMuted has not been implemented.');
  }

  Future<JitsiMeetingResponse> hangUp() async {
    throw UnimplementedError('OMNI_JITSI: hangUp has not been implemented.');
  }

  closeMeeting() {
    throw UnimplementedError(
        'OMNI_JITSI: joinMeeting has not been implemented.');
  }

  /// execute command interface, use only in web
  void executeCommand(String command, List<String> args) {
    throw UnimplementedError(
        'OMNI_JITSI: executeCommand has not been implemented.');
  }

  /// buildView
  /// Method added to support Web plugin, the main purpose is return a <div>
  /// to contain the conferencing screen when start
  /// additionally extra JS can be added using `extraJS` argument
  /// for mobile is not need because the conferecing view get all device screen
  Widget buildView(List<String> extraJS) {
    throw UnimplementedError(
        'OMNI_JITSI: _buildView has not been implemented.');
  }
}
