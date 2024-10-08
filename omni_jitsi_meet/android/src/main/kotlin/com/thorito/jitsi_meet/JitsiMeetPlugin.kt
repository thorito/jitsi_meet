package com.thorito.jitsi_meet

import android.app.Activity
import android.content.Intent
import android.content.BroadcastReceiver
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import org.jitsi.meet.sdk.*
import java.net.URL
import androidx.localbroadcastmanager.content.LocalBroadcastManager


/** JitsiMeetPlugin
example: https://github.com/jitsi/jitsi-meet-sdk-samples/blob/18c35f7625b38233579ff34f761f4c126ba7e03a/android/kotlin/JitsiSDKTest/app/src/main/kotlin/net/jitsi/sdktest/MainActivity.kt
 */
public class JitsiMeetPlugin() : FlutterPlugin, MethodCallHandler,
    ActivityAware {
    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private val eventStreamHandler = JitsiMeetEventStreamHandler.instance
    private var activity: Activity? = null

    /**
     * FlutterPlugin interface implementations
     */
    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel =
            MethodChannel(flutterPluginBinding.binaryMessenger, "jitsi_meet")
        methodChannel.setMethodCallHandler(this)

        eventChannel = EventChannel(
            flutterPluginBinding.binaryMessenger,
            "jitsi_meet_events"
        )
        eventChannel.setStreamHandler(JitsiMeetEventStreamHandler.instance)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }

    override fun onDetachedFromActivity() {
        this.activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        this.activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    /**
     * MethodCallHandler interface implementations
     */
    override fun onMethodCall(
        @NonNull call: MethodCall,
        @NonNull result: Result
    ) {

        when (call.method) {
            "getPlatformVersion" -> {result.success("Android ${android.os.Build.VERSION.RELEASE}")}
            "joinMeeting" -> joinMeeting(call, result)
            "setAudioMuted" -> setAudioMuted(call, result)
            "setVideoMuted" -> setVideoMuted(call, result)
            "handUp" -> hangUp(call, result)
            "closeMeeting" -> closeMeeting(call, result)
            "sendEndpointTextMessage" -> sendEndpointTextMessage(call, result)
            "toggleScreenShare" -> toggleScreenShare(call, result)
            "openChat" -> openChat(call, result)
            "sendChatMessage" -> sendChatMessage(call, result)
            "closeChat" -> closeChat(call, result)
            "retrieveParticipantsInfo" -> retrieveParticipantsInfo(call, result)
            else -> result.notImplemented()
        }
    }

    /**
     * Method call to join a meeting
     */
    private fun joinMeeting(call: MethodCall, result: Result) {
        val room = call.argument<String>("room")
        if (room.isNullOrBlank()) {
            result.error(
                "400",
                "room can not be null or empty",
                "room can not be null or empty"
            )
            return
        }

        val serverUrlString: String =
            call.argument("serverURL") ?: "https://meet.jit.si"

        val subject: String? = call.argument("subject")
        val token: String? = call.argument("token")
        val isAudioMuted: Boolean? = call.argument("audioMuted")
        val isAudioOnly: Boolean? = call.argument("audioOnly")
        val isVideoMuted: Boolean? = call.argument("videoMuted")

        val displayName: String? = call.argument("userDisplayName")
        val email: String? = call.argument("userEmail")
        val userAvatarUrlString: String? = call.argument("userAvatarUrl")
        val userInfo = JitsiMeetUserInfo().apply {
            if (displayName != null) this.displayName = displayName
            if (email != null) this.email = email
            if (userAvatarUrlString != null) avatar = URL(userAvatarUrlString)
        }

        val serverURL = URL(serverUrlString)

        val options = JitsiMeetConferenceOptions.Builder().run {
            setRoom(room)
            if (serverURL != null) setServerURL(serverURL)
            if (subject != null) setSubject(subject)
            if (token != null) setToken(token)
            if (isAudioMuted != null) setAudioMuted(isAudioMuted)
            if (isAudioOnly != null) setAudioOnly(isAudioOnly)
            if (isVideoMuted != null) setVideoMuted(isVideoMuted)
            if (displayName != null || email != null || userAvatarUrlString != null) {
                setUserInfo(userInfo)
            }

            val featureFlags =
                call.argument<HashMap<String, Any?>>("featureFlags")
            featureFlags?.forEach { (key, value) ->
                // Can only be bool, int or string according to
                // the overloads of setFeatureFlag.
                when (value) {
                    is Boolean -> setFeatureFlag(key, value)
                    is Int -> setFeatureFlag(key, value)
                    else -> setFeatureFlag(key, value.toString())
                }
            }

            val configOverrides =
                call.argument<HashMap<String, Any?>>("configOverrides")
            configOverrides?.forEach { (key, value) ->
                // Can only be bool, int, array of strings or string according to
                // the overloads of setConfigOverride.
                when (value) {
                    is Boolean -> setConfigOverride(key, value)
                    is Int -> setConfigOverride(key, value)
                    is Array<*> -> setConfigOverride(
                        key,
                        value as Array<out String>
                    )
                    else -> setConfigOverride(key, value.toString())
                }
            }

            build()
        }

        JitsiMeetPluginActivity.launchActivity(activity!!, options)
        result.success("Successfully joined room: $room")
    }

    private fun closeMeeting(call: MethodCall, result: Result) {
        val intent = Intent("JITSI_MEETING_CLOSE")
        activity?.sendBroadcast(intent)
        result.success(null)
    }

    private fun setAudioMuted(call: MethodCall, result: Result) {
        val isMuted = call.argument<Boolean>("isMuted") ?: false

        val muteBroadcastIntent: Intent =
            BroadcastIntentHelper.buildSetAudioMutedIntent(isMuted)
        LocalBroadcastManager.getInstance(activity!!.applicationContext)
            .sendBroadcast(muteBroadcastIntent)

        result.success("Successfully set audio muted to: $isMuted")
    }

    private fun setVideoMuted(call: MethodCall, result: Result) {
        val muted = call.argument<Boolean>("muted") ?: false
        val videoMuteBroadcastIntent: Intent = BroadcastIntentHelper.buildSetVideoMutedIntent(muted)
        LocalBroadcastManager.getInstance(activity!!.applicationContext).sendBroadcast(videoMuteBroadcastIntent)

        result.success("Successfully set video $muted")
    }

    private fun sendEndpointTextMessage(call: MethodCall, result: Result) {
        val to = call.argument<String?>("to")
        val message = call.argument<String>("message")
        val sendEndpointTextMessageBroadcastIntent: Intent = BroadcastIntentHelper.buildSendEndpointTextMessageIntent(to, message)
        LocalBroadcastManager.getInstance(activity!!.applicationContext).sendBroadcast(sendEndpointTextMessageBroadcastIntent)
        result.success("Successfully send endpoint text message $to")
    }

    private fun toggleScreenShare(call: MethodCall, result: Result) {
        val enabled = call.argument<Boolean>("enabled") ?: false
        val toggleScreenShareIntent: Intent = BroadcastIntentHelper.buildToggleScreenShareIntent(enabled)
        LocalBroadcastManager.getInstance(activity!!.applicationContext).sendBroadcast(toggleScreenShareIntent)
        result.success("Successfully toggled screen share $enabled")
    }

    private fun openChat(call: MethodCall, result: Result) {
        val to = call.argument<String?>("to")
        val openChatIntent: Intent = BroadcastIntentHelper.buildOpenChatIntent(to)
        LocalBroadcastManager.getInstance(activity!!.applicationContext).sendBroadcast(openChatIntent)
        result.success("Successfully opened chat $to")
    }

    private fun sendChatMessage(call: MethodCall, result: Result) {
        val to = call.argument<String?>("to")
        val message = call.argument<String>("message")
        val sendChatMessageIntent: Intent = BroadcastIntentHelper.buildSendChatMessageIntent(to, message)
        LocalBroadcastManager.getInstance(activity!!.applicationContext).sendBroadcast(sendChatMessageIntent)
        result.success("Successfully sent chat message $to")
    }

    private fun closeChat(call: MethodCall, result: Result) {
        val closeChatIntent: Intent = BroadcastIntentHelper.buildCloseChatIntent()
        LocalBroadcastManager.getInstance(activity!!.applicationContext).sendBroadcast(closeChatIntent)
        result.success("Successfully closed chat")
    }

    private fun retrieveParticipantsInfo(call: MethodCall, result: Result) {
        val retrieveParticipantsInfoIntent: Intent = Intent("org.jitsi.meet.RETRIEVE_PARTICIPANTS_INFO");
        LocalBroadcastManager.getInstance(activity!!.applicationContext).sendBroadcast(retrieveParticipantsInfoIntent)
        result.success("Successfully retrieved participants info")
    }

    private fun hangUp(call: MethodCall, result: Result) {
        val hangUpIntent: Intent = BroadcastIntentHelper.buildHangUpIntent()
        LocalBroadcastManager.getInstance(activity!!.applicationContext)
            .sendBroadcast(hangUpIntent)
        closeMeeting(call, result);
        result.success("Successfully hung up.")
    }
}
