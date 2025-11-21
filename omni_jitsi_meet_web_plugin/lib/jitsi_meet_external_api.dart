import 'dart:js_interop';

/// Extended `JitsiMeetExternalAPI' JS
///
/// Allows Dart code communicate with the `JitsiMeetExternalAPI`
/// see https://jitsi.github.io/handbook/docs/dev-guide/dev-guide-iframe
@JS('jitsi.JitsiMeetAPI')
@staticInterop
class JitsiMeetAPI {
  /// Constructor
  external factory JitsiMeetAPI(String domain, String options);
}

/// Extension methods for JitsiMeetAPI
extension JitsiMeetAPIExtension on JitsiMeetAPI {
  /// Generic handler Js for events
  external void on(String event, JSFunction callback);

  /// Interface to execute a command with `JitsiMeetExternalAPI`
  external void executeCommand(String command, JSArray<JSString> arguments);

  /// Add an Event Listener for the `JitsiMeetExternalAPI`
  external void addEventListener(String eventName, JSFunction callback);

  /// Remove Event Listener for the `JitsiMeetExternalAPI`
  external void removeEventListener(JSArray<JSString> listener);

  /// remove instance
  external void dispose();
}
