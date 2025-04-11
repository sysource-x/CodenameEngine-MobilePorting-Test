package funkin.backend.assets;

import openfl.utils.Assets;
import openfl.utils.AssetType;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFramesCollection;
import funkin.backend.scripting.Script;
import haxe.io.Path;
import funkin.backend.assets.AssetsLibraryList;

using StringTools;

class Paths
{
	public static inline final SOUND_EXT = #if web "mp3" #else "ogg" #end;

	public static var tempFramesCache:Map<String, FlxFramesCollection> = [];

	public static function init() {
		FlxG.signals.preStateSwitch.add(() -> tempFramesCache.clear());
	}

	public static inline function getPath(file:String, ?library:String)
		return 'assets/$file';

	public static inline function video(key:String, ?ext:String = "mp4")
		return getPath('videos/$key.$ext');

	public static inline function ndll(key:String)
		return getPath('ndlls/$key.ndll');

	public static inline function file(file:String, ?library:String)
		return getPath(file);

	public static inline function txt(key:String, ?library:String)
		return getPath('data/$key.txt');

	public static inline function pack(key:String, ?library:String)
		return getPath('data/$key.pack');

	public static inline function ini(key:String, ?library:String)
		return getPath('data/$key.ini');

	public static inline function fragShader(key:String, ?library:String)
		return getPath('shaders/$key.frag');

	public static inline function vertShader(key:String, ?library:String)
		return getPath('shaders/$key.vert');

	public static inline function xml(key:String, ?library:String)
		return getPath('data/$key.xml');

	public static inline function json(key:String, ?library:String)
		return getPath('data/$key.json');

	public static inline function ps1(key:String, ?library:String)
		return getPath('data/$key.ps1');

	public static inline function sound(key:String, ?library:String)
		return getPath('sounds/$key.$SOUND_EXT');

	public static inline function soundRandom(key:String, min:Int, max:Int, ?library:String)
		return sound('$key${FlxG.random.int(min, max)}');

	public static inline function music(key:String, ?library:String)
		return getPath('music/$key.$SOUND_EXT');

	public static inline function voices(song:String, difficulty:String = "normal", ?prefix:String = "") {
		var lower = song.toLowerCase();
		var diff = getPath('songs/$lower/song/Voices$prefix-${difficulty.toLowerCase()}.$SOUND_EXT');
		return Assets.exists(diff) ? diff : getPath('songs/$lower/song/Voices$prefix.$SOUND_EXT');
	}

	public static inline function inst(song:String, difficulty:String = "normal", ?prefix:String = "") {
		var lower = song.toLowerCase();
		var diff = getPath('songs/$lower/song/Inst$prefix-${difficulty.toLowerCase()}.$SOUND_EXT');
		return Assets.exists(diff) ? diff : getPath('songs/$lower/song/Inst$prefix.$SOUND_EXT');
	}

	public static function image(key:String, ?library:String, checkForAtlas:Bool = false, ?ext:String = "png") {
		if (checkForAtlas) {
			var atlasPath = getPath('images/$key/spritemap.$ext');
			var multiplePath = getPath('images/$key/1.$ext');
			if (Assets.exists(atlasPath)) return atlasPath.substr(0, atlasPath.length - 14);
			if (Assets.exists(multiplePath)) return multiplePath.substr(0, multiplePath.length - 6);
		}
		return getPath('images/$key.$ext');
	}

	public static function script(key:String, ?library:String, isAssetsPath:Bool = false):String {
		var scriptPath = isAssetsPath ? key : getPath(key);
		if (!Assets.exists(scriptPath)) {
			for (ext in Script.scriptExtensions) {
				var p = '$scriptPath.$ext';
				if (Assets.exists(p)) return p;
			}
		}
		return scriptPath;
	}

	public static inline function chart(song:String, ?difficulty:String = "normal")
		return getPath('songs/${song.toLowerCase()}/charts/${difficulty.toLowerCase()}.json');

	public static inline function character(character:String)
		return getPath('data/characters/$character.xml');

	public static inline function getFontName(font:String)
		return Assets.exists(font, FONT) ? Assets.getFont(font).fontName : font;

	public static inline function font(key:String)
		return getPath('fonts/$key');

	public static inline function obj(key:String)
		return getPath('models/$key.obj');

	public static inline function dae(key:String)
		return getPath('models/$key.dae');

	public static inline function md2(key:String)
		return getPath('models/$key.md2');

	public static inline function md5(key:String)
		return getPath('models/$key.md5');

	public static inline function awd(key:String)
		return getPath('models/$key.awd');

	public static inline function getSparrowAtlas(key:String, ?library:String)
		return FlxAtlasFrames.fromSparrow(image(key), file('images/$key.xml'));

	public static inline function getSparrowAtlasAlt(key:String)
		return FlxAtlasFrames.fromSparrow('$key.png', '$key.xml');

	public static inline function getPackerAtlas(key:String, ?library:String)
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key), file('images/$key.txt'));

	public static inline function getPackerAtlasAlt(key:String)
		return FlxAtlasFrames.fromSpriteSheetPacker('$key.png', '$key.txt');

	public static inline function getAsepriteAtlas(key:String, ?library:String)
		return FlxAtlasFrames.fromAseprite(image(key), file('images/$key.json'));

	public static inline function getAsepriteAtlasAlt(key:String)
		return FlxAtlasFrames.fromAseprite('$key.png', '$key.json');

	public static inline function getAssetsRoot():String
		return 'assets';

	public static function getFrames(key:String, assetsPath:Bool = false, ?library:String) {
		if (tempFramesCache.exists(key)) {
			var frames = tempFramesCache[key];
			if (frames.parent != null && frames.parent.bitmap != null && frames.parent.bitmap.readable)
				return frames;
			else
				tempFramesCache.remove(key);
		}
		return tempFramesCache[key] = loadFrames(assetsPath ? key : Paths.image(key, false, true));
	}

	static function loadFrames(path:String, Unique:Bool = false, Key:String = null, SkipAtlasCheck:Bool = false, SkipMultiCheck:Bool = false):FlxFramesCollection {
		var noExt = Path.withoutExtension(path);

		if (!SkipMultiCheck && Assets.exists('$noExt/1.png')) {
			var graphic = FlxG.bitmap.add("flixel/images/logo/default.png", false, '$noExt/mult');
			var frames = new MultiFramesCollection(graphic);
			var cur = 1;
			while (Assets.exists('$noExt/$cur.png')) {
				var spr = loadFrames('$noExt/$cur.png', false, null, false, true);
				frames.addFrames(spr);
				cur++;
			}
			return frames;
		} else if (Assets.exists('$noExt.xml')) {
			return Paths.getSparrowAtlasAlt(noExt);
		} else if (Assets.exists('$noExt.txt')) {
			return Paths.getPackerAtlasAlt(noExt);
		} else if (Assets.exists('$noExt.json')) {
			return Paths.getAsepriteAtlasAlt(noExt);
		}

		var graph:FlxGraphic = FlxG.bitmap.add(path, Unique, Key);
		if (graph == null)
			return null;
		return graph.imageFrame;
	}

	public static function getFolderDirectories(key:String, addPath:Bool = false):Array<String> {
		return []; // não aplicável com assets internos
	}

	public static function getFolderContent(key:String, addPath:Bool = false):Array<String> {
		return []; // idem
	}

	@:noCompletion public static function getFilenameFromLibFile(path:String) {
		var file = new Path(path);
		if (file.file.startsWith("LIB_")) return file.dir + "." + file.ext;
		return path;
	}

	@:noCompletion public static function getLibFromLibFile(path:String) {
		var file = new Path(path);
		if (file.file.startsWith("LIB_")) return file.file.substr(4);
		return "";
	}
}
