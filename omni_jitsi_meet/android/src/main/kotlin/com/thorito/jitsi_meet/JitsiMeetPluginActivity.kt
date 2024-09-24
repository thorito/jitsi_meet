package com.thorito.jitsi_meet

import android.app.Activity
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.res.Configuration
import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import android.app.KeyguardManager
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import org.jitsi.meet.sdk.BroadcastEvent
import org.jitsi.meet.sdk.JitsiMeetActivity
import org.jitsi.meet.sdk.JitsiMeetConferenceOptions

/**
 * Activity extending JitsiMeetActivity in order to override the conference events
 */
class JitsiMeetPluginActivity : JitsiMeetActivity() {

    companion object {
        @JvmStatic
        fun launchActivity(
            context: Context?,
            options: JitsiMeetConferenceOptions?
        ) {
            var intent =
                Intent(context, JitsiMeetPluginActivity::class.java).apply {
                    action = "org.jitsi.meet.CONFERENCE"
                    putExtra("JitsiMeetConferenceOptions", options)
                }
            if (context !is Activity) {
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            context?.startActivity(intent)
        }
    }

    var onStopCalled: Boolean = false;
    private val eventStreamHandler = JitsiMeetEventStreamHandler.instance
    private val broadcastReceiver: BroadcastReceiver =
        object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                this@JitsiMeetPluginActivity.onBroadcastReceived(intent)
            }
        }

    override fun onCreate(savedInstanceState: Bundle?) {
        showOnLockscreen()
        super.onCreate(savedInstanceState)
        registerForBroadcastMessages()
        eventStreamHandler.onOpened()
        turnScreenOnAndKeyguardOff();
    }


    override fun onPictureInPictureModeChanged(isInPictureInPictureMode: Boolean, newConfig: Configuration) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig)

        if (isInPictureInPictureMode){
            JitsiMeetEventStreamHandler.instance.onPictureInPictureWillEnter()
        }
        else {
            JitsiMeetEventStreamHandler.instance.onPictureInPictureTerminated()
        }

    }

    private fun showOnLockscreen() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                        WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                        WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
            )
        }
    }

    private fun registerForBroadcastMessages() {
        val intentFilter = IntentFilter()
        for (eventType in BroadcastEvent.Type.values()) {
            intentFilter.addAction(eventType.action)
        }
        LocalBroadcastManager.getInstance(this)
            .registerReceiver(this.broadcastReceiver, intentFilter)
    }

    private fun onBroadcastReceived(intent: Intent?) {
        if (intent != null) {
            val event = BroadcastEvent(intent)
            val data = event.data
            when (event.type!!) {
                BroadcastEvent.Type.CONFERENCE_JOINED -> eventStreamHandler.onConferenceJoined(data)
                BroadcastEvent.Type.CONFERENCE_TERMINATED -> eventStreamHandler.onConferenceTerminated(data)
                BroadcastEvent.Type.CONFERENCE_WILL_JOIN -> eventStreamHandler.onConferenceWillJoin(data)
                BroadcastEvent.Type.PARTICIPANT_JOINED -> eventStreamHandler.onParticipantJoined(data)
                BroadcastEvent.Type.PARTICIPANT_LEFT -> eventStreamHandler.onParticipantLeft(data)
                BroadcastEvent.Type.AUDIO_MUTED_CHANGED -> eventStreamHandler.onAudioMutedChanged(data)
                BroadcastEvent.Type.VIDEO_MUTED_CHANGED -> eventStreamHandler.onVideoMutedChanged(data)
                BroadcastEvent.Type.ENDPOINT_TEXT_MESSAGE_RECEIVED -> eventStreamHandler.onEndpointTextMessageReceived(data)
                BroadcastEvent.Type.SCREEN_SHARE_TOGGLED -> eventStreamHandler.onScreenShareToggled(data)
                BroadcastEvent.Type.CHAT_MESSAGE_RECEIVED -> eventStreamHandler.onChatMessageReceived(data)
                BroadcastEvent.Type.CHAT_TOGGLED -> eventStreamHandler.onChatToggled(data)
                BroadcastEvent.Type.PARTICIPANTS_INFO_RETRIEVED -> eventStreamHandler.onParticipantsInfoRetrieved(data)
                BroadcastEvent.Type.READY_TO_CLOSE -> eventStreamHandler.onClosed()
                //BroadcastEvent.Type.PICTURE_IN_PICTURE_TOGGLED -> eventStreamHandler.onPictureInPictureWillEnter()
                BroadcastEvent.Type.READY_TO_CLOSE -> eventStreamHandler.onClosed()
                BroadcastEvent.Type.CUSTOM_OVERFLOW_MENU_BUTTON_PRESSED -> eventStreamHandler.customOverflowMenuButtonPressed(data)
                else -> {}
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        LocalBroadcastManager.getInstance(this)
            .unregisterReceiver(this.broadcastReceiver)
        eventStreamHandler.onClosed()
        turnScreenOffAndKeyguardOn();
    }

    private fun turnScreenOnAndKeyguardOff() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            // For newer than Android Oreo: call setShowWhenLocked, setTurnScreenOn
            setShowWhenLocked(true)
            setTurnScreenOn(true)

            // If you want to display the keyguard to prompt the user to unlock the phone:
            val keyguardManager =
                getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
            keyguardManager?.requestDismissKeyguard(this, null)
        } else {
            // For older versions, do it as you did before.
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED
                        or WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
                        or WindowManager.LayoutParams.FLAG_FULLSCREEN
                        or WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
                        or WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
                        or WindowManager.LayoutParams.FLAG_ALLOW_LOCK_WHILE_SCREEN_ON
            )
        }
    }

    private fun turnScreenOffAndKeyguardOn() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(false)
            setTurnScreenOn(false)
        } else {
            window.clearFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED
                        or WindowManager.LayoutParams.FLAG_FULLSCREEN
                        or WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
                        or WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
                        or WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
                        or WindowManager.LayoutParams.FLAG_ALLOW_LOCK_WHILE_SCREEN_ON
            )
        }
    }
}
