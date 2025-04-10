package funkin.backend.system.modules;

import lime.system.System;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.io.Path;
#if android
import lime.system.JNI;
#end

#if sys
import sys.io.File;
import sys.FileSystem;
#end

/*
 * A class that simply points OpenALSoft to a custom configuration file when
 * the game starts up.
 *
 * The config overrides a few global OpenALSoft settings with the aim of
 * improving audio quality on native targets.
 */
#if (!macro && android)
@:build(funkin.backend.system.modules.ALSoftConfig.setupConfig())
#end
class ALSoftConfig
{
	#if (desktop || android)
	#if android
	private static final ANDROID_OPENAL_CONFIG:String = '';
	#end

	public static function init():Void
	{
		var origin:String = #if android null #elseif hl Sys.getCwd() #else Sys.programPath() #end; // internal

		var configPath:String = Path.directory(Path.withoutExtension(origin));
		#if windows
		configPath += "/plugins/alsoft.ini";
		#elseif mac
		configPath = Path.directory(configPath) + "/Resources/plugins/alsoft.conf";
		#elseif android
	    // For no use external storage Android
	    JNI.createStaticMethod(
		    "org/libsdl/app/SDLActivity",
		    "nativeSetenv",
		    "(Ljava/lang/String;Ljava/lang/String;)V"
	    )("ALSOFT_CONF", "/assets/internal/alsoft.conf");
		#else
		configPath += "/plugins/alsoft.conf";
		#end

		#if !android
		Sys.putEnv("ALSOFT_CONF", configPath);
		#end
	}
	#end

	#if macro
	public static function setupConfig()
	{
		var fields = Context.getBuildFields();
		var pos = Context.currentPos();

		if (!FileSystem.exists('alsoft.txt')) return fields;

		var newFields = fields.copy();
		for (i => field in fields)
		{
			if (field.name == 'ANDROID_OPENAL_CONFIG')
			{
				newFields[i] = {
					name: 'ANDROID_OPENAL_CONFIG',
					access: [APrivate, AStatic, AFinal],
					kind: FVar(macro :String, macro $v{File.getContent('alsoft.txt')}),
					pos: pos,
				};
			}
		}

		return newFields;
	}
	#end
}