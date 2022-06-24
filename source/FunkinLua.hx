#if LUA_ALLOWED
import llua.Lua;
import llua.LuaL;
import llua.State;
import llua.Convert;
#end

import animateatlas.AtlasFrameMaker;
import flixel.FlxG;
import flixel.addons.effects.FlxTrail;
import flixel.input.keyboard.FlxKey;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.util.FlxTimer;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.util.FlxColor;
import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxSprite;
import openfl.Lib;
import openfl.display.BlendMode;
import openfl.filters.BitmapFilter;
import Shaders;
import openfl.utils.Assets;
import flixel.math.FlxMath;
import flixel.util.FlxSave;
import flixel.addons.transition.FlxTransitionableState;
#if sys
import sys.FileSystem;
import sys.io.File;
#end
import Type.ValueType;
import Controls;
import DialogueBoxPsych;

#if desktop
import Discord;
#end

using StringTools;

class FunkinLua {
	public static var Function_Stop:Dynamic = 1;
	public static var Function_Continue:Dynamic = 0;
	public static var Function_StopLua:Dynamic = 2;

	public var errorHandler:String->Void;
	#if LUA_ALLOWED
	public var lua:State = null;
	#end
	public var camTarget:FlxCamera;
	public var scriptName:String = '';
	public var close:Bool = false;

	var gonnaClose:Bool = false;

	public var accessedProps:Map<String, Dynamic> = null;

	public function lol() {
		#if !LUA_ALLOWED
		trace("You have LUA disabled, so you can't access to LUA functions, sorry ;)");
		#end
	}

	public function deprecated(first:String, second:String) {
		#if LUA_ALLOWED
		luaTrace('$first is deprecated! We highly recommend using $second instead because it have better things!', false, true, FlxColor.YELLOW);
		#else
		lol();
		#end
	}
	public function couldntFindObject(vars:Dynamic) {
		#if LUA_ALLOWED
		var varr:String = vars.toString;
		traceLuaError('Couldnt find object: $varr');
		#else
		lol();
		#end
	}
	public function getLuaObjectPlay(obj:String) {
		var object:Null<String> = if(PlayState.instance.getLuaObject(obj, false) != null) obj else if(PlayState.instance.getLuaObject(obj.toLowerCase(), false) != null) obj.toLowerCase() else null;
		return object;
	}
	public function getPropertyReflect(obj:String) {
		var pussy:FlxSprite = if(Reflect.getProperty(getInstance(), obj) != null) Reflect.getProperty(getInstance(), obj) else Reflect.getProperty(getInstance(), obj.toLowerCase());
		return pussy;
	}
	public function getModchartSpriteExists(tag) {
		var tagger:Null<String> = if(PlayState.instance.modchartSprites.exists(tag)) tag else if(PlayState.instance.modchartSprites.exists(tag.toLowerCase())) tag.toLowerCase() else null;
		return tagger;
	}
	/**
	 * Returns the clicked thing, it depends in what the param name is
	 * @param name 
	 * @param type 
	 * @param other 
	 */
	public function controlsStuff(name:String, ?type:String) {
		if(type == null) type = '';
		var key:Bool = false;
		var as:String = name.toLowerCase().replace('-', '').replace('_', '').replace('"', '').replace("'", '');
		switch(as) {
			case 'left' | 'l': key = PlayState.instance.getControl('NOTE_LEFT' + type);
			case 'down' | 'd': key = PlayState.instance.getControl('NOTE_DOWN' + type);
			case 'up' | 'u': key = PlayState.instance.getControl('NOTE_UP' + type);
			case 'right' | 'r': key = PlayState.instance.getControl('NOTE_RIGHT' + type);
			case 'uileft': key = PlayState.instance.getControl('UI_LEFT' + type);
			case 'uiright': key = PlayState.instance.getControl('UI_RIGHT' + type);
			case 'uiup': key = PlayState.instance.getControl('UI_UP' + type);
			case 'uidown': key = PlayState.instance.getControl('UI_DOWN' + type);
			case 'accept': key = PlayState.instance.getControl('ACCEPT');
			case 'back': key = PlayState.instance.getControl('BACK');
			case 'pause': key = PlayState.instance.getControl('PAUSE');
			case 'reset': key = PlayState.instance.getControl('RESET');
			case 'space':
				switch(type) {
					case '_R': key = FlxG.keys.justReleased.SPACE;//an extra key for convinience
					case '': key = FlxG.keys.pressed.SPACE;
					case '_P': key = FlxG.keys.justPressed.SPACE;
				}
		}
		return key;
	}
	/**
	 * returns what character is the entrance
	 * @param name 
	 * @return String, it returns `gf`, `dad`, or `bf`
	 */
	public function charactersStuff(name:String):String {
		var aLot:String = name.toLowerCase().replace(' ', '').replace('-', '').replace(',', '').replace('.', '').replace("'", '').replace('"', '');
		var thing:String = 'bf';
		switch(aLot) {
			case 'gf' | 'girlfriend' | 'girl' | 'gfversion' | 'middle': thing = 'gf';
			case 'dad' | 'opponent' | 'player2' | 'dadname' | 'left': thing = 'dad';
		}
		return thing;
	}
	public function notExists(obj:Dynamic) {
		#if LUA_ALLOWED
		var object:String = obj.toString();
		traceLuaError('Object $object doesnt exist!');
		#else
		lol();
		#end
	}

	public function new(script:String) {
		#if LUA_ALLOWED
		lua = LuaL.newstate();
		LuaL.openlibs(lua);
		Lua.init_callbacks(lua);

		//trace('Lua version: ' + Lua.version());
		//trace("LuaJIT version: " + Lua.versionJIT());

		LuaL.dostring(lua, CLENSE);
		try {
			var result:Dynamic = LuaL.dofile(lua, script);
			var resultStr:String = Lua.tostring(lua, result);
			if(resultStr != null && result != 0) {
				trace('Error on lua script! ' + resultStr);
				#if windows
				lime.app.Application.current.window.alert(resultStr, 'Error on lua script!');
				#else
				luaTrace('Error loading lua script: "$script"\n' + resultStr, true, false, FlxColor.RED);
				#end
				lua = null;
				return;
			}
		} catch(e:Dynamic) {
			trace(e);
			return;
		}

		scriptName = script;
		trace('Lua file loaded succesfully: $script');

		#if (haxe >= "4.0.0")
		accessedProps = new Map();
		#else
		accessedProps = new Map<String, Dynamic>();
		#end

		// Lua shit
		set('Function_StopLua', Function_StopLua);
		set('Function_Stop', Function_Stop);
		set('Function_Continue', Function_Continue);
		set('luaDebugMode', false);
		set('luaDeprecatedWarnings', true);
		set('inChartEditor', false);

		// Song/Week shit
		set('curBpm', Conductor.bpm);
		set('bpm', PlayState.SONG.bpm);
		set('scrollSpeed', PlayState.SONG.speed);
		set('crochet', Conductor.crochet);
		set('stepCrochet', Conductor.stepCrochet);
		set('songLength', FlxG.sound.music.length);
		set('songName', PlayState.SONG.song);
		set('startedCountdown', false);

		set('isStoryMode', PlayState.isStoryMode);
		set('difficulty', PlayState.storyDifficulty);
		set('difficultyName', CoolUtil.difficulties[PlayState.storyDifficulty]);
		set('weekRaw', PlayState.storyWeek);
		set('week', WeekData.weeksList[PlayState.storyWeek]);
		set('seenCutscene', PlayState.seenCutscene);
		set('deaths', PlayState.deathCounter);
		set('blueBalled', PlayState.deathCounter);

		set('require', false);

		// Camera poo
		set('cameraX', 0);
		set('cameraY', 0);
		
		// Screen stuff
		set('screenWidth', FlxG.width);
		set('screenHeight', FlxG.height);

		// PlayState cringe ass nae nae bullcrap
		set('curBeat', 0);
		set('curbeat', 0);
		set('curStep', 0);
		set('curstep', 0);
		set('curDecBeat', 0);
 		set('curDecStep', 0);
		set('curdecbeat', 0);
 		set('curdecstep', 0);

		set('score', 0);
		set('misses', 0);
		set('hits', 0);

		set('rating', 0);
		set('ratingName', '');
		set('ratingFC', '');
		set('maxHealth', 2);
		set('version', MainMenuState.theoyeahEngineVersion.trim());
		
		set('inGameOver', false);
		set('mustHitSection', false);
		set('altAnim', false);
		set('gfSection', false);

		// Gameplay settings
		set('healthGainMult', PlayState.instance.healthGain);
		set('healthLossMult', PlayState.instance.healthLoss);
		set('instakillOnMiss', PlayState.instance.instakillOnMiss);
		set('botPlay', PlayState.instance.cpuControlled);
		set('practice', PlayState.instance.practiceMode);

		for (i in 0...4) {
			set('defaultPlayerStrumX' + i, 0);
			set('defaultPlayerStrumY' + i, 0);
			set('defaultOpponentStrumX' + i, 0);
			set('defaultOpponentStrumY' + i, 0);
		}

		// Default character positions woooo
		set('defaultBoyfriendX', PlayState.instance.BF_X);
		set('defaultBoyfriendY', PlayState.instance.BF_Y);
		set('defaultOpponentX', PlayState.instance.DAD_X);
		set('defaultOpponentY', PlayState.instance.DAD_Y);
		set('defaultGirlfriendX', PlayState.instance.GF_X);
		set('defaultGirlfriendY', PlayState.instance.GF_Y);

		// Character shit
		set('boyfriendName', PlayState.SONG.player1);
		set('bfName', PlayState.SONG.player1);
		set('player1', PlayState.SONG.player1);
		set('dadName', PlayState.SONG.player2);
		set('player2', PlayState.SONG.player2);
		set('gfName', PlayState.SONG.gfVersion);
		set('gfVersion', PlayState.SONG.gfVersion);
		set('girlfriendName', PlayState.SONG.gfVersion);

//______________ Some settings, no jokes _______________\\
//______________ Scroll things _________________________\\
		set('downscroll', ClientPrefs.downScroll);
		set('downScroll', ClientPrefs.downScroll); //i dont like it without capital letters
		set('middlescroll', ClientPrefs.middleScroll);
		set('middleScroll', ClientPrefs.middleScroll);

//_____________ more options things ____________________\\
		set('framerate', ClientPrefs.framerate);
		set('fps', ClientPrefs.framerate);
		set('anti-Aliasing', ClientPrefs.globalAntialiasing);
		set('antiAliasing', ClientPrefs.globalAntialiasing);
		set('antialiasing', ClientPrefs.globalAntialiasing);
		set('ghostTapping', ClientPrefs.ghostTapping);
		set('hideHud', ClientPrefs.hideHud);
		set('timeBarType', ClientPrefs.timeBarType);
		set('scoreZoom', ClientPrefs.scoreZoom);
		set('cameraZoomOnBeat', ClientPrefs.camZooms);
		set('flashingLights', ClientPrefs.flashing);
		set('flashing', ClientPrefs.flashing);
		set('noteOffset', ClientPrefs.noteOffset);
		set('healthBarAlpha', ClientPrefs.healthBarAlpha);
		set('noResetButton', ClientPrefs.noReset);
		set('lowQuality', ClientPrefs.lowQuality);
		set('winningIcons', ClientPrefs.winningIcon); //unused
		set('crazyCounter', ClientPrefs.crazycounter);
		set('judgementCounter', ClientPrefs.crazycounter);
		set('camFollow', ClientPrefs.camfollow);
		set('introBg', ClientPrefs.introbg);
		set('longHealthBar', ClientPrefs.longhealthbar);
		set('noScore', ClientPrefs.noscore);
		set('kadeTxt', ClientPrefs.kadetxt);
		set('iconBounce', ClientPrefs.iconBounce);
		set('noteSplashes', ClientPrefs.noteSplashes);
		
		// other things
		set('mouseVisible', FlxG.mouse.visible);
		set("scriptName", scriptName);


		#if windows
		set('buildTarget', 'windows');
		#elseif linux
		set('buildTarget', 'linux');
		#elseif mac
		set('buildTarget', 'mac');
		#elseif html5
		set('buildTarget', 'browser');
		#elseif android
		set('buildTarget', 'android');
		#else
		set('buildTarget', 'unknown');
		#end

		Lua_helper.add_callback(lua, "getRunningScripts", function(){
			var runningScripts:Array<String> = [];
			for (idx in 0...PlayState.instance.luaArray.length)
				runningScripts.push(PlayState.instance.luaArray[idx].scriptName);


			return runningScripts;
		});

		Lua_helper.add_callback(lua, "callOnLuas", function(?funcName:String, ?args:Array<Dynamic>, ignoreStops=false, ignoreSelf=true, ?exclusions:Array<String>){
			if(funcName == null) {
				#if (linc_luajit >= "0.0.6")
				LuaL.error(lua, "bad argument #1 to 'callOnLuas' (string expected, got nil)");
				#end
				return;
			}
			if(args == null)args = [];

			if(exclusions == null) exclusions = [];

			Lua.getglobal(lua, 'scriptName');
			var daScriptName = Lua.tostring(lua, -1);
			Lua.pop(lua, 1);
			if(ignoreSelf && !exclusions.contains(daScriptName)) exclusions.push(daScriptName);
			PlayState.instance.callOnLuas(funcName, args, ignoreStops, exclusions);
		});

		Lua_helper.add_callback(lua, "callScript", function(?luaFile:String, ?funcName:String, ?args:Array<Dynamic>){
			if(luaFile == null) {
				#if (linc_luajit >= "0.0.6")
				LuaL.error(lua, "bad argument #1 to 'callScript' (string expected, got nil)");
				#end
				return;
			}
			if(funcName == null) {
				#if (linc_luajit >= "0.0.6")
				LuaL.error(lua, "bad argument #2 to 'callScript' (string expected, got nil)");
				#end
				return;
			}
			if(args == null)
				args = [];

			var cervix = luaFile + ".lua";
			if(luaFile.endsWith(".lua"))cervix=luaFile;
			var doPush = false;
			#if MODS_ALLOWED
			if(FileSystem.exists(Paths.modFolders(cervix)))
			{
				cervix = Paths.modFolders(cervix);
				doPush = true;
			}
			else if(FileSystem.exists(cervix))
				doPush = true;
			else {
				cervix = Paths.getPreloadPath(cervix);
				if(FileSystem.exists(cervix))
					doPush = true;
			}
			#else
			cervix = Paths.getPreloadPath(cervix);
			if(Assets.exists(cervix))
				doPush = true;
			#end
			if(doPush)
			{
				for (luaInstance in PlayState.instance.luaArray)
				{
					if(luaInstance.scriptName == cervix)
					{
						luaInstance.call(funcName, args);

						return;
					}

				}
			}
			Lua.pushnil(lua);

		});

		Lua_helper.add_callback(lua, "getGlobalFromScript", function(?luaFile:String, ?global:String){ // returns the global from a script
			if(luaFile == null) {
				#if (linc_luajit >= "0.0.6")
				LuaL.error(lua, "bad argument #1 to 'getGlobalFromScript' (string expected, got nil)");
				#end
				return;
			}
			if(global == null) {
				#if (linc_luajit >= "0.0.6")
				LuaL.error(lua, "bad argument #2 to 'getGlobalFromScript' (string expected, got nil)");
				#end
				return;
			}
			var cervix = luaFile + ".lua";
			if(luaFile.endsWith(".lua")) cervix = luaFile;
			var doPush = false;
			#if MODS_ALLOWED
			if(FileSystem.exists(Paths.modFolders(cervix)))
			{
				cervix = Paths.modFolders(cervix);
				doPush = true;
			}
			else if(FileSystem.exists(cervix))
				doPush = true;
			else {
				cervix = Paths.getPreloadPath(cervix);
				if(FileSystem.exists(cervix))
					doPush = true;
			}
			#else
			cervix = Paths.getPreloadPath(cervix);
			if(Assets.exists(cervix))
				doPush = true;
			#end
			if(doPush)
			{
				for (luaInstance in PlayState.instance.luaArray)
				{
					if(luaInstance.scriptName == cervix)
					{
						Lua.getglobal(luaInstance.lua, global);
						if(Lua.isnumber(luaInstance.lua, -1))
							Lua.pushnumber(lua, Lua.tonumber(luaInstance.lua, -1));
						else if(Lua.isstring(luaInstance.lua, -1))
							Lua.pushstring(lua, Lua.tostring(luaInstance.lua, -1));
						else if(Lua.isboolean(luaInstance.lua, -1))
							Lua.pushboolean(lua, Lua.toboolean(luaInstance.lua, -1));
						else
							Lua.pushnil(lua);
						// TODO: table

						Lua.pop(luaInstance.lua, 1); // remove the global

						return;
					}

				}
			}
			Lua.pushnil(lua);
		});
		Lua_helper.add_callback(lua, "setGlobalFromScript", function(luaFile:String, global:String, val:Dynamic){ // returns the global from a script
			var cervix = luaFile + ".lua";
			if(luaFile.endsWith(".lua")) cervix = luaFile;
			var doPush = false;
			#if MODS_ALLOWED
			if(FileSystem.exists(Paths.modFolders(cervix)))
			{
				cervix = Paths.modFolders(cervix);
				doPush = true;
			}
			else if(FileSystem.exists(cervix))
				doPush = true;
			else {
				cervix = Paths.getPreloadPath(cervix);
				if(FileSystem.exists(cervix))
					doPush = true;
			}
			#else
			cervix = Paths.getPreloadPath(cervix);
			if(Assets.exists(cervix))
				doPush = true;
			#end
			if(doPush)
			{
				for (luaInstance in PlayState.instance.luaArray)
				{
					if(luaInstance.scriptName == cervix)
						luaInstance.set(global, val);

				}
			}
			Lua.pushnil(lua);
		});
		Lua_helper.add_callback(lua, "getGlobals", function(luaFile:String){ // returns a copy of the specified file's globals
			var cervix = luaFile + ".lua";
			if(luaFile.endsWith(".lua")) cervix = luaFile;
			var doPush = false;
			#if MODS_ALLOWED
			if(FileSystem.exists(Paths.modFolders(cervix)))
			{
				cervix = Paths.modFolders(cervix);
				doPush = true;
			}
			else if(FileSystem.exists(cervix))
				doPush = true;
			else {
				cervix = Paths.getPreloadPath(cervix);
				if(FileSystem.exists(cervix)) {
					doPush = true;
				}
			}
			#else
			cervix = Paths.getPreloadPath(cervix);
			if(Assets.exists(cervix)) {
				doPush = true;
			}
			#end
			if(doPush)
			{
				for (luaInstance in PlayState.instance.luaArray)
				{
					if(luaInstance.scriptName == cervix)
					{
						Lua.newtable(lua);
						var tableIdx = Lua.gettop(lua);

						Lua.pushvalue(luaInstance.lua, Lua.LUA_GLOBALSINDEX);
						Lua.pushnil(luaInstance.lua);
						while(Lua.next(luaInstance.lua, -2) != 0) {
							// key = -2
							// value = -1

							var pop:Int = 0;

							// Manual conversion
							// first we convert the key
							if(Lua.isnumber(luaInstance.lua,-2)) {
								Lua.pushnumber(lua, Lua.tonumber(luaInstance.lua, -2));
								pop++;
							} else if(Lua.isstring(luaInstance.lua,-2)) {
								Lua.pushstring(lua, Lua.tostring(luaInstance.lua, -2));
								pop++;
							} else if(Lua.isboolean(luaInstance.lua,-2)) {
								Lua.pushboolean(lua, Lua.toboolean(luaInstance.lua, -2));
								pop++;
							}
							// TODO: table


							// then the value
							if(Lua.isnumber(luaInstance.lua,-1)) {
								Lua.pushnumber(lua, Lua.tonumber(luaInstance.lua, -1));
								pop++;
							} else if(Lua.isstring(luaInstance.lua,-1)) {
								Lua.pushstring(lua, Lua.tostring(luaInstance.lua, -1));
								pop++;
							} else if(Lua.isboolean(luaInstance.lua,-1)) {
								Lua.pushboolean(lua, Lua.toboolean(luaInstance.lua, -1));
								pop++;
							}
							// TODO: table

							if(pop == 2) Lua.rawset(lua, tableIdx); // then set it
							Lua.pop(luaInstance.lua, 1); // for the loop
						}
						Lua.pop(luaInstance.lua, 1); // end the loop entirely
						Lua.pushvalue(lua, tableIdx); // push the table onto the stack so it gets returned

						return;
					}

				}
			}
			Lua.pushnil(lua);
		});
		Lua_helper.add_callback(lua, "isRunning", function(luaFile:String){
			var cervix = luaFile + ".lua";
			if(luaFile.endsWith(".lua")) cervix = luaFile;
			var doPush = false;
			#if MODS_ALLOWED
			if(FileSystem.exists(Paths.modFolders(cervix)))
			{
				cervix = Paths.modFolders(cervix);
				doPush = true;
			}
			else if(FileSystem.exists(cervix))
				doPush = true;
			else {
				cervix = Paths.getPreloadPath(cervix);
				if(FileSystem.exists(cervix))
					doPush = true;
			}
			#else
			cervix = Paths.getPreloadPath(cervix);
			if(Assets.exists(cervix))
				doPush = true;
			#end

			if(doPush)
			{
				for (luaInstance in PlayState.instance.luaArray)
				{
					if(luaInstance.scriptName == cervix)
						return true;

				}
			}
			return false;
		});

		Lua_helper.add_callback(lua, "addLuaScript", function(luaFile:String, ?ignoreAlreadyRunning:Bool = false) { //would be dope asf. 
			var cervix = luaFile + ".lua";
			if(luaFile.endsWith('.lua')) cervix = luaFile;
			var doPush = false;
			#if MODS_ALLOWED
			if(FileSystem.exists(Paths.modFolders(cervix)))
			{
				cervix = Paths.modFolders(cervix);
				doPush = true;
			} else if(FileSystem.exists(cervix))
 				doPush = true;
			else {
				cervix = Paths.getPreloadPath(cervix);
				if(FileSystem.exists(cervix))
					doPush = true;
			}
			#else
			cervix = Paths.getPreloadPath(cervix);
			if(Assets.exists(cervix))
				doPush = true;
			#end

			if(doPush)
			{
				if(!ignoreAlreadyRunning)
				{
					for (luaInstance in PlayState.instance.luaArray)
					{
						if(luaInstance.scriptName == cervix)
						{
							luaTrace('The script "$cervix" is already running!');
							return;
						}
					}
				}
				PlayState.instance.luaArray.push(new FunkinLua(cervix)); 
				return;
			}
			traceLuaError('Script "$luaFile" ' + "doesn't exist!");
		});

		Lua_helper.add_callback(lua, "removeLuaScript", function(luaFile:String, ?ignoreAlreadyRunning:Bool = false) { //would be dope asf. 
			var cervix = luaFile + ".lua";
			if(luaFile.endsWith('.lua')) cervix = luaFile;
			var doPush = false;
			#if MODS_ALLOWED
			if(FileSystem.exists(Paths.modFolders(cervix))) {
				cervix = Paths.modFolders(cervix);
				doPush = true;
			} else if(FileSystem.exists(cervix))
 			{
 				doPush = true;
 			} else {
				cervix = Paths.getPreloadPath(cervix);
				if(FileSystem.exists(cervix))
					doPush = true;
			}
			#else
			cervix = Paths.getPreloadPath(cervix);
			if(Assets.exists(cervix))
				doPush = true;
			#end

			if(doPush)
			{
				if(!ignoreAlreadyRunning)
				{
					for (luaInstance in PlayState.instance.luaArray)
					{
						if(luaInstance.scriptName == cervix)
						{
							//luaTrace('The script "' + cervix + '" is already running!');
							PlayState.instance.luaArray.remove(luaInstance); 
							return;
						}
					}
				}
				return;
			}
			luaTrace('Script "$luaFile" doesn' + "'t exist!", false, false, FlxColor.RED);
		});

		Lua_helper.add_callback(lua, "luaSpriteExists", function(tag:String) {
 			return (PlayState.instance.modchartSprites.exists(tag) || PlayState.instance.modchartSprites.exists(tag.toLowerCase()) || PlayState.instance.modchartSprites.exists(tag.toUpperCase()));
 		});
 		Lua_helper.add_callback(lua, "luaTextExists", function(tag:String) {
 			return PlayState.instance.modchartTexts.exists(tag);
 		});
 		Lua_helper.add_callback(lua, "luaSoundExists", function(tag:String) {
 			return PlayState.instance.modchartSounds.exists(tag);
 		});
		Lua_helper.add_callback(lua, "checkFileExists", function(filename:String, ?absolute:Bool = false) {
			#if MODS_ALLOWED
			if(absolute)
			{
				return FileSystem.exists(filename);
			}

			var path:String = Paths.modFolders(filename);
			if(FileSystem.exists(path))
			{
				return true;
			}
			return FileSystem.exists('assets/$filename');
			#else
			luaTrace('Platform not suppoted for checkFileExists!\nNeed mods activated for this!', true, false, FlxColor.RED);
			return false;
			#end
		});

		Lua_helper.add_callback(lua, "setHealthBarColors", function(leftHex:String, rightHex:String) {
			var left:FlxColor = Std.parseInt(leftHex);
			if(!leftHex.startsWith('0x')) left = Std.parseInt('0xff' + leftHex);
			var right:FlxColor = Std.parseInt(rightHex);
			if(!rightHex.startsWith('0x')) right = Std.parseInt('0xff' + rightHex);

			PlayState.instance.healthBar.createFilledBar(left, right);
			PlayState.instance.healthBar.updateBar();
		});
		Lua_helper.add_callback(lua, "setTimeBarColors", function(leftHex:String, rightHex:String) {
			var left:FlxColor = Std.parseInt(leftHex);
			if(!leftHex.startsWith('0x')) left = Std.parseInt('0xff' + leftHex);
			var right:FlxColor = Std.parseInt(rightHex);
			if(!rightHex.startsWith('0x')) right = Std.parseInt('0xff' + rightHex);

			PlayState.instance.timeBar.createFilledBar(right, left);
			PlayState.instance.timeBar.updateBar();
		});

		Lua_helper.add_callback(lua, "loadSong", function(?name:String = null, ?difficultyNum:Int = -1) {
			if(name == null || name.length < 1)
				name = PlayState.SONG.song;
			if (difficultyNum == -1)
				difficultyNum = PlayState.storyDifficulty;

			var poop = Highscore.formatSong(name, difficultyNum);
			PlayState.SONG = Song.loadFromJson(poop, name);
			PlayState.storyDifficulty = difficultyNum;
			PlayState.instance.persistentUpdate = false;
			LoadingState.loadAndSwitchState(new PlayState());

			FlxG.sound.music.pause();
			FlxG.sound.music.volume = 0;
			if(PlayState.instance.vocals != null)
			{
				PlayState.instance.vocals.pause();
				PlayState.instance.vocals.volume = 0;
			}
		});

		Lua_helper.add_callback(lua, "clearUnusedMemory", function() {
			Paths.clearUnusedMemory();
			return true;
		});

		Lua_helper.add_callback(lua, "loadGraphic", function(variable:String, image:String, ?gridX:Int, ?gridY:Int) {
 			var killMe:Array<String> = variable.split('.');
 			var spr:FlxSprite = getObjectDirectly(killMe[0]);
 			var gX = gridX == null ? 0 : gridX;
 			var gY = gridY == null ? 0 : gridY;
 			var animated = gX != 0 || gY != 0;

 			if(killMe.length > 1) {
 				spr = getVarInArray(getPropertyLoopThingWhatever(killMe), killMe[killMe.length-1]);
 			}

 			if(spr != null && image != null && image.length > 0)
 			{
 				spr.loadGraphic(Paths.image(image));
 				spr.loadGraphic(Paths.image(image), animated, gX, gY);
 			}
 		});
		Lua_helper.add_callback(lua, "loadFrames", function(variable:String, image:String, spriteType:String = "sparrow") {
			var killMe:Array<String> = variable.split('.');
			var spr:FlxSprite = getObjectDirectly(killMe[0]);
			if(killMe.length > 1) {
				spr = getVarInArray(getPropertyLoopThingWhatever(killMe), killMe[killMe.length-1]);
			}

			if(spr != null && image != null && image.length > 0)
			{
				loadFrames(spr, image, spriteType);
			}
		});
		
		Lua_helper.add_callback(lua, "getProperty", function(variable:String) {
			var killMe:Array<String> = variable.split('.');
			if(killMe.length > 1) {
				return Reflect.getProperty(getPropertyLoopThingWhatever(killMe), killMe[killMe.length-1]);
			}
			return Reflect.getProperty(getInstance(), variable);
		});
		Lua_helper.add_callback(lua, "setProperty", function(variable:String, value:Dynamic) {
			var killMe:Array<String> = variable.split('.');
			trace(getPropertyLoopThingWhatever(killMe));
			if(killMe.length > 1) {
				return Reflect.setProperty(getPropertyLoopThingWhatever(killMe), killMe[killMe.length-1], value);
			}
			return Reflect.setProperty(getInstance(), variable, value);
		});
		Lua_helper.add_callback(lua, "getPropertyFromGroup", function(obj:String, index:Int, variable:Dynamic) {
			var shitMyPants:Array<String> = obj.split('.');
			var realObject:Dynamic = Reflect.getProperty(getInstance(), obj);
			if(shitMyPants.length>1)
				realObject = getPropertyLoopThingWhatever(shitMyPants, true, false);


			if(Std.isOfType(realObject, FlxTypedGroup))
				return getGroupStuff(realObject.members[index], variable);


			var leArray:Dynamic = realObject[index];
			if(leArray != null) {
				if(Type.typeof(variable) == ValueType.TInt) {
					return leArray[variable];
				}
				return getGroupStuff(leArray, variable);
			}
			luaTrace("Object #" + index + " from group: " + obj + " doesn't exist!", false, false, FlxColor.RED);
			return null;
		});
		Lua_helper.add_callback(lua, "setPropertyFromGroup", function(obj:String, index:Int, variable:Dynamic, value:Dynamic) {
			var shitMyPants:Array<String> = obj.split('.');
			var realObject:Dynamic = Reflect.getProperty(getInstance(), obj);
			if(shitMyPants.length>1)
				realObject = getPropertyLoopThingWhatever(shitMyPants, true, false);

			if(Std.isOfType(realObject, FlxTypedGroup)) {
				setGroupStuff(realObject.members[index], variable, value);
				return;
			}

			var leArray:Dynamic = realObject[index];
			if(leArray != null) {
				if(Type.typeof(variable) == ValueType.TInt) {
					leArray[variable] = value;
					return;
				}
				setGroupStuff(leArray, variable, value);
			}
		});
		Lua_helper.add_callback(lua, "removeFromGroup", function(obj:String, index:Int, dontDestroy:Bool = false) {
			if(Std.isOfType(Reflect.getProperty(getInstance(), obj), FlxTypedGroup)) {
				var sex = Reflect.getProperty(getInstance(), obj).members[index];
				if(!dontDestroy)
					sex.kill();
				Reflect.getProperty(getInstance(), obj).remove(sex, true);
				if(!dontDestroy)
					sex.destroy();
				return;
			}
			Reflect.getProperty(getInstance(), obj).remove(Reflect.getProperty(getInstance(), obj)[index]);
		});

		Lua_helper.add_callback(lua, "getPropertyFromClass", function(classVar:String, variable:String) {
			var killMe:Array<String> = variable.split('.');
			if(killMe.length > 1) {
				var coverMeInPiss:Dynamic = Reflect.getProperty(Type.resolveClass(classVar), killMe[0]);
				for (i in 1...killMe.length-1) {
					coverMeInPiss = Reflect.getProperty(coverMeInPiss, killMe[i]);
				}
				return Reflect.getProperty(coverMeInPiss, killMe[killMe.length-1]);
			}
			return Reflect.getProperty(Type.resolveClass(classVar), variable);
		});
		Lua_helper.add_callback(lua, "setPropertyFromClass", function(classVar:String, variable:String, value:Dynamic) {
			var killMe:Array<String> = variable.split('.');
			if(killMe.length > 1) {
				var coverMeInPiss:Dynamic = Reflect.getProperty(Type.resolveClass(classVar), killMe[0]);
				for (i in 1...killMe.length-1) {
					coverMeInPiss = Reflect.getProperty(coverMeInPiss, killMe[i]);
				}
				return Reflect.setProperty(coverMeInPiss, killMe[killMe.length-1], value);
			}
			return Reflect.setProperty(Type.resolveClass(classVar), variable, value);
		});

		//shitass stuff for epic coders like me B)  *image of obama giving himself a medal*
		Lua_helper.add_callback(lua, "getObjectOrder", function(obj:String) {
			var killMe:Array<String> = obj.split('.');
			var leObj:FlxBasic = getObjectDirectly(killMe[0]);
			if(killMe.length > 1) {
				leObj = getVarInArray(getPropertyLoopThingWhatever(killMe), killMe[killMe.length-1]);
			}

			if(leObj != null)
				return getInstance().members.indexOf(leObj);

			traceLuaError('Object $obj doesnt exist!');
			return -1;
		});
		Lua_helper.add_callback(lua, "setObjectOrder", function(obj:String, position:Int) {
			var killMe:Array<String> = obj.split('.');
			var leObj:FlxBasic = getObjectDirectly(killMe[0]);
			if(killMe.length > 1) {
				leObj = getVarInArray(getPropertyLoopThingWhatever(killMe), killMe[killMe.length-1]);
			}

			if(leObj != null) {
				getInstance().remove(leObj, true);
				getInstance().insert(position, leObj);
				return;
			}
			luaTrace('Object $obj doesnt exist!', false, false, FlxColor.RED);
		});

		// gay ass tweens
		Lua_helper.add_callback(lua, "doTweenX", function(tag:String, vars:String, value:Dynamic, duration:Float, ease:String) {
			var penisExam:Dynamic = tweenShit(tag, vars);
			if(penisExam != null) {
				PlayState.instance.modchartTweens.set(tag, FlxTween.tween(penisExam, {x: value}, duration, {ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
						PlayState.instance.modchartTweens.remove(tag);
					}
				}));
			} else
				couldntFindObject(vars);
		});
		Lua_helper.add_callback(lua, "doTweenY", function(tag:String, vars:String, value:Dynamic, duration:Float, ease:String) {
			var penisExam:Dynamic = tweenShit(tag, vars);
			if(penisExam != null) {
				PlayState.instance.modchartTweens.set(tag, FlxTween.tween(penisExam, {y: value}, duration, {ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
						PlayState.instance.modchartTweens.remove(tag);
					}
				}));
			} else
				couldntFindObject(vars);
		});
		Lua_helper.add_callback(lua, "doTweenAngle", function(tag:String, vars:String, value:Dynamic, duration:Float, ease:String) {
			var penisExam:Dynamic = tweenShit(tag, vars);
			if(penisExam != null) {
				PlayState.instance.modchartTweens.set(tag, FlxTween.tween(penisExam, {angle: value}, duration, {ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
						PlayState.instance.modchartTweens.remove(tag);
					}
				}));
			} else
				couldntFindObject(vars);
		});
		Lua_helper.add_callback(lua, "doTweenAlpha", function(tag:String, vars:String, value:Dynamic, duration:Float, ease:String) {
			var penisExam:Dynamic = tweenShit(tag, vars);
			if(penisExam != null) {
				PlayState.instance.modchartTweens.set(tag, FlxTween.tween(penisExam, {alpha: value}, duration, {ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
						PlayState.instance.modchartTweens.remove(tag);
					}
				}));
			} else
				couldntFindObject(vars);
		});
		Lua_helper.add_callback(lua, "doTweenZoom", function(tag:String, vars:String, value:Dynamic, duration:Float, ease:String) {
			var penisExam:Dynamic = tweenShit(tag, vars);
			if(penisExam != null) {
				PlayState.instance.modchartTweens.set(tag, FlxTween.tween(penisExam, {zoom: value}, duration, {ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
						PlayState.instance.modchartTweens.remove(tag);
					}
				}));
			} else
				couldntFindObject(vars);
		});
		Lua_helper.add_callback(lua, "doTweenColor", function(tag:String, vars:String, targetColor:String, duration:Float, ease:String) {
			var penisExam:Dynamic = tweenShit(tag, vars);
			if(penisExam != null) {
				var color:Int = Std.parseInt(targetColor);
				if(!targetColor.startsWith('0x')) color = Std.parseInt('0xff' + targetColor);

				var curColor:FlxColor = penisExam.color;
				curColor.alphaFloat = penisExam.alpha;
				PlayState.instance.modchartTweens.set(tag, FlxTween.color(penisExam, duration, curColor, color, {ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.modchartTweens.remove(tag);
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
					}
				}));
			} else
				couldntFindObject(vars);
		});

		//Tween shit, but for strums
		Lua_helper.add_callback(lua, "noteTweenX", function(tag:String, note:Int, value:Dynamic, duration:Float, ease:String) {
			cancelTween(tag);
			if(note < 0) note = 0;
			var testicle:StrumNote = PlayState.instance.strumLineNotes.members[note % PlayState.instance.strumLineNotes.length];

			if(testicle != null) {
				PlayState.instance.modchartTweens.set(tag, FlxTween.tween(testicle, {x: value}, duration, {ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
						PlayState.instance.modchartTweens.remove(tag);
					}
				}));
			}
		});
		Lua_helper.add_callback(lua, "noteTweenY", function(tag:String, note:Int, value:Dynamic, duration:Float, ease:String) {
			cancelTween(tag);
			if(note < 0) note = 0;
			var testicle:StrumNote = PlayState.instance.strumLineNotes.members[note % PlayState.instance.strumLineNotes.length];

			if(testicle != null) {
				PlayState.instance.modchartTweens.set(tag, FlxTween.tween(testicle, {y: value}, duration, {ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
						PlayState.instance.modchartTweens.remove(tag);
					}
				}));
			}
		});
		Lua_helper.add_callback(lua, "noteTweenAngle", function(tag:String, note:Int, value:Dynamic, duration:Float, ease:String) {
			cancelTween(tag);
			if(note < 0) note = 0;
			var testicle:StrumNote = PlayState.instance.strumLineNotes.members[note % PlayState.instance.strumLineNotes.length];

			if(testicle != null) {
				PlayState.instance.modchartTweens.set(tag, FlxTween.tween(testicle, {angle: value}, duration, {ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
						PlayState.instance.modchartTweens.remove(tag);
					}
				}));
			}
		});
		Lua_helper.add_callback(lua, "noteTweenDirection", function(tag:String, note:Int, value:Dynamic, duration:Float, ease:String) {
			cancelTween(tag);
			if(note < 0) note = 0;
			var testicle:StrumNote = PlayState.instance.strumLineNotes.members[note % PlayState.instance.strumLineNotes.length];

			if(testicle != null) {
				PlayState.instance.modchartTweens.set(tag, FlxTween.tween(testicle, {direction: value}, duration, {ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
						PlayState.instance.modchartTweens.remove(tag);
					}
				}));
			}
		});
		Lua_helper.add_callback(lua, "mouseClicked", function(button:String) {
			#if (FLX_MOUSE_ADVANCED && FLX_MOUSE)
			var boobs = FlxG.mouse.justPressed;
			switch(button.toLowerCase().trim()) {
				case 'middle':
					boobs = FlxG.mouse.justPressedMiddle;
				case 'right':
					boobs = FlxG.mouse.justPressedRight;
			}
			return boobs;
			#end
		});
		Lua_helper.add_callback(lua, "mousePressed", function(button:String) {
			#if (FLX_MOUSE_ADVANCED && FLX_MOUSE)
			var boobs = FlxG.mouse.pressed;
			switch(button.toLowerCase().trim()) {
				case 'middle':
					boobs = FlxG.mouse.pressedMiddle;
				case 'right':
					boobs = FlxG.mouse.pressedRight;
			}
			return boobs;
			#end
		});
		Lua_helper.add_callback(lua, "mouseReleased", function(button:String) {
			#if (FLX_MOUSE_ADVANCED && FLX_MOUSE)
			var boobs = FlxG.mouse.justReleased;
			switch(button.toLowerCase().trim()) {
				case 'middle':
					boobs = FlxG.mouse.justReleasedMiddle;
				case 'right':
					boobs = FlxG.mouse.justReleasedRight;
			}
			return boobs;
			#end
		});
		Lua_helper.add_callback(lua, "getMouseJustPressedTimeInTicks", function(button:String) {
			#if (FLX_MOUSE_ADVANCED && FLX_MOUSE)
			var boobs = FlxG.mouse.justPressedTimeInTicks;
			switch(button.toLowerCase().trim()) {
				case 'middle':
					boobs = FlxG.mouse.justPressedTimeInTicksMiddle;
				case 'right':
					boobs = FlxG.mouse.justPressedTimeInTicksRight;
			}
			return boobs;
			#end
		});
		Lua_helper.add_callback(lua, "setMouseVisible", function(state:Bool = true) {
			#if FLX_MOUSE
			FlxG.mouse.visible = state;
			#end
		});
		Lua_helper.add_callback(lua, "getMouseVisible", function() {
			#if FLX_MOUSE
			return FlxG.mouse.visible;
			#end
		});
		Lua_helper.add_callback(lua, "getMouseWheel", function() {
			#if FLX_MOUSE
			return FlxG.mouse.wheel;
			#end
		});
		Lua_helper.add_callback(lua, "getMouseEnabled", function() {
			#if FLX_MOUSE
			return FlxG.mouse.enabled;
			#end
		});
		Lua_helper.add_callback(lua, "setMouseEnabled", function(state:Bool) {
			#if FLX_MOUSE
			FlxG.mouse.enabled = state;
			#end
		});

		Lua_helper.add_callback(lua, "noteTweenAngle", function(tag:String, note:Int, value:Dynamic, duration:Float, ease:String) {
			cancelTween(tag);
			if(note < 0) note = 0;
			var testicle:StrumNote = PlayState.instance.strumLineNotes.members[note % PlayState.instance.strumLineNotes.length];

			if(testicle != null) {
				PlayState.instance.modchartTweens.set(tag, FlxTween.tween(testicle, {angle: value}, duration, {ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
						PlayState.instance.modchartTweens.remove(tag);
					}
				}));
			}
		});
		Lua_helper.add_callback(lua, "noteTweenAlpha", function(tag:String, note:Int, value:Dynamic, duration:Float, ease:String) {
			cancelTween(tag);
			if(note < 0) note = 0;
			var testicle:StrumNote = PlayState.instance.strumLineNotes.members[note % PlayState.instance.strumLineNotes.length];

			if(testicle != null) {
				PlayState.instance.modchartTweens.set(tag, FlxTween.tween(testicle, {alpha: value}, duration, {ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
						PlayState.instance.modchartTweens.remove(tag);
					}
				}));
			}
		});

		Lua_helper.add_callback(lua, "cancelTween", function(tag:String) {
			cancelTween(tag);
		});

		Lua_helper.add_callback(lua, "runTimer", function(tag:String, time:Float = 1, loops:Int = 1) {
			cancelTimer(tag);
			PlayState.instance.modchartTimers.set(tag, new FlxTimer().start(time, function(tmr:FlxTimer) {
				if(tmr.finished) {
					PlayState.instance.modchartTimers.remove(tag);
				}
				PlayState.instance.callOnLuas('onTimerCompleted', [tag, tmr.loops, tmr.loopsLeft]);
				//trace('Timer Completed: ' + tag);
			}, loops));
		});
		Lua_helper.add_callback(lua, "cancelTimer", function(tag:String) {
			cancelTimer(tag);
		});

		/*Lua_helper.add_callback(lua, "getPropertyAdvanced", function(varsStr:String) {
			var variables:Array<String> = varsStr.replace(' ', '').split(',');
			var leClass:Class<Dynamic> = Type.resolveClass(variables[0]);
			if(variables.length > 2) {
				var curProp:Dynamic = Reflect.getProperty(leClass, variables[1]);
				if(variables.length > 3) {
					for (i in 2...variables.length-1) {
						curProp = Reflect.getProperty(curProp, variables[i]);
					}
				}
				return Reflect.getProperty(curProp, variables[variables.length-1]);
			} else if(variables.length == 2) {
				return Reflect.getProperty(leClass, variables[variables.length-1]);
			}
			return null;
		});
		Lua_helper.add_callback(lua, "setPropertyAdvanced", function(varsStr:String, value:Dynamic) {
			var variables:Array<String> = varsStr.replace(' ', '').split(',');
			var leClass:Class<Dynamic> = Type.resolveClass(variables[0]);
			if(variables.length > 2) {
				var curProp:Dynamic = Reflect.getProperty(leClass, variables[1]);
				if(variables.length > 3) {
					for (i in 2...variables.length-1) {
						curProp = Reflect.getProperty(curProp, variables[i]);
					}
				}
				return Reflect.setProperty(curProp, variables[variables.length-1], value);
			} else if(variables.length == 2) {
				return Reflect.setProperty(leClass, variables[variables.length-1], value);
			}
		});*/
		
		//stupid bietch ass functions
		Lua_helper.add_callback(lua, "addScore", function(value:Int = 0) {
			PlayState.instance.songScore += value;
			PlayState.instance.RecalculateRating();
		});
		Lua_helper.add_callback(lua, "addMisses", function(value:Int = 0) {
			PlayState.instance.songMisses += value;
			PlayState.instance.RecalculateRating();
		});
		Lua_helper.add_callback(lua, "addHits", function(value:Int = 0) {
			PlayState.instance.songHits += value;
			PlayState.instance.RecalculateRating();
		});
		Lua_helper.add_callback(lua, "setScore", function(value:Int = 0) {
			PlayState.instance.songScore = value;
			PlayState.instance.RecalculateRating();
		});
		Lua_helper.add_callback(lua, "setMisses", function(value:Int = 0) {
			PlayState.instance.songMisses = value;
			PlayState.instance.RecalculateRating();
		});
		Lua_helper.add_callback(lua, "setHits", function(value:Int = 0) {
			PlayState.instance.songHits = value;
			PlayState.instance.RecalculateRating();
		});
		Lua_helper.add_callback(lua, "getScore", function() {
			return PlayState.instance.songScore;
		});
		Lua_helper.add_callback(lua, "getMisses", function() {
			return PlayState.instance.songMisses;
		});
		Lua_helper.add_callback(lua, "getHits", function() {
			return PlayState.instance.songHits;
		});
		Lua_helper.add_callback(lua, "setHealth", function(value:Float = 0) {
			PlayState.instance.health = value;
		});
		Lua_helper.add_callback(lua, "addHealth", function(value:Float = 0) {
			PlayState.instance.health += value;
		});
		Lua_helper.add_callback(lua, "getHealth", function() {
			return PlayState.instance.health;
		});
		Lua_helper.add_callback(lua, "setMaxHealth", function(value:Float = 0) {
			PlayState.instance.maxHealth = value;
		});
		Lua_helper.add_callback(lua, "addMaxHealth", function(value:Float = 0) {
			PlayState.instance.maxHealth += value;
		});
		Lua_helper.add_callback(lua, "getMaxHealth", function() {
			return PlayState.instance.maxHealth;
		});
		
		Lua_helper.add_callback(lua, "getColorFromHex", function(color:String) {
			if(!color.startsWith('0x')) color = '0xff' + color;
			return Std.parseInt(color);
		});

		Lua_helper.add_callback(lua, "keyJustPressed", function(name:String) {
			return controlsStuff(name, '_P');
		});
		Lua_helper.add_callback(lua, "keyPressed", function(name:String) {
			return controlsStuff(name);
		});
		Lua_helper.add_callback(lua, "keyReleased", function(name:String) {
			return controlsStuff(name, '_R');
		});

		Lua_helper.add_callback(lua, "addCharacterToList", function(name:String, type:String) {
			var charType:Int = 0;
			switch(charactersStuff(type)) {
				case 'gf':
					charType = 2;
				case 'dad':
					charType = 1;
			}
			PlayState.instance.addCharacterToList(name, charType);
		});
		Lua_helper.add_callback(lua, "precacheImage", function(name:String) {
			Paths.returnGraphic(name);
		});
		Lua_helper.add_callback(lua, "precacheSound", function(name:String) {
			CoolUtil.precacheSound(name);
		});
		Lua_helper.add_callback(lua, "precacheMusic", function(name:String) {
			CoolUtil.precacheMusic(name);
		});
		Lua_helper.add_callback(lua, "triggerEvent", function(name:String, arg1:Dynamic, arg2:Dynamic) {
			var value1:String = arg1;
			var value2:String = arg2;
			PlayState.instance.triggerEventNote(name, value1, value2);
			//trace('Triggered event: ' + name + ', ' + value1 + ', ' + value2);
		});

		Lua_helper.add_callback(lua, "startCountdown", function() {
			PlayState.instance.startCountdown();
			return true;
		});
		Lua_helper.add_callback(lua, "endSong", function() {
			PlayState.instance.KillNotes();
			PlayState.instance.endSong();
		});
		Lua_helper.add_callback(lua, "restartSong", function(skipTransition:Bool) {
			PlayState.instance.persistentUpdate = false;
			PauseSubState.restartSong(skipTransition);
		});
		Lua_helper.add_callback(lua, "exitSong", function(skipTransition:Bool) {
			if(skipTransition)
			{
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
			}

			PlayState.cancelMusicFadeTween();
			CustomFadeTransition.nextCamera = PlayState.instance.camOther;
			if(FlxTransitionableState.skipNextTransIn)
				CustomFadeTransition.nextCamera = null;

			if(PlayState.isStoryMode)
				MusicBeatState.switchState(new StoryMenuState());
			else
				MusicBeatState.switchState(new FreeplayState());

			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			PlayState.changedDifficulty = false;
			PlayState.chartingMode = false;
			PlayState.instance.transitioning = true;
		});
		Lua_helper.add_callback(lua, "getSongPosition", function() {
			return Conductor.songPosition;
		});

		Lua_helper.add_callback(lua, "getCharacterX", function(type:String) {
			switch(charactersStuff(type)) {
				case 'dad':
					return PlayState.instance.dadGroup.x;
				case 'gf':
					return PlayState.instance.gfGroup.x;
				default:
					return PlayState.instance.boyfriendGroup.x;
			}
		});
		Lua_helper.add_callback(lua, "setCharacterX", function(type:String, value:Float) {
			switch(charactersStuff(type)) {
				case 'dad':
					PlayState.instance.dadGroup.x = value;
				case 'gf':
					PlayState.instance.gfGroup.x = value;
				default:
					PlayState.instance.boyfriendGroup.x = value;
			}
		});
		Lua_helper.add_callback(lua, "getCharacterY", function(type:String) {
			switch(charactersStuff(type)) {
				case 'dad':
					return PlayState.instance.dadGroup.y;
				case 'gf':
					return PlayState.instance.gfGroup.y;
				default:
					return PlayState.instance.boyfriendGroup.y;
			}
		});
		Lua_helper.add_callback(lua, "setCharacterY", function(type:String, value:Float) {
			switch(charactersStuff(type)) {
				case 'dad':
					PlayState.instance.dadGroup.y = value;
				case 'gf':
					PlayState.instance.gfGroup.y = value;
				default:
					PlayState.instance.boyfriendGroup.y = value;
			}
		});
		Lua_helper.add_callback(lua, "cameraSetTarget", function(target:String) {
			var isDad:Bool = false;
			if(target == 'dad')
				isDad = true;
			PlayState.instance.moveCamera(isDad);
			return isDad;
		});
		Lua_helper.add_callback(lua, "cameraShake", function(camera:String, intensity:Float, duration:Float) {
			cameraFromString(camera).shake(intensity, duration);
		});
		
		Lua_helper.add_callback(lua, "cameraFlash", function(camera:String, color:String, duration:Float,forced:Bool) {
			var colorNum:Int = Std.parseInt(color);
			if(!color.startsWith('0x')) colorNum = Std.parseInt('0xff' + color);
			cameraFromString(camera).flash(colorNum, duration,null,forced);
		});
		Lua_helper.add_callback(lua, "cameraFade", function(camera:String, color:String, duration:Float,forced:Bool) {
			var colorNum:Int = Std.parseInt(color);
			if(!color.startsWith('0x')) colorNum = Std.parseInt('0xff' + color);
			cameraFromString(camera).fade(colorNum, duration,false,null,forced);
		});
		Lua_helper.add_callback(lua, "setRatingPercent", function(value:Float) {
			PlayState.instance.ratingPercent = value;
		});
		Lua_helper.add_callback(lua, "setRatingName", function(value:String) {
			PlayState.instance.ratingName = value;
		});
		Lua_helper.add_callback(lua, "setRatingFC", function(value:String) {
			PlayState.instance.ratingFC = value;
		});
		Lua_helper.add_callback(lua, "getMouseX", function(camera:String) {
			var cam:FlxCamera = cameraFromString(camera);
			return FlxG.mouse.getScreenPosition(cam).x;
		});
		Lua_helper.add_callback(lua, "getMouseY", function(camera:String) {
			var cam:FlxCamera = cameraFromString(camera);
			return FlxG.mouse.getScreenPosition(cam).y;
		});

		Lua_helper.add_callback(lua, "getMidpointX", function(variable:String) {
			var killMe:Array<String> = variable.split('.');
			var obj:FlxSprite = getObjectDirectly(killMe[0]);
			if(killMe.length > 1)
				obj = getVarInArray(getPropertyLoopThingWhatever(killMe), killMe[killMe.length-1]);

			if(obj != null) return obj.getMidpoint().x;

			return 0;
		});
		Lua_helper.add_callback(lua, "getMidpointY", function(variable:String) {
			var obj:FlxObject = getObjectDirectly(variable);
			if(obj != null) return obj.getMidpoint().y;

			return 0;
		});
		Lua_helper.add_callback(lua, "getGraphicMidpointX", function(variable:String) {
			var obj:FlxSprite = getObjectDirectly(variable);
			if(obj != null) return obj.getGraphicMidpoint().x;

			return 0;
		});
		Lua_helper.add_callback(lua, "getGraphicMidpointY", function(variable:String) {
			var obj:FlxSprite = getObjectDirectly(variable);
			if(obj != null) return obj.getGraphicMidpoint().y;

			return 0;
		});
		Lua_helper.add_callback(lua, "getScreenPositionX", function(variable:String) {
			var obj:FlxObject = getObjectDirectly(variable);
			if(obj != null) return obj.getScreenPosition().x;

			return 0;
		});
		Lua_helper.add_callback(lua, "getScreenPositionY", function(variable:String) {
			var obj:FlxObject = getObjectDirectly(variable);
			if(obj != null) return obj.getScreenPosition().y;

			return 0;
		});
		Lua_helper.add_callback(lua, "characterPlayAnim", function(character:String, anim:String, ?forced:Bool = false) {
			switch(charactersStuff(character)) {
				case 'dad':
					if(PlayState.instance.dad.animOffsets.exists(anim))
						PlayState.instance.dad.playAnim(anim, forced);
				case 'gf':
					if(PlayState.instance.gf != null && PlayState.instance.gf.animOffsets.exists(anim))
						PlayState.instance.gf.playAnim(anim, forced);
				default: 
					if(PlayState.instance.boyfriend.animOffsets.exists(anim))
						PlayState.instance.boyfriend.playAnim(anim, forced);
			}
		});
		Lua_helper.add_callback(lua, "characterDance", function(character:String) {
			switch(charactersStuff(character)) {
				case 'dad': PlayState.instance.dad.dance();
				case 'gf': if(PlayState.instance.gf != null) PlayState.instance.gf.dance();
				default: PlayState.instance.boyfriend.dance();
			}
		});

		Lua_helper.add_callback(lua, "makeLuaSprite", function(tag:String, image:String, x:Float, y:Float) {
			/*
			if(FileSystem.exists(Paths.image(image))) {
				luaTrace('The image $image doesnt exists');
				return null;
			}*/
			tag = tag.replace('.', '');
			resetSpriteTag(tag);
			var leSprite:ModchartSprite = new ModchartSprite(x, y);
			if(image != null && image.length > 0)
				leSprite.loadGraphic(Paths.image(image));

			leSprite.antialiasing = ClientPrefs.globalAntialiasing;
			PlayState.instance.modchartSprites.set(tag, leSprite);
			leSprite.active = true;
		});
		Lua_helper.add_callback(lua, "makeAnimatedLuaSprite", function(tag:String, image:String, x:Float, y:Float, ?spriteType:String = "sparrow") {
			tag = tag.replace('.', '');
			resetSpriteTag(tag);
			var leSprite:ModchartSprite = new ModchartSprite(x, y);
			
			loadFrames(leSprite, image, spriteType);
			leSprite.antialiasing = ClientPrefs.globalAntialiasing;
			PlayState.instance.modchartSprites.set(tag, leSprite);
		});

		Lua_helper.add_callback(lua, "makeGraphic", function(obj:String, width:Int, height:Int, color:String) {
			var colorNum:Int = Std.parseInt(color);
			if(!color.startsWith('0x')) colorNum = Std.parseInt('0xff' + color);

			var spr:FlxSprite = PlayState.instance.getLuaObject(obj,false);
			if(spr != null) {
				PlayState.instance.getLuaObject(obj,false).makeGraphic(width, height, colorNum);
				return;
			}

			var object:FlxSprite = Reflect.getProperty(getInstance(), obj);
			if(object != null) {
				object.makeGraphic(width, height, colorNum);
			}
		});
		Lua_helper.add_callback(lua, "addAnimationByPrefix", function(obj:String, name:String, prefix:String, framerate:Int = 24, loop:Bool = true) {
			var object:Null<String> = if(PlayState.instance.getLuaObject(obj, false) != null) obj else if(PlayState.instance.getLuaObject(obj.toLowerCase(), false) != null) obj.toLowerCase() else null;
			if(object != null) {
				var cock:FlxSprite = PlayState.instance.getLuaObject(object, false);
				cock.animation.addByPrefix(name, prefix, framerate, loop);
				if(cock.animation.curAnim == null) {
					cock.animation.play(name, true);
				}
				return;
			}

			var cock:FlxSprite = if(Reflect.getProperty(getInstance(), obj) != null) Reflect.getProperty(getInstance(), obj) else Reflect.getProperty(getInstance(), obj.toLowerCase());
			if(cock != null) {
				cock.animation.addByPrefix(name, prefix, framerate, loop);
				if(cock.animation.curAnim == null) {
					cock.animation.play(name, true);
				}
			}
		});

		Lua_helper.add_callback(lua, "addAnimation", function(obj:String, name:String, frames:Array<Int>, framerate:Int = 24, loop:Bool = true) {
			var object:Null<String> = if(PlayState.instance.getLuaObject(obj, false) != null) obj else if(PlayState.instance.getLuaObject(obj.toLowerCase(), false) != null) obj.toLowerCase() else null;
 			if(object != null) {
 				var cock:FlxSprite = PlayState.instance.getLuaObject(obj,false);
 				cock.animation.add(name, frames, framerate, loop);
 				if(cock.animation.curAnim == null) {
 					cock.animation.play(name, true);
 				}
 				return;
 			}

 			var cock:FlxSprite = if(Reflect.getProperty(getInstance(), obj) != null) Reflect.getProperty(getInstance(), obj) else Reflect.getProperty(getInstance(), obj.toLowerCase());
 			if(cock != null) {
 				cock.animation.add(name, frames, framerate, loop);
 				if(cock.animation.curAnim == null) {
 					cock.animation.play(name, true);
 				}
 			}
 		});

		Lua_helper.add_callback(lua, "addAnimationByIndices", function(obj:String, name:String, prefix:String, indices:String, framerate:Int = 24) {
			var strIndices:Array<String> = indices.trim().split(',');
			var die:Array<Int> = [];
			for (i in 0...strIndices.length) {
				die.push(Std.parseInt(strIndices[i]));
			}

			var object:Null<String> = if(PlayState.instance.getLuaObject(obj, false) != null) obj else if(PlayState.instance.getLuaObject(obj.toLowerCase(), false) != null) obj.toLowerCase() else null;
			if(object != null) {
				var pussy:FlxSprite = PlayState.instance.getLuaObject(obj,false);
				pussy.animation.addByIndices(name, prefix, die, '', framerate, false);
				if(pussy.animation.curAnim == null) {
					pussy.animation.play(name, true);
				}
				return true;
			}

			var pussy:FlxSprite = if(Reflect.getProperty(getInstance(), obj) != null) Reflect.getProperty(getInstance(), obj) else Reflect.getProperty(getInstance(), obj.toLowerCase());
			if(pussy != null) {
				pussy.animation.addByIndices(name, prefix, die, '', framerate, false);
				if(pussy.animation.curAnim == null) {
					pussy.animation.play(name, true);
				}
				return true;
			}
			return false;
		});
		Lua_helper.add_callback(lua, "objectPlayAnimation", function(obj:String, name:String, forced:Bool = false, ?startFrame:Int = 0) {
			var object:Null<String> = if(PlayState.instance.getLuaObject(obj, false) != null) obj else if(PlayState.instance.getLuaObject(obj.toLowerCase(), false) != null) obj.toLowerCase() else null;
			if(object != null) {
				PlayState.instance.getLuaObject(object, false).animation.play(name, forced, startFrame);
				return true;
			}

			var spr:FlxSprite = if(Reflect.getProperty(getInstance(), obj) != null) Reflect.getProperty(getInstance(), obj) else Reflect.getProperty(getInstance(), obj.toLowerCase());
			if(spr != null) {
				spr.animation.play(name, forced);
				return true;
			}
			return false;
		});
		
		Lua_helper.add_callback(lua, "setScrollFactor", function(obj:String, scrollX:Float, scrollY:Float) {
			var object:Null<String> = if(PlayState.instance.getLuaObject(obj, false) != null) obj else if(PlayState.instance.getLuaObject(obj.toLowerCase(), false) != null) obj.toLowerCase() else null;
			if(object != null) {
				PlayState.instance.getLuaObject(object, false).scrollFactor.set(scrollX, scrollY);
				return true;
			}

			var object:FlxSprite = if(Reflect.getProperty(getInstance(), obj) != null) Reflect.getProperty(getInstance(), obj) else Reflect.getProperty(getInstance(), obj.toLowerCase());
			if(object != null) {
				object.scrollFactor.set(scrollX, scrollY);
				return true;
			}
			return false;
		});
		Lua_helper.add_callback(lua, "addLuaSprite", function(tag:String, front:Bool = false) {
			var tagger:Null<String> = if(PlayState.instance.modchartSprites.exists(tag)) tag else if(PlayState.instance.modchartSprites.exists(tag.toLowerCase())) tag.toLowerCase() else null;
			if(tagger != null) {
				var shit:ModchartSprite = PlayState.instance.modchartSprites.get(tagger);
				if(!shit.wasAdded) {
					if(front)
						getInstance().add(shit);
					else
					{
						if(PlayState.instance.isDead)
							GameOverSubstate.instance.insert(GameOverSubstate.instance.members.indexOf(GameOverSubstate.instance.boyfriend), shit);
						else
						{
							var position:Int = PlayState.instance.members.indexOf(PlayState.instance.gfGroup);
							if(PlayState.instance.members.indexOf(PlayState.instance.boyfriendGroup) < position)
								position = PlayState.instance.members.indexOf(PlayState.instance.boyfriendGroup);
							else if(PlayState.instance.members.indexOf(PlayState.instance.dadGroup) < position)
								position = PlayState.instance.members.indexOf(PlayState.instance.dadGroup);

							PlayState.instance.insert(position, shit);
						}
					}
					shit.wasAdded = true;
					//trace('added a thing: ' + tag);
				}
			}
		});
		Lua_helper.add_callback(lua, "setGraphicSize", function(obj:String, x:Int, y:Int = 0, updateHitbox:Bool = true) {
			var here = if(PlayState.instance.getLuaObject(obj) != null) obj else if(PlayState.instance.getLuaObject(obj.toLowerCase()) != null) obj.toLowerCase() else 'nope';
			if(here != 'nope') {
				var shit:FlxSprite = PlayState.instance.getLuaObject(here);
				shit.setGraphicSize(x, y);
				if(updateHitbox) shit.updateHitbox();
				return;
			}

			var killMe:Array<String> = obj.split('.');
			var poop:FlxSprite = getObjectDirectly(killMe[0]);
			if(killMe.length > 1) {
				poop = getVarInArray(getPropertyLoopThingWhatever(killMe), killMe[killMe.length-1]);
			}

			if(poop != null) {
				poop.setGraphicSize(x, y);
				if(updateHitbox) poop.updateHitbox();
				return;
			}
			traceLuaError('Couldnt find object: ' + obj);
		});
		Lua_helper.add_callback(lua, "scaleObject", function(obj:String, x:Float, y:Float, updateHitbox:Bool = true) {
			var here = if(PlayState.instance.getLuaObject(obj) != null) obj else if(PlayState.instance.getLuaObject(obj.toLowerCase()) != null) obj.toLowerCase() else 'nope';
			if(here != 'nope') {
				var shit:FlxSprite = PlayState.instance.getLuaObject(here);
				shit.scale.set(x, y);
				if(updateHitbox) shit.updateHitbox();
				return;
			}

			var killMe:Array<String> = obj.split('.');
			var poop:FlxSprite = getObjectDirectly(killMe[0]);
			if(killMe.length > 1) {
				poop = getVarInArray(getPropertyLoopThingWhatever(killMe), killMe[killMe.length-1]);
			}

			if(poop != null) {
				poop.scale.set(x, y);
				if(updateHitbox) poop.updateHitbox();
				return;
			}
			traceLuaError('Couldnt find object: ' + obj);
		});
		Lua_helper.add_callback(lua, "updateHitbox", function(obj:String) {
			var here = if(PlayState.instance.getLuaObject(obj) != null) obj else if(PlayState.instance.getLuaObject(obj.toLowerCase()) != null) obj.toLowerCase() else 'nope';
			if(here != 'nope') {
				var shit:FlxSprite = PlayState.instance.getLuaObject(here);
				shit.updateHitbox();
				return;
			}

			var poop:FlxSprite = Reflect.getProperty(getInstance(), obj);
			if(poop != null) {
				poop.updateHitbox();
				return;
			}
			traceLuaError('Couldnt find object: ' + obj);
		});
		Lua_helper.add_callback(lua, "updateHitboxFromGroup", function(group:String, index:Int) {
			if(Std.isOfType(Reflect.getProperty(getInstance(), group), FlxTypedGroup)) {
				Reflect.getProperty(getInstance(), group).members[index].updateHitbox();
				return;
			}
			Reflect.getProperty(getInstance(), group)[index].updateHitbox();
		});

		Lua_helper.add_callback(lua, "isNoteChild", function(parentID:Int, childID:Int){
			var parent:Note = cast PlayState.instance.getLuaObject('note${parentID}',false);
			var child:Note = cast PlayState.instance.getLuaObject('note${childID}',false);
			if(parent != null && child != null)
				return parent.tail.contains(child);

			traceLuaError('${parentID} or ${childID} is not a valid note ID');
			return false;
		});
		Lua_helper.add_callback(lua, "removeLuaSprite", function(tag:String, destroy:Bool = true) {
			if(!PlayState.instance.modchartSprites.exists(tag)) {
				return;
			}
			
			var pee:ModchartSprite = PlayState.instance.modchartSprites.get(tag);
			if(destroy)
				pee.kill();

			if(pee.wasAdded) {
				getInstance().remove(pee, true);
				pee.wasAdded = false;
			}

			if(destroy) {
				pee.destroy();
				PlayState.instance.modchartSprites.remove(tag);
			}
		});

		Lua_helper.add_callback(lua, "setObjectCamera", function(obj:String, camera:String = '') {
			/*if(PlayState.instance.modchartSprites.exists(obj)) {
				PlayState.instance.modchartSprites.get(obj).cameras = [cameraFromString(camera)];
				return true;
			}
			else if(PlayState.instance.modchartTexts.exists(obj)) {
				PlayState.instance.modchartTexts.get(obj).cameras = [cameraFromString(camera)];
				return true;
			}*/
			var real = PlayState.instance.getLuaObject(obj);
			if(real != null) {
				real.cameras = [cameraFromString(camera)];
				return true;
			}

			var killMe:Array<String> = obj.split('.');
			var object:FlxSprite = getObjectDirectly(killMe[0]);
			if(killMe.length > 1) {
				object = getVarInArray(getPropertyLoopThingWhatever(killMe), killMe[killMe.length-1]);
			}

			if(object != null) {
				object.cameras = [cameraFromString(camera)];
				return true;
			}
			traceLuaError("Object " + obj + " doesn't exist!");
			return false;
		});
		Lua_helper.add_callback(lua, "setBlendMode", function(obj:String, blend:String = '') {
			var real = if(PlayState.instance.getLuaObject(obj) != null) PlayState.instance.getLuaObject(obj) else if(PlayState.instance.getLuaObject(obj.toLowerCase()) != null) PlayState.instance.getLuaObject(obj.toLowerCase()) else null;
			if(real != null) {
				real.blend = blendModeFromString(blend);
				return true;
			}

			var killMe:Array<String> = obj.split('.');
			var spr:FlxSprite = getObjectDirectly(killMe[0]);
			if(killMe.length > 1) {
				spr = getVarInArray(getPropertyLoopThingWhatever(killMe), killMe[killMe.length-1]);
			}

			if(spr != null) {
				spr.blend = blendModeFromString(blend);
				return true;
			}
			traceLuaError("Object " + obj + " doesn't exist!");
			return false;
		});

		Lua_helper.add_callback(lua, "screenCenter", function(obj:String, pos:String = 'xy') {
			var spr:FlxSprite = PlayState.instance.getLuaObject(obj);

			if(spr == null) {
				var killMe:Array<String> = obj.split('.');
				spr = getObjectDirectly(killMe[0]);
				if(killMe.length > 1) {
					spr = getVarInArray(getPropertyLoopThingWhatever(killMe), killMe[killMe.length-1]);
				}
			}

			if(spr != null)
			{
				switch(pos.trim().toLowerCase())
				{
					case 'x':
						spr.screenCenter(X);
						return;
					case 'y':
						spr.screenCenter(Y);
						return;
					default:
						spr.screenCenter(XY);
						return;
				}
			}
			traceLuaError("Object " + obj + " doesn't exist!");
		});
		Lua_helper.add_callback(lua, "objectsOverlap", function(obj1:String, obj2:String) {
			var namesArray:Array<String> = [obj1, obj2];
			var objectsArray:Array<FlxSprite> = [];
			for (i in 0...namesArray.length)
			{
				var real = PlayState.instance.getLuaObject(namesArray[i]);
				if(real != null) {
					objectsArray.push(real);
				} else {
					objectsArray.push(Reflect.getProperty(getInstance(), namesArray[i]));
				}
			}

			if(!objectsArray.contains(null) && FlxG.overlap(objectsArray[0], objectsArray[1]))
			{
				return true;
			}
			return false;
		});
		Lua_helper.add_callback(lua, "getPixelColor", function(obj:String, x:Int, y:Int) {
			var killMe:Array<String> = obj.split('.');
			var spr:FlxSprite = getObjectDirectly(killMe[0]);
			if(killMe.length > 1)
				spr = getVarInArray(getPropertyLoopThingWhatever(killMe), killMe[killMe.length-1]);

			if(spr != null)
			{
				if(spr.framePixels != null) spr.framePixels.getPixel32(x, y);
				return spr.pixels.getPixel32(x, y);
			}
			return 0;
		});
		Lua_helper.add_callback(lua, "getRandomInt", function(min:Int, max:Int = FlxMath.MAX_VALUE_INT, exclude:String = '') {
			var excludeArray:Array<String> = exclude.split(',');
			var toExclude:Array<Int> = [];
			for (i in 0...excludeArray.length)
			{
				toExclude.push(Std.parseInt(excludeArray[i].trim()));
			}
			return FlxG.random.int(min, max, toExclude);
		});
		Lua_helper.add_callback(lua, "getRandomFloat", function(min:Float, max:Float = 1, exclude:String = '') {
			var excludeArray:Array<String> = exclude.split(',');
			var toExclude:Array<Float> = [];
			for (i in 0...excludeArray.length)
			{
				toExclude.push(Std.parseFloat(excludeArray[i].trim()));
			}
			return FlxG.random.float(min, max, toExclude);
		});
		Lua_helper.add_callback(lua, "getRandomBool", function(chance:Float = 50) {
			return FlxG.random.bool(chance);
		});
		Lua_helper.add_callback(lua, "startDialogue", function(dialogueFile:String, music:String = null) {
			var path:String = Paths.modsJson(Paths.formatToSongPath(PlayState.SONG.song) + '/$dialogueFile');
			if(!FileSystem.exists(path))
				path = Paths.json(Paths.formatToSongPath(PlayState.SONG.song) + '/$dialogueFile');
			luaTrace('Trying to load dialogue: $path');

			if(FileSystem.exists(path)) {
				var shit:DialogueFile = DialogueBoxPsych.parseDialogue(path);
				if(shit.dialogue.length > 0) {
					PlayState.instance.startDialogue(shit, music);
					traceLuaError('Successfully loaded dialogue "$dialogueFile"');
				} else
					traceLuaError('Dialogue file "$dialogueFile" is badly formatted!');
			} else {
				traceLuaError('Dialogue file "' + dialogueFile + '" not found');
				if(PlayState.instance.endingSong)
					PlayState.instance.endSong();
				else
					PlayState.instance.startCountdown();
			}
		});
		Lua_helper.add_callback(lua, "startVideo", function(videoFile:String) {
			#if VIDEOS_ALLOWED
			if(FileSystem.exists(Paths.video(videoFile)))
				PlayState.instance.startVideo(videoFile);
			else if(FileSystem.exists(Paths.video(videoFile.toLowerCase())))
				PlayState.instance.startVideo(videoFile.toLowerCase());
			else
				traceLuaError('Video file not found: $videoFile');
			#else
			traceLuaError('videos are not allowed');
			if(PlayState.instance.endingSong)
				PlayState.instance.endSong();
			else
				PlayState.instance.startCountdown();
			#end
		});
		
		Lua_helper.add_callback(lua, "playMusic", function(sound:String, volume:Float = 1, loop:Bool = false) {
			FlxG.sound.playMusic(Paths.music(sound), volume, loop);
		});
		Lua_helper.add_callback(lua, "playSound", function(sound:String, volume:Float = 1, ?tag:String = null) {
			if(tag != null && tag.length > 0) {
				tag = tag.replace('.', '');
				if(PlayState.instance.modchartSounds.exists(tag))
					PlayState.instance.modchartSounds.get(tag).stop();
				PlayState.instance.modchartSounds.set(tag, FlxG.sound.play(Paths.sound(sound), volume, false, function() {
					PlayState.instance.modchartSounds.remove(tag);
					PlayState.instance.callOnLuas('onSoundFinished', [tag]);
				}));
				return;
			}
			FlxG.sound.play(Paths.sound(sound), volume);
		});
		Lua_helper.add_callback(lua, "stopSound", function(tag:String = '') {
			var blabla = if(PlayState.instance.modchartSounds.exists(tag)) tag else if(PlayState.instance.modchartSounds.exists(tag.toLowerCase())) tag.toLowerCase() else null;
			if(tag != null && tag.length > 1 && blabla != null) {
				PlayState.instance.modchartSounds.get(blabla).stop();
				PlayState.instance.modchartSounds.remove(blabla);
			}
		});
		Lua_helper.add_callback(lua, "pauseSound", function(tag:String = '') {
			if(tag != null && tag.length > 1 && PlayState.instance.modchartSounds.exists(tag)) {
				PlayState.instance.modchartSounds.get(tag).pause();
			} else if(tag != null && tag.length > 1 && PlayState.instance.modchartSounds.exists(tag.toLowerCase())) {
				PlayState.instance.modchartSounds.get(tag.toLowerCase()).pause();
			}
		});
		Lua_helper.add_callback(lua, "resumeSound", function(tag:String = '') {
			if(tag != null && tag.length > 1 && PlayState.instance.modchartSounds.exists(tag)) {
				PlayState.instance.modchartSounds.get(tag).play();
			} else if(tag != null && tag.length > 1 && PlayState.instance.modchartSounds.exists(tag.toLowerCase())) {
				PlayState.instance.modchartSounds.get(tag.toLowerCase()).play();
			}
		});
		Lua_helper.add_callback(lua, "soundFadeIn", function(tag:String, duration:Float, fromValue:Float = 0, toValue:Float = 1) {
			if(tag == null || tag.length < 1)
				FlxG.sound.music.fadeIn(duration, fromValue, toValue);
			else if(PlayState.instance.modchartSounds.exists(tag))
				PlayState.instance.modchartSounds.get(tag).fadeIn(duration, fromValue, toValue);
			else if(PlayState.instance.modchartSounds.exists(tag.toLowerCase()))
				PlayState.instance.modchartSounds.get(tag.toLowerCase()).fadeIn(duration, fromValue, toValue);
		});
		Lua_helper.add_callback(lua, "soundFadeOut", function(tag:String, duration:Float, toValue:Float = 0) {
			if(tag == null || tag.length < 1)
				FlxG.sound.music.fadeOut(duration, toValue);
			else if(PlayState.instance.modchartSounds.exists(tag))
				PlayState.instance.modchartSounds.get(tag).fadeOut(duration, toValue);
		});
		Lua_helper.add_callback(lua, "soundFadeCancel", function(tag:String = '') {
			if((tag == null || tag.length < 1) && FlxG.sound.music.fadeTween != null)
				FlxG.sound.music.fadeTween.cancel();
			else if(PlayState.instance.modchartSounds.exists(tag)) {
				var theSound:FlxSound = PlayState.instance.modchartSounds.get(tag);
				if(theSound.fadeTween != null) {
					theSound.fadeTween.cancel();
					PlayState.instance.modchartSounds.remove(tag);
				}
			}
		});
		Lua_helper.add_callback(lua, "getSoundVolume", function(tag:String = '') {
			if((tag == null || tag.length < 1) && FlxG.sound.music != null)
				return FlxG.sound.music.volume;
			else if(PlayState.instance.modchartSounds.exists(tag))
				return PlayState.instance.modchartSounds.get(tag).volume;
			return 0;
		});
		Lua_helper.add_callback(lua, "setSoundVolume", function(tag:String, value:Float) {
			if((tag == null || tag.length < 1) && FlxG.sound.music != null)
				FlxG.sound.music.volume = value;
			else if(PlayState.instance.modchartSounds.exists(tag))
				PlayState.instance.modchartSounds.get(tag).volume = value;
			else if(PlayState.instance.modchartSounds.exists(tag.toLowerCase()))
				PlayState.instance.modchartSounds.get(tag.toLowerCase()).volume = value;
		});
		Lua_helper.add_callback(lua, "getSoundTime", function(tag:String = '') {
			if(tag != null && tag.length > 0 && PlayState.instance.modchartSounds.exists(tag))
				return PlayState.instance.modchartSounds.get(tag).time;
			else if(tag != null && tag.length > 0 && PlayState.instance.modchartSounds.exists(tag.toLowerCase()))
				return PlayState.instance.modchartSounds.get(tag.toLowerCase()).time;
			return 0;
		});
		Lua_helper.add_callback(lua, "setSoundTime", function(tag:String, value:Float) {
			var tagger:String = if(PlayState.instance.modchartSounds.exists(tag)) tag else if(PlayState.instance.modchartSounds.exists(tag.toLowerCase())) tag.toLowerCase() else 'nope';
			if(tag != null && tag.length > 0 && tagger != 'nope') {
				var theSound:FlxSound = PlayState.instance.modchartSounds.get(tagger);
				if(theSound != null) {
					var wasResumed:Bool = theSound.playing;
					theSound.pause();
					theSound.time = value;
					if(wasResumed) theSound.play();
				}
			}
		});

		Lua_helper.add_callback(lua, "debugPrint", function(text1:Dynamic = '', text2:Dynamic = '', text3:Dynamic = '', text4:Dynamic = '', text5:Dynamic = '', color:String = 'white') {
			if (text1 == null) text1 = '';
			if (text2 == null) text2 = '';
			if (text3 == null) text3 = '';
			if (text4 == null) text4 = '';
			if (text5 == null) text5 = '';
			luaTrace('' + text1 + text2 + text3 + text4 + text5, true, false, color);
		});
		Lua_helper.add_callback(lua, "debugPrintArray", function(text:Array<String>, color:String = 'white') { // better for arrays
			var thisText:String = '';
			for (i in 0...text.length) {
				thisText += text[i];
			}
			luaTrace(thisText, true, false, color);
		});

		Lua_helper.add_callback(lua, "close", function() {
			closed = true;
			return closed;
		});
		Lua_helper.add_callback(lua, "stopScript", function(printMessage:Bool) {
			if(!gonnaClose) {
				if(printMessage)
					luaTrace('Stopping lua script: $scriptName');
				PlayState.instance.closeLuas.push(this);
			}
			gonnaClose = true;
		});

		Lua_helper.add_callback(lua, "changePresence", function(details:String, state:Null<String>, ?smallImageKey:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float) {
			#if desktop
				DiscordClient.changePresence(details, state, smallImageKey, hasStartTimestamp, endTimestamp);
			#end
		});


		// LUA TEXTS
		Lua_helper.add_callback(lua, "makeLuaText", function(tag:String, text:String, width:Int, x:Float, y:Float) {
			tag = tag.replace('.', '');
			resetTextTag(tag);
			var leText:ModchartText = new ModchartText(x, y, text, width);
			PlayState.instance.modchartTexts.set(tag, leText);
		});

		Lua_helper.add_callback(lua, "setTextString", function(tag:String, text:String) {
			var obj:FlxText = if(getTextObject(tag) != null) getTextObject(tag) else getTextObject(tag.toLowerCase());
			if(obj != null)
				obj.text = text;
		});
		Lua_helper.add_callback(lua, "setTextSize", function(tag:String, size:Int) {
			var obj:FlxText = if(getTextObject(tag) != null) getTextObject(tag) else getTextObject(tag.toLowerCase());
			if(obj != null)
				obj.size = size;
		});
		Lua_helper.add_callback(lua, "setTextWidth", function(tag:String, width:Float) {
			var obj:FlxText = if(getTextObject(tag) != null) getTextObject(tag) else getTextObject(tag.toLowerCase());
			if(obj != null)
				obj.fieldWidth = width;
		});
		Lua_helper.add_callback(lua, "setTextBorder", function(tag:String, size:Int, color:String) {
			var obj:FlxText = if(getTextObject(tag) != null) getTextObject(tag) else getTextObject(tag.toLowerCase());
			if(obj != null)
			{
				var colorNum:Int = Std.parseInt(color);
				if(!color.startsWith('0x')) colorNum = Std.parseInt('0xff' + color);

				obj.borderSize = size;
				obj.borderColor = colorNum;
			}
		});
		Lua_helper.add_callback(lua, "setTextColor", function(tag:String, color:String) {
			var obj:FlxText = if(getTextObject(tag) != null) getTextObject(tag) else getTextObject(tag.toLowerCase());
			if(obj != null)
			{
				var colorNum:Int = Std.parseInt(color);
				if(!color.startsWith('0x')) colorNum = Std.parseInt('0xff' + color);

				obj.color = colorNum;
			}
		});
		Lua_helper.add_callback(lua, "setTextFont", function(tag:String, newFont:String) {
			var obj:FlxText = if(getTextObject(tag) != null) getTextObject(tag) else getTextObject(tag.toLowerCase());
			if(obj != null)
				obj.font = Paths.font(newFont);
		});
		Lua_helper.add_callback(lua, "setTextItalic", function(tag:String, italic:Bool) {
			var obj:FlxText = if(getTextObject(tag) != null) getTextObject(tag) else getTextObject(tag.toLowerCase());
			if(obj != null)
				obj.italic = italic;
		});
		Lua_helper.add_callback(lua, "setTextAlignment", function(tag:String, alignment:String = 'left') {
			var obj:FlxText = if(getTextObject(tag) != null) getTextObject(tag) else getTextObject(tag.toLowerCase());
			if(obj != null)
			{
				obj.alignment = LEFT;
				switch(alignment.trim().toLowerCase())
				{
					case 'right':
						obj.alignment = RIGHT;
					case 'center':
						obj.alignment = CENTER;
				}
			}
		});

		Lua_helper.add_callback(lua, "getTextString", function(tag:String) {
			var obj:FlxText = if(getTextObject(tag) != null) getTextObject(tag) else getTextObject(tag.toLowerCase());
			if(obj != null)
				return obj.text;
			return null;
		});
		Lua_helper.add_callback(lua, "getTextSize", function(tag:String) {
			var obj:FlxText = if(getTextObject(tag) != null) getTextObject(tag) else getTextObject(tag.toLowerCase());
			if(obj != null)
				return obj.size;
			return -1;
		});
		Lua_helper.add_callback(lua, "getTextFont", function(tag:String) {
			var obj:FlxText = if(getTextObject(tag) != null) getTextObject(tag) else getTextObject(tag.toLowerCase());
			if(obj != null)
				return obj.font;
			return null;
		});
		Lua_helper.add_callback(lua, "getTextWidth", function(tag:String) {
			var obj:FlxText = if(getTextObject(tag) != null) getTextObject(tag) else getTextObject(tag.toLowerCase());
			if(obj != null)
				return obj.fieldWidth;
			return 0;
		});

		Lua_helper.add_callback(lua, "addLuaText", function(tag:String) {
			var tagger:String = if(PlayState.instance.modchartTexts.exists(tag)) tag else if(PlayState.instance.modchartTexts.exists(tag.toLowerCase())) tag.toLowerCase() else 'nope';
			if(tagger != 'nope') {
				var shit:ModchartText = PlayState.instance.modchartTexts.get(tagger);
				if(!shit.wasAdded) {
					getInstance().add(shit);
					shit.wasAdded = true;
					//trace('added a thing: ' + tag);
				}
			}
		});
		Lua_helper.add_callback(lua, "removeLuaText", function(tag:String, destroy:Bool = true) {
			if(!PlayState.instance.modchartTexts.exists(tag))
				return;
			
			var pee:ModchartText = PlayState.instance.modchartTexts.get(tag);
			if(destroy)
				pee.kill();

			if(pee.wasAdded) {
				getInstance().remove(pee, true);
				pee.wasAdded = false;
			}

			if(destroy) {
				pee.destroy();
				PlayState.instance.modchartTexts.remove(tag);
			}
		});

		Lua_helper.add_callback(lua, "initSaveData", function(name:String, ?folder:String = 'psychenginemods') {
			if(!PlayState.instance.modchartSaves.exists(name))
			{
				var save:FlxSave = new FlxSave();
				save.bind(name, folder);
				PlayState.instance.modchartSaves.set(name, save);
				return;
			}
			luaTrace('Save file already initialized: $name');
		});
		Lua_helper.add_callback(lua, "flushSaveData", function(name:String) {
			if(PlayState.instance.modchartSaves.exists(name))
			{
				PlayState.instance.modchartSaves.get(name).flush();
				return;
			}
			luaTrace('Save file not initialized: $name');
		});
		Lua_helper.add_callback(lua, "getDataFromSave", function(name:String, field:String) {
			if(PlayState.instance.modchartSaves.exists(name))
			{
				var retVal:Dynamic = Reflect.field(PlayState.instance.modchartSaves.get(name).data, field);
				return retVal;
			}
			luaTrace('Save file not initialized: $name');
			return null;
		});
		Lua_helper.add_callback(lua, "setDataFromSave", function(name:String, field:String, value:Dynamic) {
			if(PlayState.instance.modchartSaves.exists(name))
			{
				Reflect.setField(PlayState.instance.modchartSaves.get(name).data, field, value);
				return;
			}
			luaTrace('Save file not initialized: $name');
		});
		
		Lua_helper.add_callback(lua, "getTextFromFile", function(path:String, ?ignoreModFolders:Bool = false) {
			return Paths.getTextFromFile(path, ignoreModFolders);
		});

		// DEPRECATED, DONT MESS WITH THESE SHITS, ITS JUST THERE FOR BACKWARD COMPATIBILITY
		Lua_helper.add_callback(lua, "luaSpriteMakeGraphic", function(tag:String, width:Int, height:Int, color:String) {
			deprecated('luaSpriteMakeGraphic', 'makeGraphic');
			if(PlayState.instance.modchartSprites.exists(tag)) {
				var colorNum:Int = Std.parseInt(color);
				if(!color.startsWith('0x')) colorNum = Std.parseInt('0xff' + color);

				PlayState.instance.modchartSprites.get(tag).makeGraphic(width, height, colorNum);
			}
		});
		Lua_helper.add_callback(lua, "luaSpriteAddAnimationByPrefix", function(tag:String, name:String, prefix:String, framerate:Int = 24, loop:Bool = true) {
			deprecated('luaSpriteAddAnimationByPrefix', 'addAnimationByPrefix');
			if(PlayState.instance.modchartSprites.exists(tag)) {
				var cock:ModchartSprite = PlayState.instance.modchartSprites.get(tag);
				cock.animation.addByPrefix(name, prefix, framerate, loop);
				if(cock.animation.curAnim == null)
					cock.animation.play(name, true);
			}
		});
		Lua_helper.add_callback(lua, "luaSpriteAddAnimationByIndices", function(tag:String, name:String, prefix:String, indices:String, framerate:Int = 24) {
			deprecated('luaSpriteAddAnimationByIndices', 'addAnimationByIndices');
			if(PlayState.instance.modchartSprites.exists(tag)) {
				var strIndices:Array<String> = indices.trim().split(',');
				var die:Array<Int> = [];
				for (i in 0...strIndices.length) {
					die.push(Std.parseInt(strIndices[i]));
				}
				var pussy:ModchartSprite = PlayState.instance.modchartSprites.get(tag);
				pussy.animation.addByIndices(name, prefix, die, '', framerate, false);
				if(pussy.animation.curAnim == null)
					pussy.animation.play(name, true);
			}
		});
		Lua_helper.add_callback(lua, "luaSpritePlayAnimation", function(tag:String, name:String, forced:Bool = false) {
			deprecated('luaSpritePlayAnimation', 'objectPlayAnimation');
			if(PlayState.instance.modchartSprites.exists(tag)) {
				PlayState.instance.modchartSprites.get(tag).animation.play(name, forced);
				return true;
			}
			return false;
		});
		Lua_helper.add_callback(lua, "setLuaSpriteCamera", function(tag:String, camera:String = '') {
			deprecated('setLuaSpriteCamera', 'setObjectCamera');
			if(PlayState.instance.modchartSprites.exists(tag)) {
				PlayState.instance.modchartSprites.get(tag).cameras = [cameraFromString(camera)];
				return true;
			}
			traceLuaError("Lua sprite with tag: " + tag + " doesn't exist!");
			return false;
		});
		Lua_helper.add_callback(lua, "setLuaSpriteScrollFactor", function(tag:String, scrollX:Float, scrollY:Float) {
			deprecated("setLuaSpriteScrollFactor", "setScrollFactor");
			if(PlayState.instance.modchartSprites.exists(tag)) {
				PlayState.instance.modchartSprites.get(tag).scrollFactor.set(scrollX, scrollY);
				return true;
			}
			return false;
		});
		Lua_helper.add_callback(lua, "scaleLuaSprite", function(tag:String, x:Float, y:Float) {
			deprecated("scaleLuaSprite", "scaleObject");
			if(PlayState.instance.modchartSprites.exists(tag)) {
				var shit:ModchartSprite = PlayState.instance.modchartSprites.get(tag);
				shit.scale.set(x, y);
				shit.updateHitbox();
				return true;
			}
			return false;
		});
		Lua_helper.add_callback(lua, "getPropertyLuaSprite", function(tag:String, variable:String) {
			deprecated("getPropertyLuaSprite", 'getProperty');
			if(PlayState.instance.modchartSprites.exists(tag)) {
				var killMe:Array<String> = variable.split('.');
				if(killMe.length > 1) {
					var coverMeInPiss:Dynamic = Reflect.getProperty(PlayState.instance.modchartSprites.get(tag), killMe[0]);
					for (i in 1...killMe.length-1) {
						coverMeInPiss = Reflect.getProperty(coverMeInPiss, killMe[i]);
					}
					return Reflect.getProperty(coverMeInPiss, killMe[killMe.length-1]);
				}
				return Reflect.getProperty(PlayState.instance.modchartSprites.get(tag), variable);
			}
			return null;
		});
		Lua_helper.add_callback(lua, "setPropertyLuaSprite", function(tag:String, variable:String, value:Dynamic) {
			deprecated('setPropertyLuaSprite', 'setProperty');
			if(PlayState.instance.modchartSprites.exists(tag)) {
				var killMe:Array<String> = variable.split('.');
				if(killMe.length > 1) {
					var coverMeInPiss:Dynamic = Reflect.getProperty(PlayState.instance.modchartSprites.get(tag), killMe[0]);
					for (i in 1...killMe.length-1) {
						coverMeInPiss = Reflect.getProperty(coverMeInPiss, killMe[i]);
					}
					return Reflect.setProperty(coverMeInPiss, killMe[killMe.length-1], value);
				}
				return Reflect.setProperty(PlayState.instance.modchartSprites.get(tag), variable, value);
			}
			traceLuaError('Lua sprite with tag: "$tag" ' + "doesn't exist!");
		});
		Lua_helper.add_callback(lua, "musicFadeIn", function(duration:Float, fromValue:Float = 0, toValue:Float = 1) {
			FlxG.sound.music.fadeIn(duration, fromValue, toValue);
			deprecated('musicFadeIn', 'soundFadeIn');

		});
		Lua_helper.add_callback(lua, "musicFadeOut", function(duration:Float, toValue:Float = 0) {
			FlxG.sound.music.fadeOut(duration, toValue);
			deprecated('musicFadeOut', 'soundFadeOut');
		});
		// Other stuff
		Lua_helper.add_callback(lua, "stringStartsWith", function(str:String, start:String) {
			return str.startsWith(start);
		});
		Lua_helper.add_callback(lua, "stringEndsWith", function(str:String, end:String) {
			return str.endsWith(end);
		});
		Lua_helper.add_callback(lua, "length", function(str:String) {
			return str.length;
		});
		Lua_helper.add_callback(lua, "ltrim", function(str:String) {
			return str.ltrim();
		});
		Lua_helper.add_callback(lua, "rtrim", function(str:String) {
			return str.rtrim();
		});
		Lua_helper.add_callback(lua, "trim", function(str:String) {
			return str.trim();
		});
		Lua_helper.add_callback(lua, "replace", function(str:String, sub:String = ' ', by:String = '') {
			return str.replace(sub, by);
		});
		Lua_helper.add_callback(lua, "isSpace", function(str:String, pos:Int = 0) {
			return str.isSpace(pos);
		});
		Lua_helper.add_callback(lua, "htmlEscape", function(str:String, ?quotes:Bool) {
			return str.htmlEscape(quotes);
		});
		Lua_helper.add_callback(lua, "hex", function(number:Int, ?digits:Int) {
			return StringTools.hex(number, digits);
		});

		// shaders
		Lua_helper.add_callback(lua, "chromaticEffect", function(camera:String, chromeOffset:Float = 0.005) {
			if (ClientPrefs.shaders)
				PlayState.instance.addShaderToCamera(camera, new ChromaticAberrationEffect(chromeOffset));

		});
		Lua_helper.add_callback(lua, "scanlineEffect", function(camera:String, lockAlpha:Bool = false) {
			if (ClientPrefs.shaders)
				PlayState.instance.addShaderToCamera(camera, new ScanlineEffect(lockAlpha));
			
		});
		Lua_helper.add_callback(lua, "grainEffect", function(camera:String, grainSize:Float, lumAmount:Float, lockAlpha:Bool = false) {
			if (ClientPrefs.shaders)
				PlayState.instance.addShaderToCamera(camera, new GrainEffect(grainSize, lumAmount, lockAlpha));
			
		});
		Lua_helper.add_callback(lua, "tiltshiftEffect", function(camera:String, blurAmount:Float, center:Float) {
			if (ClientPrefs.shaders)
				PlayState.instance.addShaderToCamera(camera, new TiltshiftEffect(blurAmount, center));

		});
		Lua_helper.add_callback(lua, "vcrEffect", function(camera:String,glitchFactor:Float = 0.0, distortion:Bool = true, perspectiveOn:Bool = true, vignetteMoving:Bool = true) {
			if (ClientPrefs.shaders)
				PlayState.instance.addShaderToCamera(camera, new VCRDistortionEffect(glitchFactor, distortion, perspectiveOn, vignetteMoving));
			
		});
		Lua_helper.add_callback(lua, "fuckinDaveAndBambi1", function(camera:String,waveSpeed:Float = 0.1, waveFrq:Float = 0.1, waveAmp:Float = 0.1) {
			if (ClientPrefs.shaders)
				PlayState.instance.addShaderToCamera(camera, new GlitchEffect(waveSpeed, waveFrq, waveAmp));
			
		});
		Lua_helper.add_callback(lua, "fuckinDaveAndBambi2", function(camera:String, waveSpeed:Float = 0.1, waveFrq:Float = 0.1, waveAmp:Float = 0.1) {
			if (ClientPrefs.shaders)
				PlayState.instance.addShaderToCamera(camera, new PulseEffect(waveSpeed, waveFrq, waveAmp));
			
		});
		Lua_helper.add_callback(lua, "fuckinDaveAndBambi3", function(camera:String, waveSpeed:Float = 0.1, waveFrq:Float = 0.1, waveAmp:Float = 0.1) {
			if (ClientPrefs.shaders)
				PlayState.instance.addShaderToCamera(camera, new DistortBGEffect(waveSpeed, waveFrq, waveAmp));
			
		});
		Lua_helper.add_callback(lua, "glitchEffect", function(camera:String,waveSpeed:Float = 0.1, waveFrq:Float = 0.1, waveAmp:Float = 0.1) {
			if (ClientPrefs.shaders)
				PlayState.instance.addShaderToCamera(camera, new GlitchEffect(waveSpeed, waveFrq, waveAmp));
			
		});
		Lua_helper.add_callback(lua, "pulseEffect", function(camera:String, waveSpeed:Float = 0.1, waveFrq:Float = 0.1, waveAmp:Float = 0.1) {
			if (ClientPrefs.shaders)
				PlayState.instance.addShaderToCamera(camera, new PulseEffect(waveSpeed, waveFrq, waveAmp));
			
		});
		Lua_helper.add_callback(lua, "distortBGEffect", function(camera:String, waveSpeed:Float = 0.1, waveFrq:Float = 0.1, waveAmp:Float = 0.1) {
			if (ClientPrefs.shaders)
				PlayState.instance.addShaderToCamera(camera, new DistortBGEffect(waveSpeed, waveFrq, waveAmp));
			
		});
		Lua_helper.add_callback(lua, "invertColors", function(camera:String, lockAlpha:Bool = false) {
			if (ClientPrefs.shaders)
				PlayState.instance.addShaderToCamera(camera, new InvertColorsEffect(lockAlpha));
			
		});
		Lua_helper.add_callback(lua, "greyscaleEffect1", function(camera:String) { //for dem funkies
			if (ClientPrefs.shaders)
				PlayState.instance.addShaderToCamera(camera, new GreyscaleEffect());
			
		});
		Lua_helper.add_callback(lua, "greyscaleEffect2", function(camera:String) { //for dem funkies
			if (ClientPrefs.shaders)
				PlayState.instance.addShaderToCamera(camera, new GreyscaleEffect());
			
		});
		Lua_helper.add_callback(lua, "3DEffect", function(camera:String, xrotation:Float = 0, yrotation:Float = 0, zrotation:Float = 0, depth:Float = 0) { //for dem funkies
			if (ClientPrefs.shaders)
				PlayState.instance.addShaderToCamera(camera, new ThreeDEffect(xrotation, yrotation, zrotation, depth));
			
		});
		Lua_helper.add_callback(lua, "bloomEffect", function(camera:String, intensity:Float = 0.35, blurSize:Float = 1.0) {
			if (ClientPrefs.shaders)
				PlayState.instance.addShaderToCamera(camera, new BloomEffect(blurSize/512.0, intensity));
			
		});
		Lua_helper.add_callback(lua, "killShaders", function(camera:String) {
			PlayState.instance.clearShaderFromCamera(camera);
		});

		call('onCreate', []);
		#else
		lol();
		#end
	}

	public static function setVarInArray(instance:Dynamic, variable:String, value:Dynamic):Any
	{
		var shit:Array<String> = variable.split('[');
		if(shit.length > 1)
		{
			var blah:Dynamic = Reflect.getProperty(instance, shit[0]);
			for (i in 1...shit.length)
			{
				var leNum:Dynamic = shit[i].substr(0, shit[i].length - 1);
				if(i >= shit.length-1) //Last array
					blah[leNum] = value;
				else //Anything else
					blah = blah[leNum];
			}
			return blah;
		}
		/*if(Std.isOfType(instance, Map))
 			instance.set(variable,value);
 		else*/
 		switch(Type.typeof(instance)) {
 			case ValueType.TClass(haxe.ds.StringMap) | ValueType.TClass(haxe.ds.ObjectMap) | ValueType.TClass(haxe.ds.IntMap) | ValueType.TClass(haxe.ds.EnumValueMap):
 				instance.set(variable, value);
 			default:
 				Reflect.setProperty(instance, variable, value);
 		};



		return true;
	}
	public static function getVarInArray(instance:Dynamic, variable:String):Any
	{
		var shit:Array<String> = variable.split('[');
		if(shit.length > 1)
		{
			var blah:Dynamic = Reflect.getProperty(instance, shit[0]);
			for (i in 1...shit.length)
			{
				var leNum:Dynamic = shit[i].substr(0, shit[i].length - 1);
				blah = blah[leNum];
			}
			return blah;
		}
		switch(Type.typeof(instance)) {
 			case ValueType.TClass(haxe.ds.StringMap) | ValueType.TClass(haxe.ds.ObjectMap) | ValueType.TClass(haxe.ds.IntMap) | ValueType.TClass(haxe.ds.EnumValueMap):
 				return instance.get(variable);
 			default:
 				return Reflect.getProperty(instance, variable);
 		};
	}

	inline static function getTextObject(name:String):FlxText
	{
		return PlayState.instance.modchartTexts.exists(name) ? PlayState.instance.modchartTexts.get(name) : Reflect.getProperty(PlayState.instance, name);
	}

	function getGroupStuff(leArray:Dynamic, variable:String) {
		var killMe:Array<String> = variable.split('.');
		if(killMe.length > 1) {
			var coverMeInPiss:Dynamic = Reflect.getProperty(leArray, killMe[0]);
			for (i in 1...killMe.length-1) {
				coverMeInPiss = Reflect.getProperty(coverMeInPiss, killMe[i]);
			}
			switch(Type.typeof(coverMeInPiss)) {
 				case ValueType.TClass(haxe.ds.StringMap) | ValueType.TClass(haxe.ds.ObjectMap) | ValueType.TClass(haxe.ds.IntMap) | ValueType.TClass(haxe.ds.EnumValueMap):
 					return coverMeInPiss.get(killMe[killMe.length-1]);
 				default:
 					return Reflect.getProperty(coverMeInPiss, killMe[killMe.length-1]);
 			}
		}
		switch(Type.typeof(leArray)) {
 			case ValueType.TClass(haxe.ds.StringMap) | ValueType.TClass(haxe.ds.ObjectMap) | ValueType.TClass(haxe.ds.IntMap) | ValueType.TClass(haxe.ds.EnumValueMap):
 				return leArray.get(variable);
 			default:
 				return Reflect.getProperty(leArray, variable);
 		}
	}

	function loadFrames(spr:FlxSprite, image:String, spriteType:String)
	{
		switch(spriteType.toLowerCase().trim())
		{
			case "texture" | "textureatlas" | "tex":
				spr.frames = AtlasFrameMaker.construct(image);

			case "texture_noaa" | "textureatlas_noaa" | "tex_noaa" | "noaa":
				spr.frames = AtlasFrameMaker.construct(image, null, true);

			case "packer" | "packeratlas" | "pac":
				spr.frames = Paths.getPackerAtlas(image);

			default:
				spr.frames = Paths.getSparrowAtlas(image);
		}
	}

	function setGroupStuff(leArray:Dynamic, variable:String, value:Dynamic) {
		var killMe:Array<String> = variable.split('.');
		if(killMe.length > 1) {
			var coverMeInPiss:Dynamic = Reflect.getProperty(leArray, killMe[0]);
			for (i in 1...killMe.length-1) {
				coverMeInPiss = Reflect.getProperty(coverMeInPiss, killMe[i]);
			}
			Reflect.setProperty(coverMeInPiss, killMe[killMe.length-1], value);
			return;
		}
		Reflect.setProperty(leArray, variable, value);
	}

	function resetTextTag(tag:String) {
		if(!PlayState.instance.modchartTexts.exists(tag))
			return;


		var pee:ModchartText = PlayState.instance.modchartTexts.get(tag);
		pee.kill();
		if(pee.wasAdded)
			PlayState.instance.remove(pee, true);

		pee.destroy();
		PlayState.instance.modchartTexts.remove(tag);
	}

	function resetSpriteTag(tag:String) {
		if(!PlayState.instance.modchartSprites.exists(tag)) {
			return;
		}

		var pee:ModchartSprite = PlayState.instance.modchartSprites.get(tag);
		pee.kill();
		if(pee.wasAdded) {
			PlayState.instance.remove(pee, true);
		}
		pee.destroy();
		PlayState.instance.modchartSprites.remove(tag);
	}

	function cancelTween(tag:String) {
		var tagger:String = if(PlayState.instance.modchartTweens.exists(tag)) tag else if(PlayState.instance.modchartTweens.exists(tag.toLowerCase())) tag.toLowerCase() else 'nope';
		if(tagger != 'nope') {
			PlayState.instance.modchartTweens.get(tagger).cancel();
			PlayState.instance.modchartTweens.get(tagger).destroy();
			PlayState.instance.modchartTweens.remove(tagger);
		}
	}
	
	function tweenShit(tag:String, vars:String) {
		cancelTween(tag);
		var variables:Array<String> = vars.split('.');
 		var sexyProp:Dynamic = getObjectDirectly(variables[0]);
 		if(variables.length > 1) {
 			sexyProp = getVarInArray(getPropertyLoopThingWhatever(variables), variables[variables.length-1]);
		}
		return sexyProp;
	}

	function cancelTimer(tag:String) {
		var tagger:String = if(PlayState.instance.modchartTimers.exists(tag)) tag else if(PlayState.instance.modchartTimers.exists(tag.toLowerCase())) tag.toLowerCase() else 'nope';
		if(tagger != 'nope') {
			var theTimer:FlxTimer = PlayState.instance.modchartTimers.get(tagger);
			theTimer.cancel();
			theTimer.destroy();
			PlayState.instance.modchartTimers.remove(tagger);
		}
	}

	//Better optimized than using some getProperty shit or idk
	function getFlxEaseByString(?ease:String = '') {
		switch(ease.toLowerCase().trim()) {
			case 'backin': return FlxEase.backIn;
			case 'backinout': return FlxEase.backInOut;
			case 'backout': return FlxEase.backOut;
			case 'bouncein': return FlxEase.bounceIn;
			case 'bounceinout': return FlxEase.bounceInOut;
			case 'bounceout': return FlxEase.bounceOut;
			case 'circin': return FlxEase.circIn;
			case 'circinout': return FlxEase.circInOut;
			case 'circout': return FlxEase.circOut;
			case 'cubein': return FlxEase.cubeIn;
			case 'cubeinout': return FlxEase.cubeInOut;
			case 'cubeout': return FlxEase.cubeOut;
			case 'elasticin': return FlxEase.elasticIn;
			case 'elasticinout': return FlxEase.elasticInOut;
			case 'elasticout': return FlxEase.elasticOut;
			case 'expoin': return FlxEase.expoIn;
			case 'expoinout': return FlxEase.expoInOut;
			case 'expoout': return FlxEase.expoOut;
			case 'quadin': return FlxEase.quadIn;
			case 'quadinout': return FlxEase.quadInOut;
			case 'quadout': return FlxEase.quadOut;
			case 'quartin': return FlxEase.quartIn;
			case 'quartinout': return FlxEase.quartInOut;
			case 'quartout': return FlxEase.quartOut;
			case 'quintin': return FlxEase.quintIn;
			case 'quintinout': return FlxEase.quintInOut;
			case 'quintout': return FlxEase.quintOut;
			case 'sinein': return FlxEase.sineIn;
			case 'sineinout': return FlxEase.sineInOut;
			case 'sineout': return FlxEase.sineOut;
			case 'smoothstepin': return FlxEase.smoothStepIn;
			case 'smoothstepinout': return FlxEase.smoothStepInOut;
			case 'smoothstepout': return FlxEase.smoothStepInOut;
			case 'smootherstepin': return FlxEase.smootherStepIn;
			case 'smootherstepinout': return FlxEase.smootherStepInOut;
			case 'smootherstepout': return FlxEase.smootherStepOut;
		}
		return FlxEase.linear;
	}

	function blendModeFromString(blend:String):BlendMode {
		switch(blend.toLowerCase().trim()) {
			case 'add': return ADD;
			case 'alpha': return ALPHA;
			case 'darken': return DARKEN;
			case 'difference': return DIFFERENCE;
			case 'erase': return ERASE;
			case 'hardlight': return HARDLIGHT;
			case 'invert': return INVERT;
			case 'layer': return LAYER;
			case 'lighten': return LIGHTEN;
			case 'multiply': return MULTIPLY;
			case 'overlay': return OVERLAY;
			case 'screen': return SCREEN;
			case 'shader': return SHADER;
			case 'subtract': return SUBTRACT;
		}
		return NORMAL;
	}

	function cameraFromString(cam:String):FlxCamera {
		switch(cam.toLowerCase().replace('-', '').trim()) {
			case 'camhud' | 'hud': return PlayState.instance.camHUD;
			case 'camother' | 'other': return PlayState.instance.camOther;
		}
		return PlayState.instance.camGame;
	}

	public function luaTrace(text:String, ignoreCheck:Bool = false, deprecated:Bool = false, color:Dynamic = 'white') {
		#if LUA_ALLOWED
		var colorr:FlxColor = FlxColor.WHITE;
		var colorStuff:Array<Array<Dynamic>> = [
			['red', FlxColor.RED],
			['blue', FlxColor.BLUE],
			['black', FlxColor.BLACK],
			['brown', FlxColor.BROWN],
			['cyan', FlxColor.CYAN],
			['gray', FlxColor.GRAY],
			['green', FlxColor.GREEN],
			['lime', FlxColor.LIME],
			['yellow', FlxColor.YELLOW],
			['transparent', FlxColor.TRANSPARENT],
			['white', FlxColor.WHITE]
		];
		if(color is String) {
			for (i in 0...colorStuff.length) {
				if(colorStuff[i][0].toLowerCase().trim().replace('-', '') == color.toLowerCase().trim().replace('-', '')) {
					colorr = colorStuff[i][1];
				}
			}
		} else if(color is FlxColor) {
			colorr = color;
		}
		if(ignoreCheck || getBool('luaDebugMode')) {
			if(deprecated && !getBool('luaDeprecatedWarnings')) {
				return;
			}
			PlayState.instance.addTextToDebug(text, colorr);
			trace(text);
		}
		#else
		lol();
		#end
	}
	public function traceLuaError(text:String) {
		luaTrace(text, false, false, 'red');
	}
	/*public function call(event:String, args:Array<Dynamic>):Dynamic {
		#if LUA_ALLOWED
		if(lua == null) {
			return Function_Continue;
		}

		Lua.getglobal(lua, event);

		for (arg in args) {
			Convert.toLua(lua, arg);
		}

		var result:Null<Int> = Lua.pcall(lua, args.length, 1, 0);
		if(result != null && resultIsAllowed(lua, result)) {
			if(Lua.type(lua, -1) == Lua.LUA_TSTRING) {
				var error:String = Lua.tostring(lua, -1);
				Lua.pop(lua, 1);
				if(error == 'attempt to call a nil value') { //Makes it ignore warnings and not break stuff if you didn't put the functions on your lua file
					return Function_Continue;
				}
			}

			var conv:Dynamic = Convert.fromLua(lua, result);
			return conv;
		}
		#else
		lol();
		#end
		return Function_Continue;
		}*/

 	function getErrorMessage() {
		#if LUA_ALLOWED
		var v:String = Lua.tostring(lua, -1);
		Lua.pop(lua, 1);
		return v;
		#end
 	}

 	public function call(func:String, args:Array<Dynamic>): Dynamic{
 		#if LUA_ALLOWED
 		try {
 			if(lua == null) return Function_Continue;
 			Lua.getglobal(lua, func);

 			if(Lua.isfunction(lua, -1) == #if (linc_luajit >= "0.0.6") true #else 1 #end )
 			{

 				for(arg in args) Convert.toLua(lua, arg);
 				var result: Dynamic = Lua.pcall(lua, args.length, 1, 0);
 				if(result != 0) {
 					var err = getErrorMessage();
 					if(errorHandler != null) {
 						errorHandler(err);
 					} else {
 						luaTrace("ERROR: " + err, false, false, FlxColor.RED);
 					}
					//LuaL.error(state,err);

					Lua.pop(lua, 1);
 					return Function_Continue;

 				} else {
 					var conv:Dynamic = Convert.fromLua(lua, -1);
 					Lua.pop(lua, 1);
					if(conv == null) conv = Function_Continue;
 					return conv;
 				}
			} else {
 				Lua.pop(lua, 1);
 				return Function_Continue;
 			}

 		}
		catch(e:Dynamic) {
 			trace(e);
 		}
		#else
		lol();
 		#end
 		return Function_Continue;

 	}

	public static function getPropertyLoopThingWhatever(killMe:Array<String>, ?checkForTextsToo:Bool = true, ?getProperty:Bool=true):Dynamic
	{
		var coverMeInPiss:Dynamic = getObjectDirectly(killMe[0], checkForTextsToo);
		var end = killMe.length;
		if(getProperty) end = killMe.length-1;

		for (i in 1...end) {
			coverMeInPiss = getVarInArray(coverMeInPiss, killMe[i]);
		}
		return coverMeInPiss;
	}

	public static function getObjectDirectly(objectName:String, ?checkForTextsToo:Bool = true):Dynamic
	{
		var coverMeInPiss:Dynamic = PlayState.instance.getLuaObject(objectName, checkForTextsToo);
		if(coverMeInPiss == null)
			coverMeInPiss = getVarInArray(getInstance(), objectName);

		return coverMeInPiss;
	}

	#if LUA_ALLOWED
	function resultIsAllowed(leLua:State, leResult:Null<Int>) { //Makes it ignore warnings
		switch(Lua.type(leLua, leResult)) {
			case Lua.LUA_TNIL | Lua.LUA_TBOOLEAN | Lua.LUA_TNUMBER | Lua.LUA_TSTRING | Lua.LUA_TTABLE:
				return true;
		}
		return false;
	}
	#end

	public function set(variable:String, data:Dynamic) {
		#if LUA_ALLOWED
		if(lua == null) {
			return;
		}

		Convert.toLua(lua, data);
		Lua.setglobal(lua, variable);
		Lua.setglobal(lua, variable.toLowerCase());
		#else
		lol();
		#end
	}

	public function getBool(variable:String) {
		#if LUA_ALLOWED
		var result:String = null;
		Lua.getglobal(lua, variable);
		result = Convert.fromLua(lua, -1);
		Lua.pop(lua, 1);

		if(result == null) {
			return false;
		}

		// YES! FINALLY IT WORKS
		//trace('variable: ' + variable + ', ' + result);
		return (result == 'true');
		#else
		lol();
		return null;
		#end
	}

	public function stop() {
		#if LUA_ALLOWED
		if(lua == null) {
			return;
		}

		if(accessedProps != null) {
			accessedProps.clear();
		}

		Lua.close(lua);
		lua = null;
		#else
		lol();
		#end
	}

	public static inline function getInstance()
	{
		return PlayState.instance.isDead ? GameOverSubstate.instance : PlayState.instance;
	}
	static inline var CLENSE:String = "
		os.getenv = nil;

		os.execute = nil;
		os.makedir = nil;
		os.makedirs =nil;
		require = nil;
		package.loaded.require = nil;
		package.preload.require = nil;
		ffi = nil;
		package.loaded.ffi = nil;
		package.preload.ffi = nil;

	";
}

class ModchartSprite extends FlxSprite
{
	public var wasAdded:Bool = false;
	//public var isInFront:Bool = false;

	public function new(?x:Float = 0, ?y:Float = 0)
	{
		super(x, y);
		antialiasing = ClientPrefs.globalAntialiasing;
	}
}

class ModchartText extends FlxText
{
	public var wasAdded:Bool = false;
	public function new(x:Float, y:Float, text:String, width:Float, color:FlxColor = FlxColor.WHITE, alignment:FlxTextAlign = CENTER, borderColor:FlxColor = FlxColor.BLACK)
	{
		super(x, y, width, text, 16);
		setFormat(Paths.font("vcr.ttf"), 16, color, alignment, FlxTextBorderStyle.OUTLINE, borderColor);
		cameras = [PlayState.instance.camHUD];
		scrollFactor.set();
		borderSize = 2;
	}
}

class DebugLuaText extends FlxText
{
	private var disableTime:Float = 6;
	public var parentGroup:FlxTypedGroup<DebugLuaText>; 
	public function new(text:String, parentGroup:FlxTypedGroup<DebugLuaText>, color:FlxColor = FlxColor.WHITE, borderStyle:FlxTextBorderStyle = FlxTextBorderStyle.OUTLINE, borderColor:FlxColor = FlxColor.BLACK) {
		this.parentGroup = parentGroup;
		super(10, 10, 0, text, 16);
		setFormat(Paths.font("vcr.ttf"), 20, color, LEFT, borderStyle, borderColor);
		scrollFactor.set();
		borderSize = 1;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		disableTime -= elapsed;
		if(disableTime <= 0) {
			kill();
			parentGroup.remove(this);
			destroy();
		}
		else if(disableTime < 1) alpha = disableTime;
	}
	
}
