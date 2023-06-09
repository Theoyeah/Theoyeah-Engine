package;

import flixel.math.FlxRandom;
import lime.system.System;
#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import haxe.Json;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end
import options.GraphicsSettingsSubState;
//import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;

using StringTools;
typedef TitleData =
{
	titlex:Float,
	titley:Float,
	startx:Float,
	starty:Float,
	gfx:Float,
	gfy:Float,
	backgroundSprite:String,
	bpm:Int
}
class TitleState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	public static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;
	var psychSpr:FlxSprite;
	var tySpr:FlxSprite;
	var wrSpr:FlxSprite;
	var dnSpr:FlxSprite;
	var coolguys:FlxSprite;

	var titleTextColors:Array<FlxColor> = [0xFF33FFFF, 0xFF3333CC];
	var titleTextAlphas:Array<Float> = [1, .64];
	var titleTextColorEnter:FlxColor = FlxColor.WHITE;

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;

	#if TITLE_SCREEN_EASTER_EGG
	var witherone = 'WITHER'; // I change it a lot of times...
	var easterEggKeys:Array<String> = [
		'THEOYEAH', 'WITHER', 'GABI', 'DEMOLITIONDON96', // May do it one day ?
		'SHADOW', 'RIVER', 'SHUBS', 'BBPANZU'
	];
	var allowedKeys:String = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'/* + 'Ñ@#€&*()"=-_;:/\\$£¥^[]{}ºª§|~¶<>'*/;
	var easterEggKeysBuffer:String = '';
	#end

	var mustUpdate:Bool = false;
	
	var titleJSON:TitleData;
	
	public static var updateVersion:String = '';

	override public function create():Void
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		#if LUA_ALLOWED
		Paths.pushGlobalMods();
		#end

		// Just to load a mod on start up if ya got one. For mods that change the menu music and bg
		WeekData.loadTheFirstEnabledMod();
		
		//trace(path, FileSystem.exists(path));

		/*#if (polymod && !html5)
		if (sys.FileSystem.exists('mods/')) {
			var folders:Array<String> = [];
			for (file in sys.FileSystem.readDirectory('mods/')) {
				var path = haxe.io.Path.join(['mods/', file]);
				if (sys.FileSystem.isDirectory(path)) {
					folders.push(file);
				}
			}
			if(folders.length > 0) {
				polymod.Polymod.init({modRoot: "mods", dirs: folders});
			}
		}
		#end*/

		FlxG.game.focusLostFramerate = 60;
		FlxG.sound.muteKeys = muteKeys;
		FlxG.sound.volumeDownKeys = volumeDownKeys;
		FlxG.sound.volumeUpKeys = volumeUpKeys;
		FlxG.keys.preventDefaultKeys = [TAB];

		PlayerSettings.init();

		curWacky = FlxG.random.getObject(getIntroTextShit());

		// DEBUG BULLSHIT

		swagShader = new ColorSwap();
		super.create();

		FlxG.save.bind('funkin', 'ninjamuffin99');

		ClientPrefs.loadPrefs();

		#if CHECK_FOR_UPDATES
		if(ClientPrefs.checkForUpdates && !closedState) {
			trace('checking for update');
			var http = new haxe.Http("https://raw.githubusercontent.com/Theoyeah/Theoyeah-Engine/main/gitVersion.txt");
			
			http.onData = function (data:String)
			{
				updateVersion = data.split('\n')[0].trim();
				var curVersion:String = MainMenuState.theoyeahEngineVersion.trim();
				trace('version online: ' + updateVersion + ', your version: ' + curVersion);
				if(updateVersion != curVersion) {
					trace('versions arent matching!');
					mustUpdate = true;
				}
			}

			http.onError = function (error) {
				trace('error: $error');
			}

			http.request();
		}
		#end

		Highscore.load();

		// IGNORE THIS!!!
		titleJSON = Json.parse(Paths.getTextFromFile('images/gfDanceTitle.json'));

		#if TITLE_SCREEN_EASTER_EGG
		if (FlxG.save.data.psychDevsEasterEgg == null) FlxG.save.data.psychDevsEasterEgg = ''; //Crash prevention
		switch(FlxG.save.data.psychDevsEasterEgg.toUpperCase())
		{
			case 'SHADOW':
				titleJSON.gfx += 210;
				titleJSON.gfy += 40;
			case 'RIVER':
				titleJSON.gfx += 100;
				titleJSON.gfy += 20;
			case 'SHUBS':
				titleJSON.gfx += 160;
				titleJSON.gfy -= 10;
			case 'BBPANZU':
				titleJSON.gfx += 45;
				titleJSON.gfy += 100;
		}
		trace(FlxG.save.data.psychDevsEasterEgg);
		#end

		if(FlxG.save.data.firstInitied == null) FlxG.save.data.firstInitied = false;
		if(!initialized)
		{
			if(FlxG.save.data != null && FlxG.save.data.fullscreen)
 			{
 				FlxG.fullscreen = FlxG.save.data.fullscreen;
 				//trace('LOADED FULLSCREEN SETTING!!');
 			}
 			persistentUpdate = true;
 			persistentDraw = true;
		}

		if (FlxG.save.data.weekCompleted != null)
		{
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}

		FlxG.mouse.visible = false;
		#if FREEPLAY
		MusicBeatState.switchState(new FreeplayState());
		#elseif CHARTING
		MusicBeatState.switchState(new ChartingState());
		#else
		if(FlxG.save.data.flashing == null && !FlashingState.leftState) {
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new FlashingState());
		} else {
			#if desktop
			if (!DiscordClient.isInitialized)
			{
				DiscordClient.initialize();
				Application.current.onExit.add(function (exitCode) {
					DiscordClient.shutdown();
				});
			}
			#end

			if (initialized)
				startIntro();
			else
			{
				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					startIntro();
				});
			}
		}
		#end
	}

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;
	var swagShader:ColorSwap = null;

	function startIntro()
	{
		if (!initialized)
		{
			/*var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
			diamond.persist = true;
			diamond.destroyOnNoUse = false;

			FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
				new FlxRect(-300, -300, FlxG.width * 1.8, FlxG.height * 1.8));
			FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1),
				{asset: diamond, width: 32, height: 32}, new FlxRect(-300, -300, FlxG.width * 1.8, FlxG.height * 1.8));

			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;*/

			// HAD TO MODIFY SOME BACKEND SHIT
			// IF THIS PR IS HERE IF ITS ACCEPTED UR GOOD TO GO
			// https://github.com/HaxeFlixel/flixel-addons/pull/348

			// var music:FlxSound = new FlxSound();
			// music.loadStream(Paths.music('freakyMenu'));
			// FlxG.sound.list.add(music);
			// music.play();

			if(FlxG.sound.music == null) {
				FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
			}
		}

		Conductor.changeBPM(titleJSON.bpm);
		persistentUpdate = true;

		var bg:FlxSprite = new FlxSprite();

		if (titleJSON.backgroundSprite != null && titleJSON.backgroundSprite.length > 0 && titleJSON.backgroundSprite != "none") {
			bg.loadGraphic(Paths.image(titleJSON.backgroundSprite));
		} else {
			bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		}

		// bg.antialiasing = ClientPrefs.globalAntialiasing;
		// bg.setGraphicSize(Std.int(bg.width * 0.6));
		// bg.updateHitbox();
		add(bg);

		#if ACHIEVEMENTS_ALLOWED
		var leDate = Date.now();
		#end
		logoBl = new FlxSprite(titleJSON.titlex, titleJSON.titley);
		logoBl.frames =
			#if ACHIEVEMENTS_ALLOWED
			if(leDate.getDay() == 6 && leDate.getHours() >= 18) {
				Paths.getSparrowAtlas('saturdayLogoBumpin');
			} else {
				Paths.getSparrowAtlas('logoBumpin');
			}
			#else
				Paths.getSparrowAtlas('logoBumpin');
			#end

		logoBl.antialiasing = ClientPrefs.globalAntialiasing;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();
		// logoBl.screenCenter();
		// logoBl.color = FlxColor.BLACK;

		swagShader = new ColorSwap();
		gfDance = new FlxSprite(titleJSON.gfx, titleJSON.gfy);

		var easterEgg:String = FlxG.save.data.psychDevsEasterEgg;
		if(easterEgg == null) easterEgg = ''; //html5 fix

		switch(easterEgg.toUpperCase())
		{
			#if TITLE_SCREEN_EASTER_EGG
			case 'SHADOW':
				gfDance.frames = Paths.getSparrowAtlas('ShadowBump');
				gfDance.animation.addByPrefix('danceLeft', 'Shadow Title Bump', 24);
				gfDance.animation.addByPrefix('danceRight', 'Shadow Title Bump', 24);
			case 'RIVER':
				gfDance.frames = Paths.getSparrowAtlas('RiverBump');
				gfDance.animation.addByIndices('danceLeft', 'River Title Bump', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				gfDance.animation.addByIndices('danceRight', 'River Title Bump', [29, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
			case 'SHUBS':
				gfDance.frames = Paths.getSparrowAtlas('ShubBump');
				gfDance.animation.addByPrefix('danceLeft', 'Shub Title Bump', 24, false);
				gfDance.animation.addByPrefix('danceRight', 'Shub Title Bump', 24, false);
			case 'BBPANZU':
				gfDance.frames = Paths.getSparrowAtlas('BBBump');
				gfDance.animation.addByIndices('danceLeft', 'BB Title Bump', [14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27], "", 24, false);
				gfDance.animation.addByIndices('danceRight', 'BB Title Bump', [27, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13], "", 24, false);
			case '$witherone':
				if(FlxG.sound.music != null)
					FlxG.sound.music.pitch = 1.01;
				/*swagShader.hue = new FlxRandom().float(0, 100);
				swagShader.saturation = new FlxRandom().float(0, 100);
				swagShader.brightness = new FlxRandom().float(0, 100);*/
			#end

			default:
			//EDIT THIS ONE IF YOU'RE MAKING A SOURCE CODE MOD!!!!
			//EDIT THIS ONE IF YOU'RE MAKING A SOURCE CODE MOD!!!!
			//EDIT THIS ONE IF YOU'RE MAKING A SOURCE CODE MOD!!!!
				gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
				gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		}
		gfDance.antialiasing = ClientPrefs.globalAntialiasing;

		add(gfDance);
		gfDance.shader = swagShader.shader;
		add(logoBl);
		logoBl.shader = swagShader.shader;

		titleText = new FlxSprite(titleJSON.startx, titleJSON.starty);
		#if MODS_ALLOWED
		var path = Paths.currentModImages('titleEnter');
		//trace(path, FileSystem.exists(path));
		if (!FileSystem.exists(path)) {
			path = 'assets/images/titleEnter.png';
		}
		//trace(path, FileSystem.exists(path));
		titleText.frames = FlxAtlasFrames.fromSparrow(BitmapData.fromFile(path), File.getContent(StringTools.replace(path, '.png', '.xml')));
		#else

		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		#end
		var animFrames:Array<FlxFrame> = [];
		@:privateAccess {
			titleText.animation.findByPrefix(animFrames, "ENTER IDLE");
			titleText.animation.findByPrefix(animFrames, "ENTER FREEZE");
		}

		if (animFrames.length > 0) {
			newTitle = true;

			titleText.animation.addByPrefix('idle', "ENTER IDLE", 24);
			titleText.animation.addByPrefix('press', ClientPrefs.flashing ? "ENTER PRESSED" : "ENTER FREEZE", 24);
		}
		else {
			newTitle = false;

			titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
			titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		}

		titleText.antialiasing = ClientPrefs.globalAntialiasing;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		// titleText.screenCenter(X);
		add(titleText);

		var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('logo'));
		logo.screenCenter();
		logo.antialiasing = ClientPrefs.globalAntialiasing;
		/* add(logo);


		FlxTween.tween(logoBl, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});
		FlxTween.tween(logo, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});*/

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		if (ClientPrefs.introbg) {
			blackScreen = new FlxSprite().loadGraphic(Paths.image('menutheme'));
		} else {
			blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		}
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "", true);
		credTextShit.screenCenter();

		// credTextShit.alignment = CENTER;

		credTextShit.visible = false;

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('newgrounds_logo'));
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = ClientPrefs.globalAntialiasing;


		psychSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('psych_logo'));
		add(psychSpr);
		psychSpr.visible = false;
		psychSpr.setGraphicSize(Std.int(psychSpr.width * 0.8));
		psychSpr.updateHitbox();
		psychSpr.screenCenter(X);
		psychSpr.antialiasing = ClientPrefs.globalAntialiasing;

		tySpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('theoyeah_logo'));
		add(tySpr);
		tySpr.visible = false;
		tySpr.setGraphicSize(Std.int(125 * 0.74)); //i dont know how this works, edit it later theoyeah to correct the image and all that
		tySpr.updateHitbox();
		tySpr.screenCenter(X);

		wrSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('wither_logo'));
		add(wrSpr);
		wrSpr.visible = false;
		wrSpr.setGraphicSize(800, 600);
		wrSpr.updateHitbox();
		wrSpr.screenCenter(X);

		dnSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('demolitiondon_logo'));
		add(dnSpr);
		dnSpr.visible = false;
		dnSpr.setGraphicSize(436, 436);
		dnSpr.updateHitbox();
		dnSpr.screenCenter(X);

		coolguys = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('demolitiondon_wither_logo'));
		add(coolguys);
		coolguys.visible = false;
		coolguys.setGraphicSize(Std.int(coolguys.width * 0.8));
		coolguys.updateHitbox();
		coolguys.screenCenter(X);
		coolguys.antialiasing = ClientPrefs.globalAntialiasing;



		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		if (initialized)
			skipIntro();
		else
			initialized = true;

		// credGroup.add(credTextShit);
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;
	private static var playJingle:Bool = false;

	var newTitle:Bool = false;
	var titleTimer:Float = 0;

	override function update(elapsed:Float)
	{
		if(FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		var pressedEnter:Bool = ((FlxG.keys.justPressed.ENTER || controls.ACCEPT || FlxG.mouse.justPressed) #if !debug && FlxG.save.data.firstInitied #end);

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}


		if (newTitle) {
			titleTimer += CoolUtil.boundTo(elapsed, 0, 1);
			if (titleTimer > 2)
				titleTimer -= 2;
		}


		// EASTER EGG

		if (initialized && !transitioning && skippedIntro)
		{
			if (newTitle && !pressedEnter)
			{
				var timer:Float = titleTimer;
				if (timer >= 1)
					timer = (-timer) + 2;

				timer = FlxEase.quadInOut(timer);

				if(titleText != null) {
					titleText.color = FlxColor.interpolate(titleTextColors[0], titleTextColors[1], timer);
					titleText.alpha = FlxMath.lerp(titleTextAlphas[0], titleTextAlphas[1], timer);
				}
			}

			if(pressedEnter)
			{
				if(titleText != null) {
					titleText.color = titleTextColorEnter;
					titleText.alpha = 1;
					titleText.animation.play('press');
				}

				if(ClientPrefs.flashing) {
					FlxG.camera.flash(titleTextColorEnter, 1);
				}
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

				transitioning = true;
				// FlxG.sound.music.stop();

				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					if (mustUpdate)
						MusicBeatState.switchState(new OutdatedState());
					else
						MusicBeatState.switchState(new MainMenuState());

					closedState = true;
				});
				// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
			}
			#if TITLE_SCREEN_EASTER_EGG
			else if (FlxG.keys.firstJustPressed() != FlxKey.NONE)
			{
				var keyPressed:FlxKey = FlxG.keys.firstJustPressed();
				var keyName:String = Std.string(keyPressed);
				if(allowedKeys.contains(keyName)) {
					easterEggKeysBuffer += keyName;
					if(easterEggKeysBuffer.length >= 32) easterEggKeysBuffer = easterEggKeysBuffer.substring(1);
					//trace('Test! Allowed Key pressed!!! Buffer: ' + easterEggKeysBuffer);

					for (wordRaw in easterEggKeys)
					{
						var word:String = wordRaw.toUpperCase(); //just for being sure you're doing it right
						if (easterEggKeysBuffer.contains(word))
						{
							//trace('YOOO! ' + word);
							if (FlxG.save.data.psychDevsEasterEgg == word)
								FlxG.save.data.psychDevsEasterEgg = '';
							else
								FlxG.save.data.psychDevsEasterEgg = word;
							FlxG.save.flush();

							FlxG.sound.play(Paths.sound('ToggleJingle'));

							var black:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
							black.alpha = 0;
							add(black);

							FlxTween.tween(black, {alpha: 1}, 1, {onComplete:
								function(twn:FlxTween) {
									FlxTransitionableState.skipNextTransIn = true;
									FlxTransitionableState.skipNextTransOut = true;
									MusicBeatState.switchState(new TitleState());
								}
							});
							FlxG.sound.music.fadeOut();
							if(FreeplayState.vocals != null)
							{
								FreeplayState.vocals.fadeOut();
							}
							closedState = true;
							transitioning = true;
							playJingle = true;
							easterEggKeysBuffer = '';

							break;
						}
					}
				}
			}
			#end
		}

		if (initialized && pressedEnter && !skippedIntro)
		{
			skipIntro();
		}

		if(swagShader != null)
		{
			if(FlxG.save.data.psychDevsEasterEgg == witherone) // ma mama
				swagShader.hue += elapsed;
			else {
				if(controls.UI_LEFT) swagShader.hue -= elapsed * 0.1;
				if(controls.UI_RIGHT) swagShader.hue += elapsed * 0.1;
			}
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>, offset:Float = 0)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true);
			money.screenCenter(X);
			money.y += (i * 60) + 200 + offset;
			if(credGroup != null && textGroup != null) {
				credGroup.add(money);
				textGroup.add(money);
			}
		}
	}

	function addMoreText(text:String, offset:Float = 0)
	{
		if(textGroup != null && credGroup != null) {
			var coolText:Alphabet = new Alphabet(0, 0, text, true);
			coolText.screenCenter(X);
			coolText.y += (textGroup.length * 60) + 200 + offset;
			credGroup.add(coolText);
			textGroup.add(coolText);
		}
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	private var sickBeats:Int = 0; //Basically curBeat but won't be skipped if you hold the tab or resize the screen
	public static var closedState:Bool = false;
	override function beatHit()
	{
		super.beatHit();

		if(FlxG.save.data.psychDevsEasterEgg == witherone && FlxG.sound.music != null)
		{
			if(FlxG.sound.music.pitch <= 5)
				FlxG.sound.music.pitch += 0.01;
			else
				FlxG.sound.music.pitch = 0.01;
		}


		if(logoBl != null)
			logoBl.animation.play('bump', true);

		if(gfDance != null) {
			danceLeft = !danceLeft;
			if (danceLeft)
				gfDance.animation.play('danceRight');
			else
				gfDance.animation.play('danceLeft');
		}

		if(!closedState) {
			sickBeats++;
			switch (sickBeats)
			{
				case 1:
				{
					FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
					FlxG.sound.music.fadeIn(4, 0, 1);
				}
				case 2:
				{
					createCoolText(['Theoyeah Engine by'], 15);
					// credTextShit.visible = true;
				}
				case 3:
				{
					addMoreText('Theoyeah', 15);
					tySpr.visible = true;
					// credTextShit.text += '\npresent...';
					// credTextShit.addText();
				}
				case 4:
				{
					deleteCoolText();
					tySpr.visible = false;
					// credTextShit.visible = false;
					// credTextShit.text = 'In association \nwith';
					// credTextShit.screenCenter();
				}
				case 5:
				{
					createCoolText(['With help of'], 15);
				}
				case 7:
				{
					addMoreText('Wither362');
					addMoreText('DEMOLITIONDON69');
					addMoreText('BeastlyGhost');
					coolguys.visible = true;
				}
				case 9:
				{
					deleteCoolText();
					coolguys.visible = false;
				}
				case 10:
				{
					createCoolText(['A Modified Version of'], -40);
				}
				case 11:
				{
					addMoreText('Psych Engine', -40);
					psychSpr.visible = true;
					// credTextShit.text += '\nNewgrounds';
				}
				case 12:
				{
					deleteCoolText();
					psychSpr.visible = false;
					// credTextShit.visible = false;

					// credTextShit.text = 'Shoutouts Tom Fulp';
					// credTextShit.screenCenter();
				}
				case 13:
				{
					createCoolText([curWacky[0]]);
					// credTextShit.visible = true;
				}
				case 14:
				{
					addMoreText(curWacky[1]);
					// credTextShit.text += '\nlmao';
				}
				case 15:
				{
					if (curWacky[2] != null) //im stupid bro, i wrote 3 instead of 2
						addMoreText(curWacky[2]);
					/*} else {
						sickBeats++;
					}*/
				}
				case 16:
				{
					deleteCoolText();
					// credTextShit.visible = false;
					// credTextShit.text = "Friday";
					// credTextShit.screenCenter();
				}
				case 17:
				{
					addMoreText("Friday Night Funkin'");
					// credTextShit.visible = true;
				}
				case 18:
				{
					addMoreText('Theoyeah');
					// credTextShit.text += '\nNight';
				}
				case 19:
				{
					addMoreText('Engine');
					// credTextShit.text += '\nFunkin';
				}
				case 20:
				{
					skipIntro();
				}
			}
		}
	}

	var skippedIntro:Bool = false;
	var increaseVolume:Bool = false;
	function removeThings():Void {
		remove(ngSpr);
		remove(psychSpr);
		remove(tySpr);
		remove(dnSpr);
		remove(credGroup);
		remove(coolguys);
	}
	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			if(!FlxG.save.data.firstInitied || FlxG.save.data.firstInitied == null)
				FlxG.save.data.firstInitied = true; // now you can skip the intro!

			//deleteCoolText();
			if (playJingle) //Ignore deez
			{
				var easteregg:String = FlxG.save.data.psychDevsEasterEgg;
				if (easteregg == null) easteregg = '';
				easteregg = easteregg.toUpperCase();

				var sound:FlxSound = null;
				switch(easteregg)
				{
					case 'RIVER':
						sound = FlxG.sound.play(Paths.sound('JingleRiver'));
					case 'SHUBS':
						sound = FlxG.sound.play(Paths.sound('JingleShubs'));
					case 'SHADOW':
						FlxG.sound.play(Paths.sound('JingleShadow'));
					case 'BBPANZU':
						sound = FlxG.sound.play(Paths.sound('JingleBB'));

					default: //Go back to normal ugly ass boring GF
						removeThings();
						if(ClientPrefs.flashing) {
							FlxG.camera.flash(titleTextColorEnter, 2);
						}
						skippedIntro = true;
						playJingle = false;

						FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
						FlxG.sound.music.fadeIn(4, 0, 0.7);
						return;
				}

				transitioning = true;
				if(easteregg == 'SHADOW')
				{
					new FlxTimer().start(3.2, function(tmr:FlxTimer)
					{
						removeThings();
						if(ClientPrefs.flashing) {
							FlxG.camera.flash(FlxColor.WHITE, 0.6);
						}
						transitioning = false;
					});
				}
				else if(easteregg == witherone) // im special!
				{
					var time = 0.3;
					if(ClientPrefs.flashing) { // a LOT OF FLASH
						FlxG.camera.flash(FlxColor.PINK, time, function() {
							trace('hehehe... if you didnt know it, wither its');
							trace('a FUCKING TROLLER/TROLL... and not an easy one...');
							if(FlxG.camera != null)
								FlxG.camera.angle = -4;
							new FlxTimer().start(4.3, function(tmr:FlxTimer)
							{
								if(FlxG.camera != null) {
									if (FlxG.camera.angle == -4) // just testing
										FlxTween.angle(FlxG.camera.angle, 4, -4, {ease: FlxEase.quartInOut});
									if (FlxG.camera.angle == 4)
										FlxTween.angle(FlxG.camera.angle, -4, 4, {ease: FlxEase.quartInOut});
								}

								removeThings();
								FlxG.camera.flash(FlxColor.RED, time, function() {
									FlxG.camera.flash(FlxColor.GRAY, time, function() {
										FlxG.camera.flash(FlxColor.WHITE, time, function() {
											FlxG.camera.flash(FlxColor.BLACK, time / 2);
											FlxG.camera.flash(FlxColor.BLUE, time / 2 + 0.1);
											FlxG.camera.flash(FlxColor.BROWN, time / 2 + 0.17);
											FlxG.camera.flash(FlxColor.YELLOW, time / 2 + 0.2);
											FlxG.camera.flash(FlxColor.ORANGE, time / 2 + 0.26, function() {
												new FlxTimer().start(2, function(tmr:FlxTimer) {
													if(FlxG.camera != null)
														FlxG.camera.angle = 0;
												});
											});
										});
									});
								});
								transitioning = false;
							});
						});
					} else {
						new FlxTimer().start(4.3 + time, function(tmr:FlxTimer)
						{
							removeThings();
							transitioning = false;
						});
					}
				}
				else if(easteregg == 'THEOYEAH') // customize it yourself theoyeah
				{
					new FlxTimer().start(3.2, function(tmr:FlxTimer)
					{
						removeThings();
						transitioning = false;
					});
				}
				else // other easter eggs
				{
					removeThings();
					if(ClientPrefs.flashing) {
						FlxG.camera.flash(FlxColor.WHITE, 3);
					}
					sound.onComplete = function() {
						FlxG.sound.playMusic(Paths.music(), 0);
						FlxG.sound.music.fadeIn(4, 0, 0.7);
						transitioning = false;
					};
				}
				playJingle = false;
			}
			else //Default! Edit this one!!
			{
				removeThings();
				if(ClientPrefs.flashing) {
					FlxG.camera.flash(titleTextColorEnter, 4);
				}

				var easteregg:String = FlxG.save.data.psychDevsEasterEgg;
				if (easteregg == null) easteregg = '';
				easteregg = easteregg.toUpperCase();
				#if TITLE_SCREEN_EASTER_EGG
				if(easteregg == 'SHADOW')
				{
					FlxG.sound.music.fadeOut();
					if(FreeplayState.vocals != null)
					{
						FreeplayState.vocals.fadeOut();
					}
				}
				#end
			}
			var easteregg:String = FlxG.save.data.psychDevsEasterEgg;
			if (easteregg == null) easteregg = '';
			easteregg = easteregg.toUpperCase();

			var lol = FlxG.random.int(4, 100);
			if(easteregg != witherone) {
				logoBl.angle = -4;
			} else {
				logoBl.angle = -lol;
			}

			new FlxTimer().start(0.01, function(tmr:FlxTimer)
			{
				if(easteregg == witherone) {
					if (logoBl.angle == -lol)
						FlxTween.angle(logoBl, logoBl.angle, lol, 4, {ease: FlxEase.quartInOut});
					if (logoBl.angle == lol)
						FlxTween.angle(logoBl, logoBl.angle, lol, 4, {ease: FlxEase.quartInOut});
				} else {
					if (logoBl.angle == -4)
						FlxTween.angle(logoBl, logoBl.angle, 4, 4, {ease: FlxEase.quartInOut});
					if (logoBl.angle == 4)
						FlxTween.angle(logoBl, logoBl.angle, -4, 4, {ease: FlxEase.quartInOut});
				}
			}, 0);

			skippedIntro = true;
		}
	}
}
