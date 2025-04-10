package funkin.backend.assets;

import lime.utils.AssetLibrary;
import flixel.graphics.frames.FlxFramesCollection;
import haxe.io.Path;
import funkin.backend.assets.LimeLibrarySymbol;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.Assets as OpenFlAssets;
import funkin.backend.assets.ModsFolder;
import funkin.backend.scripting.Script;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.graphics.FlxGraphic;

#if mobile
import openfl.utils.Assets;
#else
import lime.utils.Assets;
import openfl.media.Sound;
import openfl.display.BitmapData;
#end

using StringTools;

class Paths
{
	public static inline final SOUND_EXT = #if web "mp3" #else "ogg" #end;

	public static var assetsTree:AssetsLibraryList;
	public static var tempFramesCache:Map<String, FlxFramesCollection> = [];

	public static function init() {
		FlxG.signals.preStateSwitch.add(() -> tempFramesCache.clear());
	}

	public static inline function getPath(file:String, ?library:String)
		return library != null ? '$library:assets/$library/$file' : 'assets/$file';

	public static inline function video(key:String, ?ext:String = "mp4")
		return getPath('videos/$key.$ext');

	public static inline function ndll(key:String)
		return getPath('ndlls/$key.ndll');

	inline public static function file(file:String, ?library:String)
		return getPath(file, library);

	//inline public static function txt(key:String, ?library:String)
	//	return getPath('data/$key.txt', library);
	public static function txt(key:String):String
	{
		#if mobile
		var path = 'assets/data/$data/$key.txt';
		return Assets.getText(path);
		#else
		return 'mods/data/$data/$key.json';
		#end
	}

	inline public static function ini(key:String, ?library:String)
		return getPath('data/$key.ini', library);

	inline public static function xml(key:String, ?library:String)
		return getPath('data/$key.xml', library);

	public static function json(song:String, chartType:String = "normal"):String {
		#if mobile
		var path = 'assets/songs/$song/$chartType.json';
		return Assets.exists(path) ? path : null;
		#else
		return 'mods/songs/$song/$chartType.json';
		#end
	}

	public static function music(key:String):Sound {
		#if mobile
		return Assets.getSound('assets/music/$key.$SOUND_EXT');
		#else
		return Sound.fromFile('mods/music/$key.$SOUND_EXT');
		#end
	}

	public static function image(key:String, ?library:String, ?checkAtlas:Bool = false):BitmapData {
		#if mobile
		return Assets.getBitmapData('assets/images/$key.png');
		#else
		return BitmapData.fromFile('mods/images/$key.png');
		#end
	}

	public static function inst(song:String, difficulty:String = "normal", ?prefix:String = "") {
		final diff = getPath('songs/${song.toLowerCase()}/song/Inst$prefix-${difficulty.toLowerCase()}.$SOUND_EXT');
		return OpenFlAssets.exists(diff) ? diff : getPath('songs/${song.toLowerCase()}/song/Inst$prefix.$SOUND_EXT');
	}

	public static function voices(song:String, difficulty:String = "normal", ?prefix:String = "") {
		final diff = getPath('songs/${song.toLowerCase()}/song/Voices$prefix-${difficulty.toLowerCase()}.$SOUND_EXT');
		return OpenFlAssets.exists(diff) ? diff : getPath('songs/${song.toLowerCase()}/song/Voices$prefix.$SOUND_EXT');
	}

	public static function script(key:String, ?library:String, isAssetsPath:Bool = false) {
		var scriptPath = isAssetsPath ? key : getPath(key, library);
		if (!OpenFlAssets.exists(scriptPath)) {
			for (ex in Script.scriptExtensions) {
				var testPath = '$scriptPath.$ex';
				if (OpenFlAssets.exists(testPath)) return testPath;
			}
		}
		return scriptPath;
	}

	public static function character(character:String):String
		return getPath('data/characters/$character.xml');

	public static function font(key:String)
		return getPath('fonts/$key');

	inline public static function getFontName(font:String)
		return OpenFlAssets.exists(font, FONT) ? OpenFlAssets.getFont(font).fontName : font;

	public static function getSparrowAtlas(key:String, ?library:String)
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));

	// Outras funções de atlas mantidas como estão se necessário

	public static function getFrames(key:String, assetsPath:Bool = false, ?library:String):FlxFramesCollection {
		if (tempFramesCache.exists(key)) {
			var frames = tempFramesCache[key];
			if (frames.parent != null && frames.parent.bitmap != null && frames.parent.bitmap.readable)
				return frames;
			else
				tempFramesCache.remove(key);
		}
		return tempFramesCache[key] = loadFrames(assetsPath ? key : Paths.image(key, library, true));
	}

	static function loadFrames(path:String, Unique:Bool = false, Key:String = null, SkipAtlasCheck:Bool = false, SkipMultiCheck:Bool = false):FlxFramesCollection {
		var noExt = Path.withoutExtension(path);
		if (!SkipMultiCheck && Assets.exists('$noExt/1.png')) {
			var graphic = FlxG.bitmap.add("flixel/images/logo/default.png", false, '$noExt/mult');
			var frames = MultiFramesCollection.findFrame(graphic);
			if (frames != null) return frames;

			var cur = 1;
			var finalFrames = new MultiFramesCollection(graphic);
			while (Assets.exists('$noExt/$cur.png')) {
				finalFrames.addFrames(loadFrames('$noExt/$cur.png', false, null, false, true));
				cur++;
			}
			return finalFrames;
		} else if (Assets.exists('$noExt.xml')) {
			return Paths.getSparrowAtlasAlt(noExt);
		} else if (Assets.exists('$noExt.txt')) {
			return Paths.getPackerAtlasAlt(noExt);
		} else if (Assets.exists('$noExt.json')) {
			return Paths.getAsepriteAtlasAlt(noExt);
		}

		var graph:FlxGraphic = FlxG.bitmap.add(path, Unique, Key);
		if (graph == null) return null;
		return graph.imageFrame;
	}

	public static function getFolderContent(key:String, addPath:Bool = false, source:AssetsLibraryList.AssetSource = BOTH):Array<String> {
		if (!key.endsWith("/")) key += "/";
		var content = assetsTree.getFiles('assets/$key', source);
		if (addPath) for (k => e in content) content[k] = '$key$e';
		return content;
	}

	public static function getFolderDirectories(key:String, addPath:Bool = false, source:AssetsLibraryList.AssetSource = BOTH):Array<String> {
		if (!key.endsWith("/")) key += "/";
		var content = assetsTree.getFolders('assets/$key', source);
		if (addPath) for (k => e in content) content[k] = '$key$e';
		return content;
	}
}