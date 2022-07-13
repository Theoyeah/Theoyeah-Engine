package;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import Achievements;

using StringTools;

class AchievementsMenuState extends MusicBeatState
{
	#if ACHIEVEMENTS_ALLOWED
	var options:Array<String> = [];
	private var grpOptions:FlxTypedGroup<Alphabet>;
	private static var curSelected:Int = 0;
	private var achievementArray:Array<AttachedAchievement> = [];
	private var achievementIndex:Array<Int> = [];
	private var descText:FlxText;

	override function create() {
		#if desktop
		DiscordClient.changePresence("Achievements Menu", null);
		#end

		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBGBlue'));
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = ClientPrefs.globalAntialiasing;
		add(menuBG);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		Achievements.loadAchievements();
		for (i in 0...Achievements.achievementsStuff.length)
		{
			if ((!Achievements.achievementsStuff[i][4] || Achievements.achievementsStuff[i][4] == null)
				&& !options.contains(Achievements.achievementsStuff[i]) // fixes DUPLICATION BUG, now i have to find a way to implement the custom achievements... -Wither
			) {
				options.push(Achievements.achievementsStuff[i]);
				achievementIndex.push(i);
			}
		}

		for (i in 0...options.length)
		{
			if(options[i] == options[i+1] || options[i] == options[i-1]) {
				options.remove(options[i]); // i know this is stupid, but is better to delete all the copies
				continue;
			}
			var achieveName:String = Achievements.achievementsStuff[achievementIndex[i]][2];
			var optionText:Alphabet = new Alphabet(0, (100 * i) + 210,
				Achievements.isAchievementUnlocked(achieveName) ? Achievements.achievementsStuff[achievementIndex[i]][0] : '?',
				false, false);
			optionText.isMenuItem = true;
			optionText.x += 280;
			optionText.xAdd = 200;
			optionText.targetY = i;
			grpOptions.add(optionText);

			var icon:AttachedAchievement = new AttachedAchievement(optionText.x - 105, optionText.y, achieveName);
			icon.sprTracker = optionText;
			achievementArray.push(icon);
			add(icon);
		}

		descText = new FlxText(150, 600, 980, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.borderSize = 2.4;
		add(descText);

		var resetText:FlxText = new FlxText(0, 680, FlxG.width, "Press R to reset achievement/nPress ALT + R to reset all", 12);
 		resetText.borderSize = 2.5;
 		resetText.setFormat(Paths.font("vcr.ttf"), 28, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
 		resetText.scrollFactor.set();
 		add(resetText);

		changeSelection();

		super.create();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (controls.UI_UP_P  || FlxG.mouse.wheel > 0) {
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P  || FlxG.mouse.wheel < 0) {
			changeSelection(1);
		}

		if(controls.RESET) {
			if(FlxG.keys.pressed.ALT) {
				openSubState(new Prompt('This action will clear ALL the progress.\n\nProceed?', 0, function() {
					FlxG.sound.play(Paths.sound('confirmMenu'));
					for (i in 0...achievementArray.length) {
						achievementArray[i].forget();
						grpOptions.members[i].changeText('?');
					}
				}, function() {
					FlxG.sound.play(Paths.sound('confirmMenu'));
				}, false));
			} else {
				openSubState(new Prompt('This action will clear the progress of the selected achievement.\n\nProceed?', 0, function() {
					FlxG.sound.play(Paths.sound('confirmMenu'));
					achievementArray[curSelected].forget();
					grpOptions.members[curSelected].changeText('?');
				}, function() {
					FlxG.sound.play(Paths.sound('cancelMenu'));
				}, false));
			}
 		}

		if (controls.BACK) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}
	}

	function changeSelection(change:Int = 0) {
		curSelected += change;
		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpOptions.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			if (item.targetY == 0) {
				item.alpha = 1;
			}
		}

		for (i in 0...achievementArray.length) {
			achievementArray[i].alpha = 0.6;

			if(i == curSelected) {
				achievementArray[i].alpha = 1;
			}
		}
		descText.text = Achievements.achievementsStuff[achievementIndex[curSelected]][1];
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
	}
	#end
}
