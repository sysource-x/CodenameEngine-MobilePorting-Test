package funkin.backend.assets;

import funkin.backend.system.MainState;
import funkin.menus.TitleState;
import funkin.backend.system.Main;

import lime.text.Font;
import lime.media.AudioBuffer;
import lime.utils.Bytes;
import lime.graphics.Image;
import openfl.utils.Assets;
import openfl.text.Font as OpenFLFont;

import flixel.util.FlxSignal.FlxTypedSignal;
import openfl.utils.AssetManifest;
import openfl.utils.AssetLibrary;

import flixel.FlxG;

using StringTools;

class ModsFolder {
	public static var onModSwitch:FlxTypedSignal<String->Void> = new FlxTypedSignal<String->Void>();

	public static var currentModFolder:String = null;

	public static var modsPath:String = "assets/mods/";
	public static var addonsPath:String = "assets/addons/";

	public static var useLibFile:Bool = true;

	private static var __firstTime:Bool = true;

	public static function init() {
		if (!getModsList().contains(Options.lastLoadedMod))
			Options.lastLoadedMod = null;
	}

	public static function switchMod(mod:String) {
		Options.lastLoadedMod = currentModFolder = mod;
		reloadMods();
	}

	public static function reloadMods() {
		if (!__firstTime)
			FlxG.switchState(new MainState());
		__firstTime = false;
	}

	public static function loadModLib(path:String, force:Bool = false, ?modName:String) {
		return loadLibraryFromFolder(path.toLowerCase(), path, force, modName);
	}

	public static function getModsList():Array<String> {
		final list:Array<String> = [];
		for (asset in Assets.list()) {
			if (asset.startsWith("assets/mods/")) {
				var modName = asset.substr("assets/mods/".length).split("/")[0];
				if (!list.contains(modName)) list.push(modName);
			}
		}
		return list;
	}

	public static function getAddonsList():Array<String> {
		final list:Array<String> = [];
		for (asset in Assets.list()) {
			if (asset.startsWith("assets/addons/")) {
				var addonName = asset.substr("assets/addons/".length).split("/")[0];
				if (!list.contains(addonName)) list.push(addonName);
			}
		}
		return list;
	}

	public static function getLoadedMods():Array<String> {
		var libs = [];
		for (i in Paths.assetsTree.libraries) {
			var l = i;
			if (l is openfl.utils.AssetLibrary) {
				var al = cast(l, openfl.utils.AssetLibrary);
				@:privateAccess
				if (al.__proxy != null) l = al.__proxy;
			}
			var libString:String;
			if (l is ScriptedAssetLibrary || l is IModsAssetLibrary) libString = cast(l, IModsAssetLibrary).modName;
			else continue;
			libs.push(libString);
		}
		return libs;
	}

	public static function prepareLibrary(libName:String, force:Bool = false) {
		var assets:AssetManifest = new AssetManifest();
		assets.name = libName;
		assets.version = 2;
		assets.libraryArgs = [];
		assets.assets = [];
		return AssetLibrary.fromManifest(assets);
	}

	public static function registerFont(font:Font) {
		var openflFont = new OpenFLFont();
		@:privateAccess
		openflFont.__fromLimeFont(font);
		OpenFLFont.registerFont(openflFont);
		return font;
	}

	public static function prepareModLibrary(libName:String, lib:IModsAssetLibrary, force:Bool = false) {
		var openLib = prepareLibrary(libName, force);
		lib.prefix = 'assets/';
		@:privateAccess
		openLib.__proxy = cast(lib, lime.utils.AssetLibrary);
		return openLib;
	}

	public static function loadLibraryFromFolder(libName:String, folder:String, force:Bool = false, ?modName:String) {
		return prepareModLibrary(libName, new InternalModsFolder(folder, libName, modName), force);
	}
}