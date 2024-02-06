import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:js/js.dart';
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

      api?.on("chatUpdated", allowInterop((message) {
        Map<String, dynamic> data = {
          'isOpen': !kReleaseMode ? message.isOpen : false,
          'unreadCount': !kReleaseMode ? message.unreadCount : 0,
        };

        listener.onChatToggled?.call(
          parseBool(data["isOpen"]),
        );
      }));

      api?.on("incomingMessage", allowInterop((message) {
        Map<String, dynamic> data = {
          'senderId': !kReleaseMode ? message.from : '?',
          'nick': !kReleaseMode ? message.nick : '?',
          'isPrivate': !kReleaseMode ? message.privateMessage : false,
          'message': !kReleaseMode ? message.message : '?',
          'timestamp': DateTime.now().toUtc(),
        };

        listener.onChatMessageReceived?.call(
          data["senderId"]?.toString() ?? '?',
          data["message"]?.toString() ?? '?',
          parseBool(data["isPrivate"]),
          data["timestamp"].toString(),
        );
      }));

      api?.on("audioMuteStatusChanged", allowInterop((message) {
        Map<String, dynamic> data = {
          'muted': !kReleaseMode ? message.muted : false,
        };

        listener.onAudioMutedChanged?.call(
          parseBool(data["muted"]),
        );
      }));

      api?.on("videoMuteStatusChanged", allowInterop((message) {
        Map<String, dynamic> data = {
          'muted': !kReleaseMode ? message.muted : false,
        };

        listener.onVideoMutedChanged?.call(
          parseBool(data["muted"], isVideoMutedChanged: true),
        );
      }));

      api?.on("screenSharingStatusChanged", allowInterop((message) {
        Map<String, dynamic> data = {
          'sharing': !kReleaseMode ? message.on : false,
          'details': !kReleaseMode ? message.details : {},
          'participantId': !kReleaseMode ? message.id : '?',
        };

        listener.onScreenShareToggled?.call(
          data["participantId"]?.toString() ?? '?',
          parseBool(data["sharing"]),
        );
      }));

      api?.on("participantsInfoRetrieved", allowInterop((message) {
        Map<String, dynamic> data = {
          'participantsInfo': !kReleaseMode ? message.participantsInfo : {},
          'requestId': !kReleaseMode ? message.requestId : '?'
        };

        listener.onParticipantsInfoRetrieved?.call(
          data["participantsInfo"] ?? {},
          data["requestId"]?.toString() ?? '?',
        );
      }));

      api?.on("videoConferenceJoined", allowInterop((message) {
        Map<String, dynamic> data = {
          'url': !kReleaseMode ? message.roomName : '?',
          'id': !kReleaseMode ? message.id : '?',
          'displayName': !kReleaseMode ? message.displayName : '?',
          'avatarURL': !kReleaseMode ? message.avatarURL : '',
          'breakoutRoom': !kReleaseMode ? message.breakoutRoom : false,
        };

        listener.onConferenceJoined?.call(
          data["url"].toString(),
        );
      }));

      api?.on("videoConferenceLeft", allowInterop((message) {
        Map<String, dynamic> data = {
          'url': !kReleaseMode ? message.roomName : '?',
          'error': message?.error,
        };

        listener.onConferenceTerminated?.call(
          data["url"].toString(),
          data["error"],
        );

        listener.onClosed?.call();
      }));

      api?.on("participantJoined", allowInterop((message) {
        Map<String, dynamic> data = {
          'email': !kReleaseMode ? message.email : '?',
          'name': !kReleaseMode ? message.displayName : '?',
          'role': !kReleaseMode ? message.role : '?',
          'participantId': !kReleaseMode ? message.id : '?',
        };

        listener.onParticipantJoined?.call(
            data["email"]?.toString() ?? "?",
            data["name"]?.toString() ?? "?",
            data["role"]?.toString() ?? "?",
            data["participantId"]?.toString() ?? "?");
      }));

      api?.on("participantLeft", allowInterop((message) {
        Map<String, dynamic> data = {
          "participantId": !kReleaseMode ? message.id : '?',
        };

        listener.onParticipantLeft?.call(
          data["participantId"]?.toString() ?? "?",
        );
      }));

      api?.on("feedbackSubmitted", allowInterop((message) {
        Map<String, dynamic> data = {
          "error": !kReleaseMode ? message.error : '?',
        };

        listener.onError?.call(
          data["error"]?.toString() ?? "?",
        );
      }));

      // NOTE: `onConferenceWillJoin` is not supported or nof found event in web
      // add generic listener
      _addGenericListeners(listener);
      api?.on("readyToClose", allowInterop((message) {
        listener.onClosed?.call();
        api?.dispose();
      }));
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
  _addGenericListeners(JitsiMeetingListener listener) {
    if (api == null) {
      debugPrint("Jistsi instance not exists event can't be attached");
      return;
    }
    debugPrint("genericListeners ${listener.genericListeners}");
    if (listener.genericListeners != null) {
      listener.genericListeners?.forEach((item) {
        debugPrint("eventName ${item.eventName}");
        api?.on(item.eventName, allowInterop(item.callback));
      });
    }
  }

  @override
  void executeCommand(String command, List<String> args) {
    api?.executeCommand(command, args);
  }

  closeMeeting() {
    debugPrint("Closing the meeting");
    api?.dispose();
    api = null;
  }

  /// Adds a JitsiMeetingListener that will broadcast conference events
  addListener(JitsiMeetingListener jitsiMeetingListener) {
    _addGenericListeners(jitsiMeetingListener);
  }

  /// Remove JitsiListener
  /// Remove all list of listeners bassed on event name
  removeListener(JitsiMeetingListener jitsiMeetingListener) {
    List<String> listeners = [];
    if (jitsiMeetingListener.onConferenceJoined != null) {
      listeners.add("videoConferenceJoined");
    }
    ;
    if (jitsiMeetingListener.onConferenceTerminated != null) {
      listeners.add("videoConferenceLeft");
    }

    jitsiMeetingListener.genericListeners
        ?.forEach((element) => listeners.add(element.eventName));
    api?.removeEventListener(listeners);
  }

  /// Removes all JitsiMeetingListeners
  /// Not used for web
  removeAllListeners() {}

  /// Initialize
  void initialize() {}

  @override
  Widget buildView(List<String> extraJS) {
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory('jitsi-meet-view',
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
    extraJS.forEach((element) {
      RegExp regExp = RegExp(r"<script[^>]*>(.*?)<\/script[^>]*>");
      if (regExp.hasMatch(element)) {
        final html.NodeValidatorBuilder validator =
            html.NodeValidatorBuilder.common()
              ..allowElement('script',
                  attributes: ['type', 'crossorigin', 'integrity', 'src']);
        debugPrint("ADD script $element");
        html.Element script = html.Element.html(element, validator: validator);
        html.querySelector('head')?.children.add(script);
        // html.querySelector('head').appendHtml(element, validator: validator);
      } else {
        debugPrint("$element is not a valid script");
      }
    });
  }

  // Setup the `JitsiMeetExternalAPI` JS script
  void _setupScripts() {
    final html.ScriptElement script = html.ScriptElement()
      ..appendText(_clientJs());
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
