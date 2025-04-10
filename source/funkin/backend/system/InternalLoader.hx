package funkin.backend.system;

import openfl.utils.Assets;
import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import lime.utils.AssetManifest;

class InternalLoader
{
	public static function loadImage(path:String):FlxGraphic
	{
		#if mobile
		var fullPath:String = 'assets/images/$path.png';
		if (Assets.exists(fullPath, IMAGE))
			return FlxG.bitmap.add(Assets.getBitmapData(fullPath));
		else
			return null;
		#else
		return FlxG.bitmap.add(path);
		#end
	}

	public static function loadText(path:String):String
	{
		#if mobile
		var fullPath:String = 'assets/data/$path.txt';
		if (Assets.exists(fullPath, TEXT))
			return Assets.getText(fullPath);
		else
			return null;
		#else
		return sys.io.File.getContent(path);
		#end
	}

	public static function loadJson(path:String):Dynamic
	{
		var content:String = loadText(path);
		if (content != null)
			return haxe.Json.parse(content);
		else
			return null;
	}

	public static function loadSound(path:String):Dynamic
	{
		#if mobile
		var fullPath:String = 'assets/sounds/$path.ogg';
		if (Assets.exists(fullPath, SOUND))
			return Assets.getSound(fullPath);
		else
			return null;
		#else
		return openfl.media.Sound.fromFile('assets/sounds/$path.ogg');
		#end
	}
}