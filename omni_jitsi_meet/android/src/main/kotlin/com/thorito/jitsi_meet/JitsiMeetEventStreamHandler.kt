package com.thorito.jitsi_meet

import io.flutter.plugin.common.EventChannel
import java.io.Serializable

/**
 * StreamHandler to listen to conference events and broadcast it back to Flutter
 */
class JitsiMeetEventStreamHandler private constructor(): EventChannel.StreamHandler {
    companion object {
        val instance = JitsiMeetEventStreamHandler()
    }

    private var eventSink: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink?) {
        this.eventSink = eventSink
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    fun onOpened() {
        eventSink?.success(mapOf("event" to "opened"))
    }

    fun onClosed() {
        eventSink?.success(mapOf("event" to "closed"))
    }

    fun onConferenceWillJoin(data: MutableMap<String, Any>?) {
        eventSink?.success(mapOf("event" to "conferenceWillJoin", "data" to data))
    }

    fun onConferenceJoined(data: MutableMap<String, Any>?) {
        eventSink?.success(mapOf("event" to "conferenceJoined", "data" to data))
    }

    fun onConferenceTerminated(data: MutableMap<String, Any>?) {
        eventSink?.success(mapOf("event" to "conferenceTerminated", "data" to data))
    }

    fun onAudioMutedChanged(data: MutableMap<String, Any>?) {
        eventSink?.success(mapOf("event" to "audioMutedChanged", "data" to data))
    }

    fun onParticipantJoined(data: MutableMap<String, Any>?) {
        eventSink?.success(mapOf("event" to "participantJoined", "data" to data))
    }

    fun onParticipantLeft(data: MutableMap<String, Any>?) {
        eventSink?.success(mapOf("event" to "participantLeft", "data" to data))
    }

    fun onEndpointTextMessageReceived(data: MutableMap<String, Any>?) {
        eventSink?.success(mapOf("event" to "endpointTextMessageReceived", "data" to data))
    }

    fun onScreenShareToggled(data: MutableMap<String, Any>?) {
        eventSink?.success(mapOf("event" to "screenShareToggled", "data" to data))
    }

    fun onParticipantsInfoRetrieved(data: MutableMap<String, Any>?) {
        eventSink?.success(mapOf("event" to "participantInfoRetrieved", "data" to data))
    }

    fun onChatMessageReceived(data: MutableMap<String, Any>?) {
        eventSink?.success(mapOf("event" to "chatMessageReceived", "data" to data))
    }

    fun onChatToggled(data: MutableMap<String, Any>?) {
        eventSink?.success(mapOf("event" to "chatToggled", "data" to data))
    }

    fun onVideoMutedChanged(data: MutableMap<String, Any>?) {
        eventSink?.success(mapOf("event" to "videoMutedChanged", "data" to data))
    }

    fun onPictureInPictureWillEnter() {
        eventSink?.success(mapOf("event" to "onPictureInPictureWillEnter"))
    }

    fun onPictureInPictureTerminated() {
        eventSink?.success(mapOf("event" to "onPictureInPictureTerminated"))
    }
}