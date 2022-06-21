package options;

import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;

class NotesPromptSubState extends MusicBeatSubstate
{
	var noteSkinList:Array<String> = [];
	var noteSkins:Array<String> = [];

	var curSelected = 0;

	var selectText:Alphabet;

	override function create()
	{
		super.create();

		NoteskinHelper.reloadNoteSkinFiles();

		for (skin in NoteskinHelper.noteSkins.keys())
			if(!noteSkins.contains(skin)) noteSkins.push(skin);

		if(!noteSkins.contains(ClientPrefs.noteSkin)) {
			ClientPrefs.noteSkin = 'Unknown';
			curSelected = 0;
			noteSkins.insert(0, 'Unknown');
		}

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		bg.alpha = 0.3;
		add(bg);

		var infoText:Alphabet = new Alphabet(0, FlxG.height / 3, 'Choose your Noteskin', true);
		infoText.screenCenter(X);
		add(infoText);

		selectText = new Alphabet(0, 0, noteSkins[curSelected]);
		selectText.y = infoText.y + selectText.height + 50;
		add(selectText);
	}

	override function close()
	{
		FlxG.mouse.visible = false;
		changeSelection();
		super.close();
	}

	override function update(elasped)
	{
		super.update(elasped);

		if (controls.UI_LEFT_P)
			changeSelection(-1);
		if (controls.UI_RIGHT_P)
			changeSelection(1);

		if (controls.ACCEPT)
		{
			ClientPrefs.noteSkin = noteSkins[curSelected];
			ClientPrefs.saveSettings();
			FlxG.sound.play(Paths.sound('confirmMenu'));
			close();
		}

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			close();
		}
	}

	function changeSelection(change:Int = 0)
	{
		curSelected += change;
		if(noteSkins.contains('Unknown')) noteSkins.remove('Unknown');

		if (curSelected < 0)
			curSelected = noteSkins.length - 1;
		if (curSelected >= noteSkins.length)
			curSelected = 0;

		selectText.changeText('< ' + noteSkins[curSelected] + ' >');
		selectText.screenCenter(X);

		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}
