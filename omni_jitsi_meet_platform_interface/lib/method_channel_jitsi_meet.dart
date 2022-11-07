import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'jitsi_meet_platform_interface.dart';

const MethodChannel _channel = MethodChannel('jitsi_meet');

const EventChannel _eventChannel = const EventChannel('jitsi_meet_events');

/// An implementation of [JitsiMeetPlatform] that uses method channels.
class MethodChannelJitsiMeet extends JitsiMeetPlatform {
  List<JitsiMeetingListener> _listeners = <JitsiMeetingListener>[];
  Map<String, JitsiMeetingListener> _perMeetingListeners = {};

  @override
  Future<JitsiMeetingResponse> joinMeeting(
    JitsiMeetingOptions options, {
    JitsiMeetingListener? listener,
  }) async {
    // Attach a listener if it exists. The key is based on the serverURL + room
    if (listener != null) {
      String serverURL = options.serverURL ?? "https://meet.jit.si";
      String key;
      if (serverURL.endsWith("/")) {
        key = serverURL + options.room;
      } else {
        key = serverURL + "/" + options.room;
      }

      _perMeetingListeners.update(key, (oldListener) => listener,
          ifAbsent: () => listener);
      initialize();
    }
    Map<String, dynamic> _options = {
      'room': options.room.trim(),
      'serverURL': options.serverURL?.trim(),
      'subject': options.subject,
      'token': options.token,
      'audioMuted': options.audioMuted,
      'audioOnly': options.audioOnly,
      'videoMuted': options.videoMuted,
      'featureFlags': options.getFeatureFlags(),
      'userDisplayName': options.userDisplayName,
      'userEmail': options.userEmail,
      'iosAppBarRGBAColor': options.iosAppBarRGBAColor,
    };

    return await _channel
        .invokeMethod<String>('joinMeeting', _options)
        .then((message) => JitsiMeetingResponse(
              isSuccess: true,
              message: message,
            ))
        .catchError(
      (error) {
        return JitsiMeetingResponse(
          isSuccess: true,
          message: error.toString(),
          error: error,
        );
      },
    );
  }

  @override
  closeMeeting() {
    _channel.invokeMethod('closeMeeting');
  }

  @override
  addListener(JitsiMeetingListener jitsiMeetingListener) {
    _listeners.add(jitsiMeetingListener);
    initialize();
  }

  @override
  removeListener(JitsiMeetingListener jitsiMeetingListener) {
    _listeners.remove(jitsiMeetingListener);
  }

  @override
  removeAllListeners() {
    _listeners.clear();
  }

  @override
  void executeCommand(String command, List<String> args) {}

  @override
  Widget buildView(List<String> extraJS) {
    // return empty container for compatibily
    return Container();
  }

  @override
  void initialize() {
    _eventChannel.receiveBroadcastStream().listen((message) {
      _broadcastToGlobalListeners(message);
      _broadcastToPerMeetingListeners(message);
    }, onError: (dynamic error) {
      debugPrint('CUSTOM_JITSI: Jitsi Meet broadcast error: $error');
      _listeners.forEach((listener) {
        if (listener.onError != null) listener.onError!(error);
      });
      _perMeetingListeners.forEach((key, listener) {
        if (listener.onError != null) listener.onError!(error);
      });
    });
  }

  /// Sends a broadcast to global listeners added using addListener
  void _broadcastToGlobalListeners(message) {
    _listeners.forEach((listener) {
      final data = message['data'];
      final event = message['event'];
      switch (event) {
        case "opened":
          listener.onOpened?.call();
          break;
        case "onConferenceWillJoin":
          listener.onConferenceWillJoin?.call(data["url"]);
          break;
        case "onConferenceJoined":
          listener.onConferenceJoined?.call(data["url"]);
          break;
        case "onConferenceTerminated":
          listener.onConferenceTerminated?.call(data["url"], data["error"]);
          break;
        case "audioMutedChanged":
          listener.onAudioMutedChanged?.call(parseBool(data["muted"]));
          break;
        case "videoMutedChanged":
          listener.onVideoMutedChanged?.call(parseBool(data["muted"]));
          break;
        case "screenShareToggled":
          listener.onScreenShareToggled
              ?.call(data["participantId"], parseBool(data["sharing"]));
          break;
        case "participantJoined":
          listener.onParticipantJoined?.call(
            data["email"],
            data["name"],
            data["role"],
            data["participantId"],
          );
          break;
        case "participantLeft":
          listener.onParticipantLeft?.call(data["participantId"]);
          break;
        case "participantsInfoRetrieved":
          listener.onParticipantsInfoRetrieved?.call(
            data["participantsInfo"],
            data["requestId"],
          );
          break;
        case "chatMessageReceived":
          listener.onChatMessageReceived?.call(
            data["senderId"],
            data["message"],
            parseBool(data["isPrivate"]),
          );
          break;
        case "chatToggled":
          listener.onChatToggled?.call(parseBool(data["isOpen"]));
          break;
        case "closed":
          listener.onClosed?.call();
          break;
      }
    });
  }

  /// Sends a broadcast to per meeting listeners added during joinMeeting
  void _broadcastToPerMeetingListeners(message) {
    final data = message['data'];

    if (data["url"] != null) {
      final listener = _perMeetingListeners[data["url"]];
      if (listener != null) {
        switch (message['event']) {
          case "onConferenceWillJoin":
            listener.onConferenceWillJoin?.call(data["url"]);
            break;
          case "onConferenceJoined":
            listener.onConferenceJoined?.call(data["url"]);
            break;
          case "onConferenceTerminated":
            listener.onConferenceTerminated?.call(data["url"], data['error']);
            _perMeetingListeners.remove(listener);
            break;
          case "participantJoined":
            listener.onParticipantJoined?.call(
              data["email"],
              data["name"],
              data["role"],
              data["participantId"],
            );
            break;
          case "onParticipantLeft":
            listener.onParticipantLeft?.call(message['participantId']);
        }
      }
    }
  }
}

// Required because Android SDK returns boolean values as Strings
// and iOS SDK returns boolean values as Booleans.
// (Making this an extension does not work, because of dynamic.)
bool parseBool(dynamic value) {
  if (value is bool) return value;
  if (value is String) return value == 'true';
  // Check whether value is not 0, because true values can be any value
  // above 0 when coming from Jitsi.
  if (value is num) return value != 0;
  throw ArgumentError('Unsupported type: $value');
}
