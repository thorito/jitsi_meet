import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'jitsi_meet_platform_interface.dart';

const MethodChannel _methodChannel = MethodChannel('jitsi_meet');
const EventChannel _eventChannel = const EventChannel('jitsi_meet_events');

/// An implementation of [JitsiMeetPlatform] that uses method channels.
class MethodChannelJitsiMeet extends JitsiMeetPlatform {
  bool _eventChannelIsInitialized = false;
  JitsiMeetingListener? _listener;

  @override
  Future<JitsiMeetingResponse> joinMeeting(
    JitsiMeetingOptions options, {
    JitsiMeetingListener? listener,
  }) async {
    _listener = listener;
    if (!_eventChannelIsInitialized) {
      _initialize();
    }

    Map<String, dynamic> _options = {
      'room': options.room.trim(),
      'serverURL': options.serverURL?.trim(),
      'subject': options.subject?.trim(),
      'token': options.token,
      'audioMuted': options.audioMuted,
      'audioOnly': options.audioOnly,
      'videoMuted': options.videoMuted,
      'userAvatarURL': options.userAvatarURL,
      'userDisplayName': options.userDisplayName,
      'userEmail': options.userEmail,
      'iosAppBarRGBAColor': options.iosAppBarRGBAColor,
      'featureFlags': options.getFeatureFlags(),
    };

    return await _methodChannel
        .invokeMethod<String>('joinMeeting', _options)
        .then((message) {
      return JitsiMeetingResponse(isSuccess: true, message: message);
    }).catchError((error) {
      return JitsiMeetingResponse(
        isSuccess: false,
        message: error.toString(),
        error: error,
      );
    });
  }

  @override
  void executeCommand(String command, List<String> args) {}

  @override
  Future<JitsiMeetingResponse> setAudioMuted(bool isMuted) async {
    Map<String, dynamic> _options = {
      'isMuted': isMuted,
    };
    return await _methodChannel
        .invokeMethod<String>('setAudioMuted', _options)
        .then((message) {
      return JitsiMeetingResponse(isSuccess: true, message: message);
    }).catchError((error) {
      return JitsiMeetingResponse(
        isSuccess: false,
        message: error.toString(),
        error: error,
      );
    });
  }

  @override
  Future<JitsiMeetingResponse> hangUp() async {
    return await _methodChannel.invokeMethod<String>('hangUp').then((message) {
      return JitsiMeetingResponse(isSuccess: true, message: message);
    }).catchError((error) {
      return JitsiMeetingResponse(
        isSuccess: false,
        message: error.toString(),
        error: error,
      );
    });
  }

  void _initialize() {
    _eventChannel.receiveBroadcastStream().listen((message) {
      final data = message['data'];
      switch (message['event']) {
        case "opened":
          _listener?.onOpened?.call();
          break;
        case "onPictureInPictureWillEnter":
          _listener?.onPictureInPictureWillEnter?.call();
          break;
        case "onPictureInPictureTerminated":
          _listener?.onPictureInPictureTerminated?.call();
          break;
        case "conferenceWillJoin":
          _listener?.onConferenceWillJoin?.call(data["url"].toString());
          break;
        case "conferenceJoined":
          _listener?.onConferenceJoined?.call(data["url"].toString());
          break;
        case "conferenceTerminated":
          _listener?.onConferenceTerminated
              ?.call(data["url"].toString(), data["error"]);
          break;
        case "audioMutedChanged":
          _listener?.onAudioMutedChanged?.call(parseBool(data["muted"]));
          break;
        case "videoMutedChanged":
          _listener?.onVideoMutedChanged
              ?.call(parseBool(data["muted"], isVideoMutedChanged: true));
          break;
        case "screenShareToggled":
          _listener?.onScreenShareToggled
              ?.call(data["participantId"], parseBool(data["sharing"]));
          break;
        case "participantJoined":
          _listener?.onParticipantJoined?.call(
            data["email"].toString(),
            data["name"].toString(),
            data["role"].toString(),
            data["participantId"].toString(),
          );
          break;
        case "participantLeft":
          _listener?.onParticipantLeft?.call(data["participantId"]);
          break;
        case "participantsInfoRetrieved":
          _listener?.onParticipantsInfoRetrieved?.call(
            data["participantsInfo"],
            data["requestId"],
          );
          break;
        case "chatMessageReceived":
          _listener?.onChatMessageReceived?.call(
            data["senderId"],
            data["message"],
            parseBool(data["isPrivate"]),
            DateTime.now().toUtc().toString(),
          );
          break;
        case "chatToggled":
          _listener?.onChatToggled?.call(parseBool(data["isOpen"]));
          break;
        case "closed":
          _listener?.onClosed?.call();
          _listener = null;
          break;
      }
    }).onError((error) {
      debugPrint(
          "OMNI_JITSI: Error receiving data from the event channel: $error");
      _listener?.onError?.call(error);
    });
    _eventChannelIsInitialized = true;
  }

  @override
  closeMeeting() {
    _methodChannel.invokeMethod('closeMeeting');
  }

  @override
  Widget buildView(List<String> extraJS) => const SizedBox.shrink();
}

bool parseBool(dynamic value, {bool isVideoMutedChanged = false}) {
  if (value is bool) return value;

  if (isVideoMutedChanged && value is String) {
    return value != '0.0';
  }

  if (value is String) return value == 'true';
  if (value is num) return value != 0;

  throw ArgumentError('OMNI_JITSI: Unsupported type: $value');
}
