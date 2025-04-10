package funkin.backend.system.modules;

import openfl.events.UncaughtErrorEvent;
import openfl.events.ErrorEvent;
import openfl.errors.Error;
#if sys
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;
using flixel.util.FlxArrayUtil;

import openfl.Lib;
import lime.system.System;
import haxe.CallStack;
import haxe.io.Path;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFieldAutoSize;

/**
 * Crash Handler.
 * @author YoshiCrafter29, Ne_Eo, MAJigsaw77 and Homura Akemi (HomuHomu833)
 * @author Sysource
 */
class CrashHandler
{
	public static function crash(error:Dynamic):Void
	{
		final errMsg:String = Std.string(error) + "\n" + callStackToString(CallStack.exceptionStack());
		showCrashMessage(errMsg);
	}

	static function showCrashMessage(message:String):Void
	{
		var textField:TextField = new TextField();
		textField.defaultTextFormat = new TextFormat("_sans", 20, 0xFF0000, true);
		textField.autoSize = TextFieldAutoSize.LEFT;
		textField.multiline = true;
		textField.wordWrap = true;
		textField.width = Lib.current.stage.stageWidth - 40;
		textField.x = 20;
		textField.y = 20;
		textField.text = "Oops! Something goes wrong!:\n\n" + message;

		var container:Sprite = new Sprite();
		container.graphics.beginFill(0x000000, 0.85);
		container.graphics.drawRect(0, 0, Lib.current.stage.stageWidth, Lib.current.stage.stageHeight);
		container.graphics.endFill();
		container.addChild(textField);
		Lib.current.addChild(container);
	}

	public static function init():Void
	{
		openfl.Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtError);
		#if cpp
		untyped __global__.__hxcpp_set_critical_error_handler(onError);
		#elseif hl
		hl.Api.setErrorHandler(onError);
		#end
	}

	private static function onUncaughtError(e:UncaughtErrorEvent):Void
	{
		e.preventDefault();
		e.stopPropagation();
		e.stopImmediatePropagation();

		var m:String = e.error;
		if (Std.isOfType(e.error, Error))
		{
			var err = cast(e.error, Error);
			m = '${err.message}';
		}
		else if (Std.isOfType(e.error, ErrorEvent))
		{
			var err = cast(e.error, ErrorEvent);
			m = '${err.text}';
		}
		var stack = haxe.CallStack.exceptionStack();
		var stackLabelArr:Array<String> = [];
		var stackLabel:String = "";
		for (e in stack)
		{
			switch (e)
			{
				case CFunction:
					stackLabelArr.push("Non-Haxe (C) Function");
				case Module(c):
					stackLabelArr.push('Module ${c}');
				case FilePos(parent, file, line, col):
					switch (parent)
					{
						case Method(cla, func):
							stackLabelArr.push('${haxe.io.Path.withoutExtension(file)}.$func() [line $line]');
						case _:
							stackLabelArr.push('${file} [line $line]');
					}
				case LocalFunction(v):
					stackLabelArr.push('Local Function ${v}');
				case Method(cl, m):
					stackLabelArr.push('${cl} - ${m}');
			}
		}
		stackLabel = stackLabelArr.join('\r\n');

		#if sys
		saveErrorMessage('$m\n$stackLabel');
		#end

		NativeAPI.showMessageBox("Error!", '$m\n$stackLabel');
		lime.system.System.exit(1);
	}

	#if (cpp || hl)
	private static function onError(message:Dynamic):Void
	{
		final log:Array<String> = [];

		if (message != null && message.length > 0)
			log.push(message);

		log.push(haxe.CallStack.toString(haxe.CallStack.exceptionStack(true)));

		#if sys
		saveErrorMessage(log.join('\n'));
		#end

		NativeAPI.showMessageBox("Critical Error!", log.join('\n'));
		#if DISCORD_ALLOWED DiscordClient.shutdown(); #end
		lime.system.System.exit(1);
	}
	#end

	#if sys
	private static function saveErrorMessage(message:String):Void
	{
		final folder:String = #if android StorageUtil.getStorageDirectory() + #end 'crash/';
		try
		{
			if (!FileSystem.exists(folder))
				FileSystem.createDirectory(folder);

			File.saveContent(folder
				+ Date.now().toString().replace(' ', '-').replace(':', "'")
				+ '.txt', message);
		}
		catch (e:haxe.Exception)
			trace('Couldn\'t save error message. (${e.message})');
	}
	#end
}