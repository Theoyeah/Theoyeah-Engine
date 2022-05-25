package editors;

import ModsMenuState.ModMetadata;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.system.FlxSound;
#if MODS_ALLOWED
import sys.FileSystem;
#end

using StringTools;

class MasterEditorMenu extends MusicBeatState
{
	static var language:String = ClientPrefs.language.toLowerCase();
	static var weekEditor:String = if(language == 'spanish')
		'Editor de Weeks'
	else 
		'Week Editor';
	static var menuCharacterEditor:String = if(language == 'spanish')
		'Editor de Menú Personajes'
	else
		'Menu Character Editor';
	static var characterEditor:String = if(language == 'spanish')
		'Editor de Personajes'
	else
		'Character Editor';
	static var dialogueEditor:String = if(language == 'spanish')
		'Editor de Diálogo'
	else
		'Dialogue Editor';
	static var dialoguePortraitEditor:String = if(language == 'spanish')
		'Editor de Personajes de Diálogo'
	else
		'Dialogue Portrait Editor';
	static var chartEditor:String = if(language == 'spanish')
		'Editor de Chart'
	else
		'Chart Editor';
	static var stageEditor:String = if(language == 'spanish')
		'Editor de Stages'
	else
		'Stage Editor';
	static var modManager:String = if(language == 'spanish')
		'Mánager de Mods'
	else
		'Mod Manager';
	var options:Array<Dynamic> = [
		weekEditor,
		menuCharacterEditor,
		dialogueEditor,
		dialoguePortraitEditor,
		characterEditor,
		chartEditor,
		stageEditor,
		modManager
	];
	private var grpTexts:FlxTypedGroup<Alphabet>;
	private var directories:Array<String> = [null];

	private var curSelected = 0;
	private var curDirectory = 0;
	private var directoryTxt:FlxText;

	override function create()
	{
		FlxG.camera.bgColor = FlxColor.BLACK;
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Editors Main Menu", null);
		#end

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.scrollFactor.set();
		bg.color = 0xFF353535;
		add(bg);

		grpTexts = new FlxTypedGroup<Alphabet>();
		add(grpTexts);

		for (i in 0...options.length)
		{
			var leText:Alphabet = new Alphabet(0, (70 * i) + 30, options[i], true, false);
			leText.isMenuItem = true;
			leText.targetY = i;
			grpTexts.add(leText);
		}
		
		#if MODS_ALLOWED
		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 42).makeGraphic(FlxG.width, 42, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);

		directoryTxt = new FlxText(textBG.x, textBG.y + 4, FlxG.width, '', 32);
		directoryTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);
		directoryTxt.scrollFactor.set();
		add(directoryTxt);
		
		for (folder in Paths.getModDirectories())
		{
			directories.push(folder);
		}

		var found:Int = directories.indexOf(Paths.currentModDirectory);
		if(found > -1) curDirectory = found;
		changeDirectory();
		#end
		changeSelection();

		FlxG.mouse.visible = false;
		super.create();
	}

	override function update(elapsed:Float)
	{
		if (controls.UI_UP_P)
		{
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P)
		{
			changeSelection(1);
		}
		#if MODS_ALLOWED
		if(controls.UI_LEFT_P)
		{
			changeDirectory(-1);
		}
		if(controls.UI_RIGHT_P)
		{
			changeDirectory(1);
		}
		#end

		if (controls.BACK)
		{
			MusicBeatState.switchState(new MainMenuState());
		}

		if (controls.ACCEPT)
		{
			switch(options[curSelected]) {
				case characterEditor:
					LoadingState.loadAndSwitchState(new CharacterEditorState(Character.DEFAULT_CHARACTER, false));
				case weekEditor:
					MusicBeatState.switchState(new WeekEditorState());
				case menuCharacterEditor:
					MusicBeatState.switchState(new MenuCharacterEditorState());
				case dialoguePortraitEditor:
					LoadingState.loadAndSwitchState(new DialogueCharacterEditorState(), false);
				case dialogueEditor:
					LoadingState.loadAndSwitchState(new DialogueEditorState(), false);
				case chartEditor://felt it would be cool maybe
					LoadingState.loadAndSwitchState(new ChartingState(), false);
				case stageEditor:
					LoadingState.loadAndSwitchState(new StageEditorState(), false);
				case modManager:
					LoadingState.loadAndSwitchState(new ModsMenuState(), false);
					   
			}
			FlxG.sound.music.volume = 0;
			#if PRELOAD_ALL
			FreeplayState.destroyFreeplayVocals();
			#end
		}
		
		var bullShit:Int = 0;
		for (item in grpTexts.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
		super.update(elapsed);
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;
	}

	#if MODS_ALLOWED
	function changeDirectory(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curDirectory += change;

		if(curDirectory < 0)
			curDirectory = directories.length - 1;
		if(curDirectory >= directories.length)
			curDirectory = 0;
	
		WeekData.setDirectoryFromWeek();
		if(directories[curDirectory] == null || directories[curDirectory].length < 1)
			directoryTxt.text = if(language == 'spanish')
				'< Directorio de Mod No Cargado >'
			else
				'< No Mod Directory Loaded >';
		else
		{
			Paths.currentModDirectory = directories[curDirectory];
			directoryTxt.text = if(language == 'spanish')
				'< Cargado Directorio de Mod: ' + Paths.currentModDirectory + ' >'
			else
				'< Loaded Mod Directory: ' + Paths.currentModDirectory + ' >';
		}
		directoryTxt.text = directoryTxt.text.toUpperCase();
	}
	#end
}
