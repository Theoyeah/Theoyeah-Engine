package;

import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import lime.app.Application;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import flixel.util.FlxStringUtil;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	static var menuItems:Array<String> = [];
	
	static var resumeL:String = 'Resume';
	static var restartL:String = 'Restart Song';
	static var changeL:String = 'Change Difficulty';
	static var optionsL:String = 'Options';
	static var exitL:String = 'Exit to menu';
	static var leaveL:String = 'Leave Charting Mode';
	static var skipL:String = 'Skip Time';
	static var endL:String = 'End Song';
	static var tog:String = 'Toggle Practice Mode';
	static var bot:String = 'Toggle Botplay';
	static var bac:String = 'BACK';

	var menuItemsOG:Array<String> = [resumeL, restartL, changeL, optionsL, exitL];
	var difficultyChoices = [];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;
	var practiceText:FlxText;
	var skipTimeText:FlxText;
	var skipTimeTracker:Alphabet;
	var curTime:Float = Math.max(0, Conductor.songPosition);
	//var botplayText:FlxText;

	public static var songName:String = '';

	
	public static var toOptions:Bool = false;
	
	public function new(x:Float, y:Float)
	{
		super();
		
		switch(ClientPrefs.language.toLowerCase()) {
			case 'francais':
				resumeL = 'Résumer';
				restartL = 'Redémarrer';
				changeL = 'Changer de Difficulté';
				optionsL = 'Choix';
				exitL = 'Quitter le menu';
				leaveL = 'Quitter le Mode Graphique';
				skipL = 'Sauter le Temps';
				endL = 'Chanson de Fin';
				tog = 'Basculer en Mode Entraînement';
				bot = 'Basculer le Botplay';
				bac = 'ARRIÈRE';
			case 'portugues':
				resumeL = 'Continuar Musica';
				restartL = 'Reiniciar Musica';
				changeL = 'Dificuldade de Mudança';
				optionsL = 'Opções';
				exitL = 'Sair para o menu';
				leaveL = 'Sair do Charting Mode';
				skipL = 'Pular Tempo';
				endL = 'Terminar Musica';
				tog = 'Ligar Modo Prática';
				bot = 'Ligar Botplay';
				bac = 'COSTAS';
			case 'spanish':
				resumeL = 'Continuar';
				restartL = 'Reiniciar';
				changeL = 'Cambiar Dificultad';
				optionsL = 'Opciones';
				exitL = 'Salir al Menú';
				leaveL = 'Salir Modo Charting';
				skipL = 'Saltar Tiempo';
				endL = 'Terminar Canción';
				tog = 'Alternar Modo Practicar';
				bot = 'Alternar Botplay';
				bac = 'ATRÁS';
			default:
				resumeL = 'Resume';
				restartL = 'Restart Song';
				changeL = 'Change Difficulty';
				optionsL = 'Options';
				exitL = 'Exit to menu';
				leaveL = 'Leave Charting Mode';
				skipL = 'Skip Time';
				endL = 'End Song';
				tog = 'Toggle Practice Mode';
				bot = 'Toggle Botplay';
				bac = 'BACK';
		}
		menuItemsOG = [resumeL, restartL, changeL, optionsL, exitL];

		if(CoolUtil.difficulties.length < 2 || CoolUtil.defaultDifficulties.length < 2) {
			menuItemsOG.remove(changeL); //No need to change difficulty if there is only one!
		}

		toOptions = false;
		
		if(PlayState.chartingMode)
		{
			menuItemsOG.insert(2, leaveL);
			
			var num:Int = 0;
			if(!PlayState.instance.startingSong)
			{
				num = 1;
				menuItemsOG.insert(3, skipL);
			}
			menuItemsOG.insert(3 + num, endL);
			menuItemsOG.insert(4 + num, tog);
			menuItemsOG.insert(5 + num, bot);
		}
		menuItems = menuItemsOG;

		for (i in 0...CoolUtil.difficulties.length) {
			var diff:String = '' + CoolUtil.difficulties[i];
			difficultyChoices.push(diff);
		}
		difficultyChoices.push(bac);


		pauseMusic = new FlxSound();
		if(songName != null) {
			pauseMusic.loadEmbedded(Paths.music(songName), true, true);
		} else if (songName != 'None') {
			pauseMusic.loadEmbedded(Paths.music(Paths.formatToSongPath(ClientPrefs.pauseMusic)), true, true);
		}
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		if(ClientPrefs.pauseMusic.toLowerCase() == 'none') {
			pauseMusic.volume = 0;
		}

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var pauseL:String = 'PAUSED';
		switch(ClientPrefs.language.toLowerCase()) {
			case 'francais':
				pauseL = 'EN PAUSE'; //please correct me if is incorrect
			case 'spanish':
				pauseL = 'PAUSADO';
			case 'portugues':
				pauseL = 'PAUSADO'; //please correct me if is incorrect
			default:
				pauseL = 'PAUSED';
		}

		Application.current.window.title = "Friday Night Funkin': Theoyeah Engine - " + PlayState.SONG.song + ' [' + CoolUtil.difficultyString() + '] [$pauseL]';

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, "", 32);
		levelDifficulty.text += CoolUtil.difficultyString();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		var blueballedTxt:FlxText = new FlxText(20, 15 + 64, 0, "", 32);
		blueballedTxt.text = "Blueballed: " + PlayState.deathCounter;
		blueballedTxt.scrollFactor.set();
		blueballedTxt.setFormat(Paths.font('vcr.ttf'), 32);
		blueballedTxt.updateHitbox();
		add(blueballedTxt);

		practiceText = new FlxText(20, 15 + 101, 0, "PRACTICE MODE", 32);
		practiceText.scrollFactor.set();
		practiceText.setFormat(Paths.font('vcr.ttf'), 32);
		practiceText.x = FlxG.width - (practiceText.width + 20);
		practiceText.updateHitbox();
		practiceText.visible = PlayState.instance.practiceMode;
		add(practiceText);

		var chartingText:FlxText = new FlxText(20, 15 + 101, 0, "CHARTING MODE", 32);
		chartingText.scrollFactor.set();
		chartingText.setFormat(Paths.font('vcr.ttf'), 32);
		chartingText.x = FlxG.width - (chartingText.width + 20);
		chartingText.y = FlxG.height - (chartingText.height + 20);
		chartingText.updateHitbox();
		chartingText.visible = PlayState.chartingMode;
		add(chartingText);

		blueballedTxt.alpha = 0;
		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);
		blueballedTxt.x = FlxG.width - (blueballedTxt.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
		FlxTween.tween(blueballedTxt, {alpha: 1, y: blueballedTxt.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		regenMenu();
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);
		updateSkipTextStuff();

		var upP:Bool = controls.UI_UP_P;
		var downP:Bool = controls.UI_DOWN_P;
		var accepted:Bool = controls.ACCEPT;

		if (upP || FlxG.mouse.wheel > 0)
		{
			changeSelection(-1);
		}
		if (downP || FlxG.mouse.wheel < 0)
		{
			changeSelection(1);
		}

		var daSelected:String = menuItems[curSelected];
		switch (daSelected)
		{
			case skipL:
				if (controls.UI_LEFT_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
					curTime -= 1000;
					holdTime = 0;
				}
				if (controls.UI_RIGHT_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
					curTime += 1000;
					holdTime = 0;
				}

				if(controls.UI_LEFT || controls.UI_RIGHT)
				{
					holdTime += elapsed;
					if(holdTime > 0.5)
					{
						curTime += 45000 * elapsed * (controls.UI_LEFT ? -1 : 1);
					}

					if(curTime >= FlxG.sound.music.length) curTime -= FlxG.sound.music.length;
					else if(curTime < 0) curTime += FlxG.sound.music.length;
					updateSkipTimeText();
				}
		}

		if (accepted)
		{
			if (menuItems == difficultyChoices)
			{
				if(menuItems.length - 1 != curSelected && difficultyChoices.contains(daSelected)) {
					var name:String = PlayState.SONG.song;
					var poop = Highscore.formatSong(name, curSelected);
					PlayState.SONG = Song.loadFromJson(poop, name);
					PlayState.storyDifficulty = curSelected;
					MusicBeatState.resetState();
					FlxG.sound.music.volume = 0;
					PlayState.changedDifficulty = true;
					PlayState.chartingMode = false;
					skipTimeTracker = null;

					if(skipTimeText != null)
					{
						skipTimeText.kill();
						remove(skipTimeText);
						skipTimeText.destroy();
					}
					skipTimeText = null;
					return;
				}

				menuItems = menuItemsOG;
				regenMenu();
			}

			switch (daSelected)
			{
				case 'Résumer' | 'Resume' | 'Continuar Musica' | 'Continuar':
					Application.current.window.title = "Friday Night Funkin': Theoyeah Engine - " + PlayState.SONG.song + ' [' + CoolUtil.difficultyString() + ']';
					close();
				case 'Changer de Difficulté' | 'Dificuldade de Mudança' | 'Cambiar Dificultad' | 'Change Difficulty':
					menuItems = difficultyChoices;
					regenMenu();
				case 'Alternar Modo Practicar' | 'Toggle Practice Mode' | 'Ligar Modo Prática' | 'Basculer en Mode Entraînement':
					PlayState.instance.practiceMode = !PlayState.instance.practiceMode;
					PlayState.changedDifficulty = true;
					practiceText.visible = PlayState.instance.practiceMode;
				case 'Redémarrer' | 'Reiniciar Musica' | 'Reiniciar' | 'Restart Song':
					restartSong();
				case 'Salir Modo Charting' | 'Leave Charting Mode' | 'Sair do Charting Mode' | 'Quitter le Mode Graphique':
					restartSong();
					PlayState.chartingMode = false;
				case 'Saltar Tiempo' | 'Skip Time' | 'Pular Tempo' | 'Sauter le Temps':
					if(curTime < Conductor.songPosition)
					{
						PlayState.startOnTime = curTime;
						restartSong(true);
					}
					else
					{
						if (curTime != Conductor.songPosition)
						{
							PlayState.instance.clearNotesBefore(curTime);
							PlayState.instance.setSongTime(curTime);
						}
						close();
					}
				case 'Chanson de Fin' | 'Terminar Musica' | 'Terminar Canción' | 'End Song':
					close();
					PlayState.instance.finishSong(true);
				case 'Ligar Botplay' | 'Basculer le Botplay' | 'Alternar Botplay' | 'Toggle Botplay':
					PlayState.instance.cpuControlled = !PlayState.instance.cpuControlled;
					PlayState.changedDifficulty = true;
					PlayState.instance.botplayTxt.visible = PlayState.instance.cpuControlled;
					PlayState.instance.botplayTxt.alpha = 1;
					PlayState.instance.botplaySine = 0;
				case 'Opciones' | 'Options' | 'Choix' | 'Opções':
					Application.current.window.title = "Friday Night Funkin': Theoyeah Engine";
					toOptions = true;
					MusicBeatState.switchState(new options.OptionsState());
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
				case 'Sair para o menu' | 'Salir al Menú' | 'Exit to menu' | 'Quitter le menu':
					PlayState.deathCounter = 0;
					PlayState.seenCutscene = false;

					WeekData.loadTheFirstEnabledMod();
					if(PlayState.isStoryMode) {
						MusicBeatState.switchState(new StoryMenuState());
						Application.current.window.title = "Friday Night Funkin': Theoyeah Engine";
					} else {
						MusicBeatState.switchState(new FreeplayState());
						Application.current.window.title = "Friday Night Funkin': Theoyeah Engine";
					}
					PlayState.cancelMusicFadeTween();
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
					PlayState.changedDifficulty = false;
					PlayState.chartingMode = false;
			}
		}
	}

	public static function restartSong(noTrans:Bool = false)
	{
		PlayState.instance.paused = true; // For lua
		FlxG.sound.music.volume = 0;
		PlayState.instance.vocals.volume = 0;

		if(noTrans)
		{
			FlxTransitionableState.skipNextTransOut = true;
			FlxG.resetState();
		}
		else
		{
			MusicBeatState.resetState();
		}
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));

				if(item == skipTimeTracker)
				{
					curTime = Math.max(0, Conductor.songPosition);
					updateSkipTimeText();
				}
			}
		}
	}

	/**
	 * Destroys the menu
	 */
	function regenMenu():Void {
		for (i in 0...grpMenuShit.members.length) {
			var obj = grpMenuShit.members[0];
			obj.kill();
			grpMenuShit.remove(obj, true);
			obj.destroy();
		}

		for (i in 0...menuItems.length) {
			var item = new Alphabet(0, 70 * i + 30, menuItems[i], true, false);
			item.isMenuItem = true;
			item.targetY = i;
			grpMenuShit.add(item);

			if(menuItems[i] == skipL)
			{
				skipTimeText = new FlxText(0, 0, 0, '', 64);
				skipTimeText.setFormat(Paths.font("vcr.ttf"), 64, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				skipTimeText.scrollFactor.set();
				skipTimeText.borderSize = 2;
				skipTimeTracker = item;
				add(skipTimeText);

				updateSkipTextStuff();
				updateSkipTimeText();
			}
		}
		curSelected = 0;
		changeSelection();
	}
	
	function updateSkipTextStuff()
	{
		if(skipTimeText == null|| skipTimeTracker == null) return;

		skipTimeText.x = skipTimeTracker.x + skipTimeTracker.width + 60;
		skipTimeText.y = skipTimeTracker.y;
		skipTimeText.visible = (skipTimeTracker.alpha >= 1);
	}

	function updateSkipTimeText()
	{
		skipTimeText.text = FlxStringUtil.formatTime(Math.max(0, Math.floor(curTime / 1000)), false) + ' / ' + FlxStringUtil.formatTime(Math.max(0, Math.floor(FlxG.sound.music.length / 1000)), false);
	}
}
