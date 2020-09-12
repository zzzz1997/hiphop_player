package com.zzapp.hiphop_player

import android.annotation.SuppressLint
import android.content.Context
import android.provider.MediaStore
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry.Registrar


/**
 * 音乐查询插件
 *
 * @author zzzz1997
 * @date 20200912
 */
class MusicPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {

    // 通道
    private var channel: MethodChannel? = null

    // 上下文
    private var context: Context? = null

    companion object {
        // 通道名
        val CHANNEL = "music"

        fun registerWith(registerWith: Registrar) {
            val instance = MusicPlugin()
            instance.channel = MethodChannel(registerWith.messenger(), CHANNEL)
            instance.context = registerWith.context()
            instance.channel!!.setMethodCallHandler(instance)
        }
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, CHANNEL)
        channel!!.setMethodCallHandler(this)
        context = binding.applicationContext
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    }

    @SuppressLint("Recycle")
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "find" -> {
//                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M
//                        && ContextCompat.checkSelfPermission(context!!, Manifest.permission.READ_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED) {
//                    ActivityCompat.requestPermissions(context!!, [Manifest.permission.READ_EXTERNAL_STORAGE], 1)
//                }
                val uri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI
                val contentResolver = context!!.contentResolver
                val cursor = contentResolver!!.query(uri, null, MediaStore.Audio.Media.IS_MUSIC + " = 1", null, null)
                        ?: return
                if (!cursor.moveToFirst()) {
                    return
                }
                val id = cursor.getColumnIndex(MediaStore.Audio.Media._ID)
                val artist = cursor.getColumnIndex(MediaStore.Audio.Media.ARTIST)
                val title = cursor.getColumnIndex(MediaStore.Audio.Media.TITLE)
                val album = cursor.getColumnIndex(MediaStore.Audio.Media.ALBUM)
                val duration = cursor.getColumnIndex(MediaStore.Audio.Media.DURATION)
                val albumId = cursor.getColumnIndex(MediaStore.Audio.Media.ALBUM_ID)

                val songs = ArrayList<HashMap<String, Any>>()
                do {
                    val song = HashMap<String, Any>()
                    val songId = cursor.getLong(id)
                    val songAlbumId = cursor.getLong(albumId)
                    song["id"] = songId
                    song["artist"] = cursor.getLong(artist)
                    song["title"] = cursor.getLong(title)
                    song["album"] = cursor.getLong(album)
                    song["duration"] = cursor.getLong(duration)
                    song["albumId"] = songAlbumId
                    song["uri"] = getUri(songId)
                    song["albumArt"] = getAlbumArt(songAlbumId)
                    songs.add(song)
                } while (cursor.moveToNext())
                cursor.close()
                result.success(songs)
            }
            else -> return
        }
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
        val cursor = context!!.contentResolver.query(mediaContentUri, projection, selection, selectionArgs, null)

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
        val cursor = context!!.contentResolver.query(MediaStore.Audio.Albums.EXTERNAL_CONTENT_URI, arrayOf(MediaStore.Audio.Albums._ID, MediaStore.Audio.Albums.ALBUM_ART),
                MediaStore.Audio.Albums._ID + "=?", arrayOf<String>(java.lang.String.valueOf(albumId)),
                null)

        if (cursor!!.moveToFirst()) {
            path = cursor.getString(cursor.getColumnIndex(MediaStore.Audio.Albums.ALBUM_ART))
        }
        cursor.close()
        return path
    }
}