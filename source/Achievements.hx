import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import flixel.text.FlxText;
#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end
import haxe.Json;
import lime.utils.Assets;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

typedef AchievementFile =
{
	var unlocksAfter:String;
	var icon:String; // this is also used for the "Achievement save tag", so use "_" instead of SPACES
	var name:String;
	var description:String;
	var hidden:Bool;
	var customGoal:Bool;
	// var alpha:Array<Float>; // default is [0.6, 1]
	// var color:Dynamic; // i will add them -Wither
}

class Achievements {

	/**
	 * Write `null` in the `Unlocks After` to hardcode the achievement!
	 * The code should be in `PlayState.hx`!
	 */
	public static var achievementShits:Array<Dynamic> = [//Name, Description, Achievement save tag, Unlocks after, Hidden achievement, alpha (array)
		["Freaky on a Friday Night",			"Play on a Friday... Night.",					'friday_night_play',	 		null, 			true],
		["She Calls Me Daddy Too",			"Beat Week 1 on Hard with no Misses.",				'week1_nomiss',				null, 			false],
		["No More Tricks",				"Beat Week 2 on Hard with no Misses.",				'week2_nomiss',        			null, 			false],
		["Call Me The Hitman",				"Beat Week 3 on Hard with no Misses.",				'week3_nomiss',				null, 			false],
		["Lady Killer",					"Beat Week 4 on Hard with no Misses.",				'week4_nomiss',				null, 			false],
		["Missless Christmas",				"Beat Week 5 on Hard with no Misses.",				'week5_nomiss',				null,			false],
		["Highscore!!",					"Beat Week 6 on Hard with no Misses.",				'week6_nomiss',				null,			false],
		["God Effing Damn It!",				"Beat Week 7 with no Misses.",					'week7_nomiss',				null,			false], 
		["What a Funkin' Disaster!",			"Complete a Song with a rating lower than 20%.",		'ur_bad',				null, 			false],
		["Perfectionist",				"Complete a Song with a rating of 100%.",			'ur_good',				null,			false],
		["Roadkill Enthusiast",				"Watch the Henchmen die over 100 times.",			'roadkill_enthusiast',			null, 			false],
		["Oversinging Much...?",			"Hold down a note for 10 seconds.",				'oversinging',				null,			false],
		["Hyperactive",					"Finish a Song without going Idle.",				'hype',					null, 			false],
		["Just the Two of Us",				"Finish a Song pressing only two keys.",			'two_keys',				null,			false],
		["Toaster Gamer",				"Have you tried to run the game on a toaster?",			'toastie',				null,			false],
		["Debugger",					"Beat the \"Test\" Stage from the Chart Editor.",		'debugger',				null,			true],
		["Not Freaky on a Friday Night",		"Play on a Saturday... Night?",				'saturday_night_play',			null,			true]
	];

	/**
	 * Gets filled when loading achievements
	 */
	public static var achievementsStuff:Array<Dynamic> = [];

	public static var achievementsMap:Map<String, Bool> = new Map<String, Bool>();
	public static var loadedAchievements:Map<String, AchievementFile> = new Map<String, AchievementFile>();

	public static var henchmenDeath:Int = 0;
	public static function unlockAchievement(name:String):Void {
		FlxG.log.add('Completed achievement "$name"');
		achievementsMap.set(name, true);
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
	}

	public static function isAchievementUnlocked(name:String) {
		if(achievementsMap.exists(name)) {
			return achievementsMap.get(name);
		}
		return false;
	}

	public static function getAchievementIndex(name:String) {
		for (i in 0...achievementsStuff.length) {
			if(achievementsStuff[i][2] == name) {
				return i;
			}
		}
		return -1;
	}

	public static function loadAchievements():Void {
		achievementsStuff = [];
		achievementsStuff = achievementShits;

		#if MODS_ALLOWED
		reloadAchievements();
		#end

		if(FlxG.save.data != null) {
			if(FlxG.save.data.achievementsMap != null) {
				achievementsMap = FlxG.save.data.achievementsMap;
			}
			if(henchmenDeath == 0 && FlxG.save.data.henchmenDeath != null) {
				henchmenDeath = FlxG.save.data.henchmenDeath;
			}
		}
	}
	public static function reloadAchievements() { //Achievements in game are hardcoded, no need to make a folder for them -Wither: suck my balls!
		loadedAchievements.clear();

		#if MODS_ALLOWED //Based on WeekData.hx
		var disabledMods:Array<String> = [];
		var modsListPath:String = 'modsList.txt';
		var directories:Array<String> = [Paths.mods()];
		if(FileSystem.exists(modsListPath))
		{
			var stuff:Array<String> = CoolUtil.coolTextFile(modsListPath);
			for (i in 0...stuff.length)
			{
				var splitName:Array<String> = stuff[i].trim().split('|');
				if(splitName[1] == '0') // Disable mod
					disabledMods.push(splitName[0]);
				else // Sort mod loading order based on modsList.txt file
				{
					var path = haxe.io.Path.join([Paths.mods(), splitName[0]]);
					//trace('trying to push: ' + splitName[0]);
					if (FileSystem.isDirectory(path) && !Paths.ignoreModFolders.contains(splitName[0]) && !disabledMods.contains(splitName[0]) && !directories.contains(path + '/'))
					{
						directories.push(path + '/');
						//trace('pushed Directory: ' + splitName[0]);
					}
				}
			}
		}

		var modsDirectories:Array<String> = Paths.getGlobalMods();
		for (folder in modsDirectories)
		{
			var pathThing:String = haxe.io.Path.join([Paths.mods(), folder]) + '/';
			if (!disabledMods.contains(folder) && !directories.contains(pathThing))
			{
				directories.push(pathThing);
				//trace('pushed Directory: ' + folder);
			}
		}

		for (i in 0...directories.length) {
			var directory:String = directories[i] + 'achievements/';

			//trace(directory);
			if (FileSystem.exists(directory)) {
				var listOfAchievements:Array<String> = CoolUtil.coolTextFile((directory.endsWith('/') ? directory : directory + '/') + 'achievementList.txt');

				for (achievement in listOfAchievements) {
					var path:String = directory + achievement + '.json';

					if (FileSystem.exists(path) && !loadedAchievements.exists(achievement) && achievement != PlayState.othersCodeName) {
						loadedAchievements.set(achievement, getAchievementInfo(path));
					}

					//trace(path);
				}

				for (file in FileSystem.readDirectory(directory)) {
					var path = haxe.io.Path.join([directory, file]);

					var cutName:String = file.substr(0, file.length - 5);
					if (!FileSystem.isDirectory(path) && file.endsWith('.json') && !loadedAchievements.exists(cutName) && cutName != PlayState.othersCodeName) {
						loadedAchievements.set(cutName, getAchievementInfo(path));
					}

					//trace(file);
				}
			}
		}

		for (json in loadedAchievements) {
			if(achievementsStuff.contains([json.name, json.description, json.icon, json.unlocksAfter, json.hidden])) continue; // skip this
			//trace(json);
			var pushIt:Bool = true; // fixes duplication bug
			for (thisAchievement in achievementsStuff) {
				if(thisAchievement[0] == json.name || thisAchievement[2] == json.icon || achievementsStuff.contains([json.name, json.description, json.icon, json.unlocksAfter, json.hidden])) {
					pushIt = false;
					break; // breaks the loop
				}
			}
			if(pushIt) achievementsStuff.push([json.name, json.description, json.icon, json.unlocksAfter, json.hidden]);
		}
		#end
	}

	private static function getAchievementInfo(path:String):AchievementFile {
		var rawJson:String = null;
		#if MODS_ALLOWED
		if (FileSystem.exists(path)) {
			rawJson = File.getContent(path);
		}
		#else
		if(OpenFlAssets.exists(path)) {
			rawJson = Assets.getText(path);
		}
		#end

		if(rawJson != null && rawJson.length > 0) {
			return cast Json.parse(rawJson);
		}
		return null;
	}
}

class AttachedAchievement extends FlxSprite {
	public var sprTracker:FlxSprite;
	private var tag:String;
	public function new(x:Float = 0, y:Float = 0, name:String) {
		super(x, y);

		changeAchievement(name);
		antialiasing = ClientPrefs.globalAntialiasing;
	}

	public function changeAchievement(tag:String) {
		this.tag = tag;
		reloadAchievementImage();
	}

	public function forget() // from BeastlyGhost
 	{
 		if (Achievements.isAchievementUnlocked(tag) && FlxG.save.data.achievementsMap)
 		{
 			var savedStuff:Map<String, String> = FlxG.save.data.achievementsMap;
 			if (savedStuff.exists(tag))
 				savedStuff.remove(tag);
 			FlxG.save.data.achievementsMap = savedStuff;
 			loadGraphic(Paths.image('achievements/lockedachievement'));
		}
	}

	public function reloadAchievementImage() {
		var imagePath = Paths.image('achievements/$tag');

		if(Achievements.isAchievementUnlocked(tag)) {
			var isModIcon:Bool = false;

			if (Achievements.loadedAchievements.exists(tag)) {
				isModIcon = true;
				imagePath = Paths.image('achievements' + Achievements.loadedAchievements.get(tag).icon);
			}
			loadGraphic(imagePath);
		} else {
			loadGraphic(Paths.image('achievements/lockedachievement'));
		}

		scale.set(0.7, 0.7);
		updateHitbox();
	}

	override function update(elapsed:Float) {
		if (sprTracker != null)
			setPosition(sprTracker.x - 130, sprTracker.y + 25);

		super.update(elapsed);
	}
}

class AchievementObject extends FlxSpriteGroup {
	public var onFinish:Void->Void = null;
	var alphaTween:FlxTween;
	public function new(name:String, ?camera:FlxCamera = null)
	{
		super(x, y);
		ClientPrefs.saveSettings();

		var id:Int = Achievements.getAchievementIndex(name);
		var achieveName:String = Achievements.achievementsStuff[id][0];
		var text:String = Achievements.achievementsStuff[id][1];

		if(Achievements.loadedAchievements.exists(name)) {
			id = 0;
			achieveName = Achievements.loadedAchievements.get(name).name;
			text = Achievements.loadedAchievements.get(name).description;
		}
		var achievementBG:FlxSprite = new FlxSprite(60, 50).makeGraphic(420, 120, FlxColor.BLACK);
		achievementBG.scrollFactor.set();

		var imagePath = Paths.image('achievements/$name');
		var isModIcon:Bool = false;

		if (Achievements.loadedAchievements.exists(name)) {
			isModIcon = true;
			imagePath = Paths.image('achievements' + Achievements.loadedAchievements.get(name).icon);
		}

		var index:Int = Achievements.getAchievementIndex(name);
		if (isModIcon) index = 0;

		trace(imagePath);

		var achievementIcon:FlxSprite = new FlxSprite(achievementBG.x + 10, achievementBG.y + 10).loadGraphic(imagePath);
		achievementIcon.scrollFactor.set();
		achievementIcon.setGraphicSize(Std.int(achievementIcon.width * (2 / 3)));
		achievementIcon.updateHitbox();
		achievementIcon.antialiasing = ClientPrefs.globalAntialiasing;

		var achievementName:FlxText = new FlxText(achievementIcon.x + achievementIcon.width + 20, achievementIcon.y + 16, 280, achieveName, 16);
		achievementName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT);
		achievementName.scrollFactor.set();

		var achievementText:FlxText = new FlxText(achievementName.x, achievementName.y + 32, 280, text, 16);
		achievementText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT);
		achievementText.scrollFactor.set();

		add(achievementBG);
		add(achievementName);
		add(achievementText);
		add(achievementIcon);

		var cam:Array<FlxCamera> = FlxCamera.defaultCameras;
		if(camera != null) {
			cam = [camera];
		}
		alpha = 0;
		achievementBG.cameras = cam;
		achievementName.cameras = cam;
		achievementText.cameras = cam;
		achievementIcon.cameras = cam;
		alphaTween = FlxTween.tween(this, {alpha: 1}, 0.5, {onComplete: function (twn:FlxTween) {
			alphaTween = FlxTween.tween(this, {alpha: 0}, 0.5, {
				startDelay: 2.5,
				onComplete: function(twn:FlxTween) {
					alphaTween = null;
					remove(this);
					if(onFinish != null) onFinish();
				}
			});
		}});
	}

	override function destroy() {
		if(alphaTween != null) {
			alphaTween.cancel();
		}
		super.destroy();
	}
}
