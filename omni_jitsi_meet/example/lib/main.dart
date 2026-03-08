import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:omni_jitsi_meet/jitsi_meet.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb && Platform.isIOS) {
      return const CupertinoApp(
        debugShowCheckedModeBanner: false,
        home: Meeting(),
      );
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Meeting(),
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
    );
  }
}

class Meeting extends StatefulWidget {
  const Meeting({super.key});

  @override
  State<Meeting> createState() => _MeetingState();
}

class _MeetingState extends State<Meeting> {
  final serverText = TextEditingController();
  final roomText = TextEditingController(text: 'omni_room_sample_1234');
  final subjectText = TextEditingController(text: 'Subject1');
  final nameText = TextEditingController(text: 'User1');
  final emailText = TextEditingController(text: 'fake1@email.com');
  final iosAppBarRGBAColor = TextEditingController(text: '#0080FF80');
  bool? isAudioOnly = false;
  bool? isAudioMuted = true;
  bool? isVideoMuted = true;

  bool get _isIOS => !kIsWeb && Platform.isIOS;

  @override
  Widget build(BuildContext context) {
    if (_isIOS) {
      return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('🏠 Plugin example app'),
        ),
        child: _meetConfigIOS(),
      );
    }

    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('🏠 Plugin example app'),
        centerTitle: false,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: kIsWeb
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(width: width * 0.3, child: _meetConfigAndroid()),
                  Container(
                    width: width * 0.6,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Card(
                        color: Colors.white54,
                        child: SizedBox(
                          width: width * 0.6 * 0.7,
                          height: width * 0.6 * 0.7,
                          child: JitsiMeetConferencing(
                            extraJS: [
                              '<script src="https://code.jquery.com/jquery-3.6.3.slim.js" integrity="sha256-DKU1CmJ8kBuEwumaLuh9Tl/6ZB6jzGOBV/5YpNE2BWc=" crossorigin="anonymous"></script>'
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : _meetConfigAndroid(),
      ),
    );
  }

  Widget _meetConfigIOS() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  spacing: 16,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _cupertinoField(serverText, 'Server URL',
                        'Leave empty for meet.jit.si'),
                    _cupertinoField(roomText, 'Room', null),
                    _cupertinoField(subjectText, 'Subject', null),
                    _cupertinoField(nameText, 'Display Name', null),
                    _cupertinoField(emailText, 'Email', null),
                    _cupertinoField(iosAppBarRGBAColor, 'AppBar Color',
                        'HEX RGBA format e.g. #0080FF80'),
                    _cupertinoCheckboxRow(
                      icon: CupertinoIcons.mic,
                      label: 'Audio Only',
                      value: isAudioOnly ?? false,
                      onChanged: (v) => setState(() => isAudioOnly = v),
                    ),
                    _cupertinoCheckboxRow(
                      icon: CupertinoIcons.mic_slash,
                      label: 'Audio Muted',
                      value: isAudioMuted ?? true,
                      enabled: isAudioOnly == false,
                      onChanged: (v) => setState(() => isAudioMuted = v),
                    ),
                    _cupertinoCheckboxRow(
                      icon: CupertinoIcons.video_camera,
                      label: 'Video Muted',
                      value: isVideoMuted ?? true,
                      enabled: isAudioOnly == false,
                      onChanged: (v) => setState(() => isVideoMuted = v),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: CupertinoButton.filled(
                onPressed: _joinMeeting,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.chat_bubble_2_fill,
                        color: CupertinoColors.white),
                    SizedBox(width: 8),
                    Text('Join Meeting'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _meetConfigAndroid() {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                spacing: 16,
                children: [
                  const SizedBox(height: 8),
                  TextField(
                    controller: serverText,
                    decoration: const InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                      labelText: 'Server URL',
                      hintText: 'Hint: Leave empty for meet.jit.si',
                    ),
                  ),
                  TextField(
                    controller: roomText,
                    decoration: const InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                      labelText: 'Room',
                    ),
                  ),
                  TextField(
                    controller: subjectText,
                    decoration: const InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                      labelText: 'Subject',
                    ),
                  ),
                  TextField(
                    controller: nameText,
                    decoration: const InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                      labelText: 'Display Name',
                    ),
                  ),
                  TextField(
                    controller: emailText,
                    decoration: const InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                    ),
                  ),
                  TextField(
                    controller: iosAppBarRGBAColor,
                    decoration: const InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                      labelText: 'AppBar Color (iOS only)',
                      hintText: 'Hint: This HAS to be in HEX RGBA format',
                    ),
                  ),
                  CheckboxListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    secondary: const Icon(Icons.mic),
                    title: const Text('Audio Only'),
                    value: isAudioOnly,
                    onChanged: (v) => setState(() => isAudioOnly = v),
                  ),
                  CheckboxListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    enabled: isAudioOnly == false,
                    secondary: const Icon(Icons.mic_off),
                    title: const Text('Audio Muted'),
                    value: isAudioMuted,
                    onChanged: (v) => setState(() => isAudioMuted = v),
                  ),
                  CheckboxListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    enabled: isAudioOnly == false,
                    secondary: const Icon(Icons.videocam),
                    title: const Text('Video Muted'),
                    value: isVideoMuted,
                    onChanged: (v) => setState(() => isVideoMuted = v),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            width: double.maxFinite,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.wechat_outlined,
                  color: Colors.white, size: 32),
              onPressed: _joinMeeting,
              label: const Text('Join Meeting',
                  style: TextStyle(color: Colors.white)),
              style: ButtonStyle(
                backgroundColor:
                    WidgetStateColor.resolveWith((states) => Colors.blue),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _cupertinoField(
    TextEditingController controller,
    String label,
    String? placeholder,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: CupertinoColors.secondaryLabel,
          ),
        ),
        const SizedBox(height: 4),
        CupertinoTextField(
          controller: controller,
          placeholder: placeholder,
        ),
      ],
    );
  }

  Widget _cupertinoCheckboxRow({
    required IconData icon,
    required String label,
    required bool value,
    bool enabled = true,
    required ValueChanged<bool?> onChanged,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: enabled
              ? CupertinoColors.activeBlue
              : CupertinoColors.inactiveGray,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: enabled
                  ? CupertinoColors.label
                  : CupertinoColors.inactiveGray,
            ),
          ),
        ),
        CupertinoCheckbox(
          value: value,
          onChanged: enabled ? onChanged : null,
        ),
      ],
    );
  }

  _joinMeeting() async {
    final String? serverUrl =
        serverText.text.trim().isEmpty ? null : serverText.text;

    final featureFlags = {
      FeatureFlagEnum.LOBBY_MODE_ENABLED: false,
      FeatureFlagEnum.RESOLUTION: FeatureFlagVideoResolution.SD_RESOLUTION,
      FeatureFlagEnum.WELCOME_PAGE_ENABLED: false,
    };
    if (!kIsWeb && Platform.isAndroid) {
      featureFlags[FeatureFlagEnum.CALL_INTEGRATION_ENABLED] = false;
    }
    final options = JitsiMeetingOptions(
        room: roomText.text,
        serverURL: serverUrl,
        subject: subjectText.text,
        userDisplayName: nameText.text,
        userEmail: emailText.text,
        iosAppBarRGBAColor: iosAppBarRGBAColor.text,
        audioOnly: isAudioOnly,
        audioMuted: isAudioMuted,
        videoMuted: isVideoMuted,
        featureFlags: featureFlags,
        webOptions: {
          'roomName': roomText.text,
          'width': '100%',
          'height': '100%',
          'enableWelcomePage': false,
          'enableNoAudioDetection': true,
          'enableNoisyMicDetection': true,
          'enableClosePage': false,
          'prejoinPageEnabled': false,
          'hideConferenceTimer': true,
          'disableInviteFunctions': true,
          'chromeExtensionBanner': null,
          'configOverwrite': {
            'prejoinPageEnabled': false,
            'disableDeepLinking': true,
            'enableLobbyChat': false,
            'enableClosePage': false,
            'chromeExtensionBanner': null,
          },
          'userInfo': {'email': emailText.text, 'displayName': nameText.text}
        });

    await JitsiMeet.joinMeeting(
      options,
      listener: JitsiMeetingListener(
          onOpened: () {
            debugPrint('JitsiMeetingListener - onOpened');
          },
          onClosed: () {
            debugPrint('JitsiMeetingListener - onClosed');
          },
          onError: (error) {
            debugPrint('JitsiMeetingListener - onError: error: $error');
          },
          onConferenceWillJoin: (url) {
            debugPrint(
                'JitsiMeetingListener - onConferenceWillJoin: url: $url');
          },
          onConferenceJoined: (url) {
            debugPrint('JitsiMeetingListener - onConferenceJoined: url:$url');
          },
          onConferenceTerminated: (url, error) {
            debugPrint(
                'JitsiMeetingListener - onConferenceTerminated: url: $url, error: $error');
          },
          onParticipantLeft: (participantId) {
            debugPrint(
                'JitsiMeetingListener - onParticipantLeft: $participantId');
          },
          onParticipantJoined: (email, name, role, participantId) {
            debugPrint('JitsiMeetingListener - onParticipantJoined: '
                'email: $email, name: $name, role: $role, '
                'participantId: $participantId');
          },
          onAudioMutedChanged: (muted) {
            debugPrint(
                'JitsiMeetingListener - onAudioMutedChanged: muted: $muted');
          },
          onVideoMutedChanged: (muted) {
            debugPrint(
                'JitsiMeetingListener - onVideoMutedChanged: muted: $muted');
          },
          onScreenShareToggled: (participantId, isSharing) {
            debugPrint('JitsiMeetingListener - onScreenShareToggled: '
                'participantId: $participantId, isSharing: $isSharing');
          },
          genericListeners: [
            JitsiGenericListener(
                eventName: 'readyToClose',
                callback: (dynamic message) {
                  debugPrint('JitsiMeetingListener - readyToClose callback');
                }),
          ]),
    );
  }
}
