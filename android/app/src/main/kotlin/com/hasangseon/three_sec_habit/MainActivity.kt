package com.hasangseon.three_sec_habit

import android.media.AudioAttributes
import android.media.MediaPlayer
import android.media.Ringtone
import android.media.RingtoneManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val soundChannelName = "com.hasangseon.three_sec_habit/sound"
    private var mediaPlayer: MediaPlayer? = null
    private var defaultRingtone: Ringtone? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, soundChannelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "playPreview" -> {
                        val soundKey = call.argument<String>("soundKey") ?: "default"
                        playPreviewSound(soundKey)
                        result.success(null)
                    }
                    "stopPreview" -> {
                        stopPreviewSound()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun stopPreviewSound() {
        try {
            mediaPlayer?.apply {
                if (isPlaying) stop()
                release()
            }
        } catch (_: Throwable) {}
        mediaPlayer = null

        try {
            defaultRingtone?.stop()
        } catch (_: Throwable) {}
        defaultRingtone = null
    }

    private fun playPreviewSound(soundKey: String) {
        stopPreviewSound()
        if (soundKey == "default" || soundKey.isBlank()) {
            try {
                val uri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
                defaultRingtone = RingtoneManager.getRingtone(applicationContext, uri)
                defaultRingtone?.play()
            } catch (_: Throwable) {}
            return
        }

        try {
            val resId = resources.getIdentifier(soundKey, "raw", packageName)
            if (resId == 0) return
            val player = MediaPlayer()
            player.setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
                    .build()
            )
            val afd = resources.openRawResourceFd(resId) ?: return
            player.setDataSource(afd.fileDescriptor, afd.startOffset, afd.length)
            afd.close()
            player.setOnCompletionListener {
                try {
                    it.release()
                } catch (_: Throwable) {}
                if (mediaPlayer === it) {
                    mediaPlayer = null
                }
            }
            player.prepare()
            player.start()
            mediaPlayer = player
        } catch (_: Throwable) {}
    }

    override fun onDestroy() {
        stopPreviewSound()
        super.onDestroy()
    }
}
