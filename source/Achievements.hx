import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import flixel.text.FlxText;

using StringTools;

class Achievements {
	public static var achievementsStuff:Array<Dynamic> = if(ClientPrefs.language == 'spanish') 
		[ //Name, Description, Achievement save tag, Hidden achievement
		["Freaky on a Friday Night",	"Juega un Viernes por la... Noche.",						'friday_night_play',	 true],
		["Ella También Me Llama Daddy",		"Termina sin misses la Week 1",				'week1_nomiss',			false],
		["No Más Truco",				"Termina sin misses la Week 2",				'week2_nomiss',			false],
		['Llámame El Pistolero',			"Termina sin misses la Week 3",				'week3_nomiss',			false],
		["Dama Asesina",					"Termina sin misses la Week 4",				'week4_nomiss',			false],
		["Navidad Con Pocos Misses",			"Termina sin misses la Week 5",				'week5_nomiss',			false],
		["¡¡Highscore!!",					"Termina sin misses la Week 6",				'week6_nomiss',			false],
		["¡Maldita Sea, Maldita Sea!",		"Termina sin misses la Week 7",				'week7_nomiss',			 false], 
		["¡Qué Desastre Ritmítico!",	"Completa una Canción con una valoración de menos de 20%.",	'ur_bad',				false],
		["Perfeccionista",			   	  "Completa una Canción con una valoración del 100%.",			'ur_good',				false],
		["Estusiasmo Atropellista",		 "Mira a los Henchmen morir por 100 veces.",			'roadkill_enthusiast',	false],
		["¿Sobrecantando Mucho...?",   "Mantén pulsado una nota por 10 segundos.",					'oversinging',			false],
		["Hiperactivo",					"Completa una Canción sin dejar que se vea el Idle",				'hype',					false],
		["Solo Nosotros 2",		 "Completa una Canción con solo pulsando 2 notas.",			'two_keys',				false],
		["Gamer Tostador",			  "¿Has intentado jugar el juego en una tostadora?",		'toastie',				false],
		["Debugger",					"Completa la Canción \"Test\" desde el Chart Editor.",	'debugger',				 true],
		["Not Freaky on a Friday Night",	"Juega un... ¿Sábado por la Noche?",						'saturday_night_play',	 true]
	] else if (ClientPrefs.language == 'Francais') [
		["Freaky dans un vendredi soir",	"Jouer le vendredi... soir.",						'friday_night_play',	 true],
		["Elle m'appèlle papa aussi",		"Compléter Semaine 1 sans erreur.",				'week1_nomiss',			false],
		["Plus de blagues",				"Compléter Semaine 2 sans erreur.",				'week2_nomiss',			false],
		["Appèlle moi l'assasin",			"Compléter Semaine 3 sans erreur.",					'week3_nomiss',			false],
		["Tueur de femmes",					"Compléter Semaine 4 sans erreur.",				'week4_nomiss',			false],
		["Noël sans faute",			"Compléter Semaine 5 sans erreur.",					'week5_nomiss',			false],
		["Score élevé!!",					"Compléter Semaine 6 sans erreur.",				'week6_nomiss',			false],
		["Dieu Effing Merde!",		"Compléter Semaine 7 sans erreur.",						'week7_nomiss',			false], 
		["Quel Funkin' Désastre!",	"Compléter une chanson avec une évaluation de moins de 20%.",			'ur_bad',			false],
		["Perfectionniste",			   	  "Compléter une Chanson avec une évaluation de 100%.",		'ur_good',			false],
		["Passionné de Roadkill",		 "Regarder les Henchmen mourir plus de 100 tfois.",				'roadkill_enthusiast',		false],
		["Chante trop...?",   "Clique une note pour 10 secondes.",						'oversinging',			false],
		["Hyperactive",					"Terminez une chanson sans rester inactif.",			'hype',				false],
		["Juste que nous deux",		 "Terminez une chanson en pressant que deux clés.",				'two_keys',			false],
		["Toaster Gamer",			  "As-tu essayé de jouer ce jeu sur un toaster?",		'toastie',			false],
		["Débogueur",					"Compléter la chanson \"Test\" depuis l'éditeur de Chart.",	'debugger',			true],
		["Pas Freaky en un vendredi soir",	"Jouer en un Samedi... Soir ?",		'saturday_night_play',	 	true]
	    ] else [
		["Freaky on a Friday Night",	"Play on a Friday... Night.",						'friday_night_play',	 true],
		["She Calls Me Daddy Too",		"Beat Week 1 with no Misses.",				'week1_nomiss',			false],
		["No More Tricks",				"Beat Week 2 with no Misses.",				'week2_nomiss',			false],
		["Call Me The Hitman",			"Beat Week 3 with no Misses.",					'week3_nomiss',			false],
		["Lady Killer",					"Beat Week 4 with no Misses.",				'week4_nomiss',			false],
		["Missless Christmas",			"Beat Week 5 with no Misses.",					'week5_nomiss',			false],
		["Highscore!!",					"Beat Week 6 with no Misses.",				'week6_nomiss',			false],
		["God Effing Damn It!",		"Beat Week 7 with no Misses.",						'week7_nomiss',			false], 
		["What a Funkin' Disaster!",	"Complete a Song with a rating lower than 20%.",			'ur_bad',			false],
		["Perfectionist",			   	  "Complete a Song with a rating of 100%.",		'ur_good',			false],
		["Roadkill Enthusiast",		 "Watch the Henchmen die over 100 times.",				'roadkill_enthusiast',		false],
		["Oversinging Much...?",   "Hold down a note for 10 seconds.",						'oversinging',			false],
		["Hyperactive",					"Finish a Song without going Idle.",			'hype',				false],
		["Just the Two of Us",		 "Finish a Song pressing only two keys.",				'two_keys',			false],
		["Toaster Gamer",			  "Have you tried to run the game on a toaster?",		'toastie',			false],
		["Debugger",					"Beat the \"Test\" Stage from the Chart Editor.",	'debugger',			true],
		["Not Freaky on a Friday Night",	"Play on a Saturday... Night ?",		'saturday_night_play',	 	true]
	];
		
	public static var achievementsMap:Map<String, Bool> = new Map<String, Bool>();

	public static var henchmenDeath:Int = 0;
	public static function unlockAchievement(name:String):Void {
		FlxG.log.add('Completed achievement "$name"');
		achievementsMap.set(name, true);
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
	}

	public static function isAchievementUnlocked(name:String) {
		if(achievementsMap.exists(name) && achievementsMap.get(name)) {
			return true;
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
		if(FlxG.save.data != null) {
			if(FlxG.save.data.achievementsMap != null) {
				achievementsMap = FlxG.save.data.achievementsMap;
			}
			if(henchmenDeath == 0 && FlxG.save.data.henchmenDeath != null) {
				henchmenDeath = FlxG.save.data.henchmenDeath;
			}
		}
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

	public function reloadAchievementImage() {
		if(Achievements.isAchievementUnlocked(tag)) {
			loadGraphic(Paths.image('achievements/' + tag));
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
		var achievementBG:FlxSprite = new FlxSprite(60, 50).makeGraphic(420, 120, FlxColor.BLACK);
		achievementBG.scrollFactor.set();

		var achievementIcon:FlxSprite = new FlxSprite(achievementBG.x + 10, achievementBG.y + 10).loadGraphic(Paths.image('achievements/' + name));
		achievementIcon.scrollFactor.set();
		achievementIcon.setGraphicSize(Std.int(achievementIcon.width * (2 / 3)));
		achievementIcon.updateHitbox();
		achievementIcon.antialiasing = ClientPrefs.globalAntialiasing;

		var achievementName:FlxText = new FlxText(achievementIcon.x + achievementIcon.width + 20, achievementIcon.y + 16, 280, Achievements.achievementsStuff[id][0], 16);
		achievementName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT);
		achievementName.scrollFactor.set();

		var achievementText:FlxText = new FlxText(achievementName.x, achievementName.y + 32, 280, Achievements.achievementsStuff[id][1], 16);
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
