package funkin.backend.assets;

import lime.utils.AssetLibrary;
import openfl.utils.Assets;
import lime.media.AudioBuffer;
import lime.graphics.Image;
import lime.text.Font;
import lime.utils.Bytes;

using StringTools;

class InternalAssetsLibrary extends AssetLibrary {
	public var libName:String;
	public var prefix:String;

	public function new(libName:String) {
		this.libName = libName;
		this.prefix = 'assets/$libName/';
		super();
	}

	public override function getImage(id:String):Image {
		if (!exists(id, "IMAGE")) return null;
		return Assets.getImage(prefix + id);
	}

	public override function getBytes(id:String):Bytes {
		if (!exists(id, "BINARY")) return null;
		return Assets.getBytes(prefix + id);
	}

	public override function getFont(id:String):Font {
		if (!exists(id, "FONT")) return null;
		return Assets.getFont(prefix + id);
	}

	public override function getAudioBuffer(id:String):AudioBuffer {
		if (!exists(id, "SOUND")) return null;
		return Assets.getSound(prefix + id).audio;
	}

	public override function getPath(id:String):String {
		// Não há caminho real em APKs
		return prefix + id;
	}

	public override function exists(id:String, type:String):Bool {
		final fullPath = prefix + id;
		return Assets.exists(fullPath, type);
	}

	public function getFilesInFolder(folder:String):Array<String> {
		var result:Array<String> = [];
		final targetPrefix = prefix + folder;
		for (asset in Assets.list()) {
			if (asset.startsWith(targetPrefix))
				result.push(asset.substr(prefix.length));
		}
		return result;
	}
}