package com.zzapp.hiphop_player

import android.Manifest
import android.annotation.SuppressLint
import android.app.Activity
import android.content.pm.PackageManager
import android.os.Build
import android.provider.MediaStore
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry.Registrar


/**
 * 音乐查询插件
 *
 * @author zzzz1997
 * @date 20200912
 */
class MusicPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {

    // 通道
    private var channel: MethodChannel? = null

    // 活动
    private var activity: Activity? = null

    companion object {
        // 通道名
        val CHANNEL = "music"

        /**
         * 保留旧接入方式
         */
        fun registerWith(registerWith: Registrar) {
            val instance = MusicPlugin()
            instance.channel = MethodChannel(registerWith.messenger(), CHANNEL)
            instance.activity = registerWith.activity()
            instance.channel!!.setMethodCallHandler(instance)
        }
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, CHANNEL)
        channel!!.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    }

    @SuppressLint("Recycle")
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "find" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M
                        && ContextCompat.checkSelfPermission(activity!!, Manifest.permission.READ_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED) {
                    ActivityCompat.requestPermissions(activity!!, arrayOf(Manifest.permission.READ_EXTERNAL_STORAGE), 1)
                    result.success(null)
                    return
                }
                val contentResolver = activity!!.contentResolver
                val cursor = contentResolver!!.query(MediaStore.Audio.Media.EXTERNAL_CONTENT_URI, null, MediaStore.Audio.Media.IS_MUSIC + " = 1", null, null)
                        ?: return
                if (!cursor.moveToFirst()) {
                    result.success(null)
                    return
                }
                val id = cursor.getColumnIndex(MediaStore.Audio.Media._ID)
                val album = cursor.getColumnIndex(MediaStore.Audio.Media.ALBUM)
                val title = cursor.getColumnIndex(MediaStore.Audio.Media.TITLE)
                val artist = cursor.getColumnIndex(MediaStore.Audio.Media.ARTIST)
                val duration = cursor.getColumnIndex(MediaStore.Audio.Media.DURATION)
                val albumId = cursor.getColumnIndex(MediaStore.Audio.Media.ALBUM_ID)
                val uri = cursor.getColumnIndex(MediaStore.Audio.Media.DATA)

                val songs = ArrayList<HashMap<String, Any>>()
                do {
                    val songAlbum = cursor.getString(album)
                    val songTitle = cursor.getString(title)
                    val songArtist = cursor.getString(artist)
                    val songAlbumId = cursor.getLong(albumId)
                    val song = HashMap<String, Any>()
                    val extras = HashMap<String, Any>()
                    extras["albumId"] = songAlbumId
                    song["id"] = cursor.getString(uri)
                    song["album"] = songAlbum
                    song["title"] = songTitle
                    song["artist"] = songArtist
                    song["duration"] = cursor.getLong(duration)
                    song["artUri"] = getAlbumArt(songAlbumId)
                    song["displayTitle"] = songTitle
                    song["displaySubtitle"] = songArtist
                    song["displayDescription"] = songAlbum
                    song["extras"] = extras
                    songs.add(song)
                } while (cursor.moveToNext())
                cursor.close()
                result.success(songs)
            }
            else -> return
        }
    }

    override fun onDetachedFromActivity() {
        TODO("Not yet implemented")
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        TODO("Not yet implemented")
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    /**
     * 获取音乐链接
     *
     * @param id 媒体id
     */
    private fun getUri(id: Long): String {
        var uri = ""
        val mediaContentUri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI
        val projection = arrayOf(MediaStore.Audio.Media._ID, MediaStore.Audio.Media.ARTIST, MediaStore.Audio.Media.TITLE, MediaStore.Audio.Media.ALBUM,
                MediaStore.Audio.Media.DURATION, MediaStore.Audio.Media.DATA, MediaStore.Audio.Media.ALBUM_ID)
        val selection = MediaStore.Audio.Media._ID + "=?"
        val selectionArgs = arrayOf(id.toString())
        val cursor = activity!!.contentResolver.query(mediaContentUri, projection, selection, selectionArgs, null)

        if (cursor!!.count >= 0) {
            cursor.moveToPosition(0)
            uri = cursor.getString(cursor.getColumnIndex(MediaStore.Audio.Media.DATA))
        }
        cursor.close()
        return uri
    }

    /**
     * 获取音乐专辑封面
     *
     * @param albumId 专辑id
     */
    private fun getAlbumArt(albumId: Long): String {
        var path = ""
        val cursor = activity!!.contentResolver.query(MediaStore.Audio.Albums.EXTERNAL_CONTENT_URI, arrayOf(MediaStore.Audio.Albums._ID, MediaStore.Audio.Albums.ALBUM_ART),
                MediaStore.Audio.Albums._ID + "=?", arrayOf<String>(java.lang.String.valueOf(albumId)),
                null)

        if (cursor!!.moveToFirst()) {
            path = cursor.getString(cursor.getColumnIndex(MediaStore.Audio.Albums.ALBUM_ART))
        }
        cursor.close()
        return path
    }
}