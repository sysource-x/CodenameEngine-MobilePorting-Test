package funkin.backend.assets;

import openfl.utils.Assets;
import lime.text.Font;
import lime.media.AudioBuffer;
import lime.utils.Bytes;
import lime.graphics.Image;

using StringTools;

class InternalModsFolder implements IModsAssetLibrary {
	public var path:String;
	public var modName:String;
	public var libName:String;
	public var prefix:String;

	public function new(path:String, libName:String, ?modName:String) {
		this.path = path;
		this.libName = libName;
		this.modName = modName != null ? modName : libName;
		this.prefix = '$path/';
	}

	public function exists(id:String, type:String):Bool {
		return Assets.exists(prefix + id, type);
	}

	public function getPath(id:String):String {
		return prefix + id;
	}

	public function getBytes(id:String):Bytes {
		if (!exists(id, "BINARY")) return null;
		return Assets.getBytes(prefix + id);
	}

	public function getImage(id:String):Image {
		if (!exists(id, "IMAGE")) return null;
		return Assets.getImage(prefix + id);
	}

	public function getFont(id:String):Font {
		if (!exists(id, "FONT")) return null;
		return Assets.getFont(prefix + id);
	}

	public function getAudioBuffer(id:String):AudioBuffer {
		if (!exists(id, "SOUND")) return null;
		return Assets.getSound(prefix + id).audio;
	}

	// Lista todos os arquivos dentro de uma pasta do mod
	public function getFiles(folder:String):Array<String> {
		if (!folder.endsWith("/")) folder += "/";
		var found:Array<String> = [];
		var checkPrefix = prefix + folder;
		for (asset in Assets.list()) {
			if (asset.startsWith(checkPrefix)) {
				found.push(asset.substr(prefix.length));
			}
		}
		return found;
	}
}