import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:js/js.dart';
import 'package:omni_jitsi_meet_platform_interface/jitsi_meet_platform_interface.dart';

import 'jitsi_meet_external_api.dart' as jitsi;
import 'room_name_constraint.dart';
import 'room_name_constraint_type.dart';

/// JitsiMeetPlugin Web version for Jitsi Meet plugin
class JitsiMeetPlugin extends JitsiMeetPlatform {
  // List<JitsiMeetingListener> _listeners = <JitsiMeetingListener>[];
  // Map<String, JitsiMeetingListener> _perMeetingListeners = {};

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
      api?.on("videoConferenceJoined", allowInterop((dynamic _message) {
        Map<String, dynamic> data = {
          'id': _message.id,
          "displayName": _message.displayName,
          "roomName": _message.roomName,
          "avatarURL": _message.avatarURL,
          "breakoutRoom": _message.breakoutRoom,
        };

        listener.onConferenceJoined?.call(data.toString());
      }));
      api?.on("videoConferenceLeft", allowInterop((dynamic _message) {
        listener.onConferenceTerminated
            ?.call(_message.roomName, _message?.error);
      }));
      api?.on("participantJoined", allowInterop((dynamic _message) {

        Map<String, dynamic> data = {
          "name": _message.displayName,
          "email": _message.email,
          "role": _message.role,
          "participantId": _message.id,
        };
        listener.onParticipantJoined?.call(
            data["email"], data["name"], data["role"], data["participantId"]);
      }));
      api?.on("participantLeft", allowInterop((dynamic _message) {
        Map<String, dynamic> data = {
          "participantId": _message.id,
        };
        listener.onParticipantLeft?.call(data["participantId"]);
      }));
      api?.on("feedbackSubmitted", allowInterop((dynamic _message) {
        listener.onError?.call(_message);
      }));
      api?.on("audioMuteStatusChanged", allowInterop((dynamic _message) {
        listener.onAudioMutedChanged?.call(_message.muted);
      }));
      api?.on("videoMuteStatusChanged", allowInterop((dynamic _message) {
        listener.onVideoMutedChanged?.call(_message.muted);
      }));

      // NOTE: `onConferenceWillJoin` is not supported or nof found event in web
      // add geeric listener
      _addGenericListeners(listener);
      api?.on("readyToClose", allowInterop((dynamic _message) {
        api?.dispose();
      }));
    }

    return JitsiMeetingResponse(isSuccess: true);
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
