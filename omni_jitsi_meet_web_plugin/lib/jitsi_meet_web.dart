import 'dart:async';
import 'dart:convert';
// ignore: deprecated_member_use
import 'dart:html' as html;
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
// ignore: depend_on_referenced_packages
import 'dart:ui_web' as ui_web;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:omni_jitsi_meet_platform_interface/jitsi_meet_platform_interface.dart';

import 'jitsi_meet_external_api.dart' as jitsi;
import 'room_name_constraint.dart';
import 'room_name_constraint_type.dart';

/// JitsiMeetPlugin Web version for Jitsi Meet plugin
class JitsiMeetPlugin extends JitsiMeetPlatform {
  /// `JitsiMeetExternalAPI` holder
  jitsi.JitsiMeetAPI? api;

  /// Flag to indicate if external JS are already added
  /// used for extra scripts
  bool extraJSAdded = false;

  /// Regex to validate URL
  RegExp cleanDomain = RegExp(r"^https?:\/\/");

  /// Helper method to get property from JSObject
  dynamic _getProperty(JSObject obj, String property) {
    try {
      final jsValue = obj.getProperty(property.toJS);
      return jsValue.dartify();
    } catch (e) {
      debugPrint("Error getting property '$property': $e");
      return null;
    }
  }

  JitsiMeetPlugin._() {
    _setupScripts();
  }

  static final JitsiMeetPlugin _instance = JitsiMeetPlugin._();

  /// Registry web plugin
  static void registerWith(Registrar registrar) {
    JitsiMeetPlatform.instance = _instance;
  }

  /// Joins a meeting based on the JitsiMeetingOptions passed in.
  /// A JitsiMeetingListener can be attached to this meeting
  /// that will automatically be removed when the meeting has ended
  @override
  Future<JitsiMeetingResponse> joinMeeting(JitsiMeetingOptions options,
      {JitsiMeetingListener? listener,
      Map<RoomNameConstraintType, RoomNameConstraint>?
          roomNameConstraints}) async {
    // encode `options` Map to Json to avoid error
    // in interoperability conversions
    String webOptions = jsonEncode(options.webOptions);
    String serverURL = options.serverURL ?? "meet.jit.si";
    serverURL = serverURL.replaceAll(cleanDomain, "");
    api = jitsi.JitsiMeetAPI(serverURL, webOptions);

    // setup listeners
    if (listener != null) {
      listener.onOpened?.call();

      api?.on("chatUpdated", ((JSAny message) {
        final msg = message as JSObject;
        Map<String, dynamic> data = {
          'isOpen': !kReleaseMode ? _getProperty(msg, 'isOpen') : false,
          'unreadCount': !kReleaseMode ? _getProperty(msg, 'unreadCount') : 0,
        };

        listener.onChatToggled?.call(
          parseBool(data["isOpen"]),
        );
      }.toJS));

      api?.on("incomingMessage", ((JSAny message) {
        final msg = message as JSObject;
        Map<String, dynamic> data = {
          'senderId': !kReleaseMode ? _getProperty(msg, 'from') : '?',
          'nick': !kReleaseMode ? _getProperty(msg, 'nick') : '?',
          'isPrivate': !kReleaseMode ? _getProperty(msg, 'privateMessage') : false,
          'message': !kReleaseMode ? _getProperty(msg, 'message') : '?',
          'timestamp': DateTime.now().toUtc(),
        };

        listener.onChatMessageReceived?.call(
          data["senderId"]?.toString() ?? '?',
          data["message"]?.toString() ?? '?',
          parseBool(data["isPrivate"]),
          data["timestamp"].toString(),
        );
      }.toJS));

      api?.on("audioMuteStatusChanged", ((JSAny message) {
        final msg = message as JSObject;
        Map<String, dynamic> data = {
          'muted': !kReleaseMode ? _getProperty(msg, 'muted') : false,
        };

        listener.onAudioMutedChanged?.call(
          parseBool(data["muted"]),
        );
      }.toJS));

      api?.on("videoMuteStatusChanged", ((JSAny message) {
        final msg = message as JSObject;
        Map<String, dynamic> data = {
          'muted': !kReleaseMode ? _getProperty(msg, 'muted') : false,
        };

        listener.onVideoMutedChanged?.call(
          parseBool(data["muted"], isVideoMutedChanged: true),
        );
      }.toJS));

      api?.on("screenSharingStatusChanged", ((JSAny message) {
        final msg = message as JSObject;
        Map<String, dynamic> data = {
          'sharing': !kReleaseMode ? _getProperty(msg, 'on') : false,
          'details': !kReleaseMode ? _getProperty(msg, 'details') : {},
          'participantId': !kReleaseMode ? _getProperty(msg, 'id') : '?',
        };

        listener.onScreenShareToggled?.call(
          data["participantId"]?.toString() ?? '?',
          parseBool(data["sharing"]),
        );
      }.toJS));

      api?.on("participantsInfoRetrieved", ((JSAny message) {
        final msg = message as JSObject;
        Map<String, dynamic> data = {
          'participantsInfo': !kReleaseMode ? _getProperty(msg, 'participantsInfo') : {},
          'requestId': !kReleaseMode ? _getProperty(msg, 'requestId') : '?'
        };

        listener.onParticipantsInfoRetrieved?.call(
          data["participantsInfo"] ?? {},
          data["requestId"]?.toString() ?? '?',
        );
      }.toJS));

      api?.on("videoConferenceJoined", ((JSAny message) {
        final msg = message as JSObject;
        Map<String, dynamic> data = {
          'url': !kReleaseMode ? _getProperty(msg, 'roomName') : '?',
          'id': !kReleaseMode ? _getProperty(msg, 'id') : '?',
          'displayName': !kReleaseMode ? _getProperty(msg, 'displayName') : '?',
          'avatarURL': !kReleaseMode ? _getProperty(msg, 'avatarURL') : '',
          'breakoutRoom': !kReleaseMode ? _getProperty(msg, 'breakoutRoom') : false,
        };

        listener.onConferenceJoined?.call(
          data["url"].toString(),
        );
      }.toJS));

      api?.on("videoConferenceLeft", ((JSAny message) {
        final msg = message as JSObject;
        Map<String, dynamic> data = {
          'url': !kReleaseMode ? _getProperty(msg, 'roomName') : '?',
          'error': _getProperty(msg, 'error'),
        };

        listener.onConferenceTerminated?.call(
          data["url"].toString(),
          data["error"],
        );

        listener.onClosed?.call();
      }.toJS));

      api?.on("participantJoined", ((JSAny message) {
        final msg = message as JSObject;
        Map<String, dynamic> data = {
          'email': !kReleaseMode ? _getProperty(msg, 'email') : '?',
          'name': !kReleaseMode ? _getProperty(msg, 'displayName') : '?',
          'role': !kReleaseMode ? _getProperty(msg, 'role') : '?',
          'participantId': !kReleaseMode ? _getProperty(msg, 'id') : '?',
        };

        listener.onParticipantJoined?.call(
            data["email"]?.toString() ?? "?",
            data["name"]?.toString() ?? "?",
            data["role"]?.toString() ?? "?",
            data["participantId"]?.toString() ?? "?");
      }.toJS));

      api?.on("participantLeft", ((JSAny message) {
        final msg = message as JSObject;
        Map<String, dynamic> data = {
          "participantId": !kReleaseMode ? _getProperty(msg, 'id') : '?',
        };

        listener.onParticipantLeft?.call(
          data["participantId"]?.toString() ?? "?",
        );
      }.toJS));

      api?.on("feedbackSubmitted", ((JSAny message) {
        final msg = message as JSObject;
        Map<String, dynamic> data = {
          "error": !kReleaseMode ? _getProperty(msg, 'error') : '?',
        };

        listener.onError?.call(
          data["error"]?.toString() ?? "?",
        );
      }.toJS));

      // NOTE: `onConferenceWillJoin` is not supported or nof found event in web
      // add generic listener
      _addGenericListeners(listener);
      api?.on("readyToClose", ((JSAny message) {
        listener.onClosed?.call();
        api?.dispose();
      }.toJS));
    }

    return JitsiMeetingResponse(isSuccess: true);
  }

  /// Required because Android SDK returns boolean values as Strings
  /// and iOS SDK returns boolean values as Booleans.
  /// (Making this an extension does not work, because of dynamic.)
  bool parseBool(dynamic value, {bool isVideoMutedChanged = false}) {
    if (value is bool) return value;
    if (isVideoMutedChanged && value is String) {
      return value != '0.0';
    }

    if (value is String) return value == 'true';
    if (value is num) return value != 0;

    throw ArgumentError('Unsupported type: $value');
  }

  // add generic lister over current session
  void _addGenericListeners(JitsiMeetingListener listener) {
    if (api == null) {
      debugPrint("Jistsi instance not exists event can't be attached");
      return;
    }
    debugPrint("genericListeners ${listener.genericListeners}");
    if (listener.genericListeners != null) {
      for (var item in listener.genericListeners!) {
        debugPrint("eventName ${item.eventName}");
        api?.on(item.eventName, ((JSAny arg) {
          item.callback(arg);
        }.toJS));
      }
    }
  }

  @override
  void executeCommand(String command, List<String> args) {
    api?.executeCommand(command, args.map((e) => e.toJS).toList().toJS);
  }

  @override
  void closeMeeting() {
    debugPrint("Closing the meeting");
    api?.dispose();
    api = null;
  }

  /// Adds a JitsiMeetingListener that will broadcast conference events
  void addListener(JitsiMeetingListener jitsiMeetingListener) {
    _addGenericListeners(jitsiMeetingListener);
  }

  /// Remove JitsiListener
  /// Remove all list of listeners bassed on event name
  void removeListener(JitsiMeetingListener jitsiMeetingListener) {
    List<String> listeners = [];
    if (jitsiMeetingListener.onConferenceJoined != null) {
      listeners.add("videoConferenceJoined");
    }
    if (jitsiMeetingListener.onConferenceTerminated != null) {
      listeners.add("videoConferenceLeft");
    }

    jitsiMeetingListener.genericListeners
        ?.forEach((element) => listeners.add(element.eventName));
    api?.removeEventListener(listeners.map((e) => e.toJS).toList().toJS);
  }

  /// Removes all JitsiMeetingListeners
  /// Not used for web
  void removeAllListeners() {}

  /// Initialize
  void initialize() {}

  @override
  Widget buildView(List<String> extraJS) {
    ui_web.platformViewRegistry.registerViewFactory('jitsi-meet-view',
        (int viewId) {
      final div = html.DivElement()
        ..id = "jitsi-meet-section"
        ..style.width = '100%'
        ..style.height = '100%';
      return div;
    });
    // add extraJS only once
    // this validation is needed because the view can be
    // rebuileded several times
    if (!extraJSAdded) {
      _setupExtraScripts(extraJS);
      extraJSAdded = true;
    }

    return HtmlElementView(viewType: 'jitsi-meet-view');
  }

  // setup extra JS Scripts
  void _setupExtraScripts(List<String> extraJS) {
    for (var element in extraJS) {
      RegExp regExp = RegExp(r"<script[^>]*>(.*?)<\/script[^>]*>");
      if (regExp.hasMatch(element)) {
        final html.NodeValidatorBuilder validator =
            html.NodeValidatorBuilder.common()
              ..allowElement('script',
                  attributes: ['type', 'crossorigin', 'integrity', 'src']);
        debugPrint("ADD script $element");
        html.Element script = html.Element.html(element, validator: validator);
        html.querySelector('head')?.children.add(script);
      } else {
        debugPrint("$element is not a valid script");
      }
    }
  }

  // Setup the `JitsiMeetExternalAPI` JS script
  void _setupScripts() {
    final html.ScriptElement script = html.ScriptElement()
      ..text = _clientJs();
    html.querySelector('head')?.children.add(script);
  }

  // Script to allow Jitsi interaction
  // To allow Flutter interact with `JitsiMeetExternalAPI`
  // extends and override the constructor is needed
  String _clientJs() => """
class JitsiMeetAPI extends JitsiMeetExternalAPI {
    constructor(domain , options) {
      console.log(options);
      var _options = JSON.parse(options);
      if (!_options.hasOwnProperty("width")) {
        _options.width='100%';
      }
      if (!_options.hasOwnProperty("height")) {
        _options.height='100%';
      }
      // override parent to atach to view
      //_options.parentNode=document.getElementsByTagName('flt-platform-vw')[0].shadowRoot.getElementById('jitsi-meet-section');
      console.log(_options);
      _options.parentNode=document.querySelector("#jitsi-meet-section");
      super(domain, _options);
    }
}
var jitsi = { JitsiMeetAPI: JitsiMeetAPI };""";
}