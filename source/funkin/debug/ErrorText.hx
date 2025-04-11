package funkin.debug;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class ErrorText extends FlxState
{
	public var errorMsg:String;

	public function new(error:String)
	{
		super();
		errorMsg = error;
	}

	override function create()
	{
		super.create();

		var errorText = new FlxText(0, 0, FlxG.width, "Erro ao iniciar o jogo:\n\n" + errorMsg);
		errorText.setFormat("VCR OSD Mono", 20, FlxColor.RED, "center");
		errorText.borderStyle = FlxTextBorderStyle.OUTLINE;
		errorText.borderColor = FlxColor.BLACK;
		errorText.screenCenter();
		add(errorText);
	}
}
