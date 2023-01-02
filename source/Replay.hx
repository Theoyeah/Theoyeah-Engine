/**
Originally made by 
**/
#if desktop
import sys.io.File;
#end
import Controls.Control;
import flixel.FlxG;
import openfl.events.IOErrorEvent;
import openfl.events.Event;
import openfl.net.FileReference;
import haxe.Json;
import flixel.input.keyboard.FlxKey;
import openfl.utils.Dictionary;

class Ana
{
	public var hitTime:Float;
	public var nearestNote:Array<Dynamic>;
	public var hit:Bool;
	public var hitJudge:String;
	public var key:Int;

	public function new(_hitTime:Float, _nearestNote:Array<Dynamic>, _hit:Bool, _hitJudge:String, _key:Int)
	{
		hitTime = _hitTime;
		nearestNote = _nearestNote;
		hit = _hit;
		hitJudge = _hitJudge;
		key = _key;
	}
}

class Analysis
{
	public var anaArray:Array<Ana>;

	public function new()
	{
		anaArray = [];
	}
}

typedef ReplayJSON =
{
	public var replayGameVer:String;
	public var timestamp:Date;
	public var songName:String;
	public var songDiff:Int;
	public var songNotes:Array<Dynamic>;
	public var songJudgements:Array<String>;
	public var noteSpeed:Float;
	public var chartPath:String;
	public var isDownscroll:Bool;
	public var sf:Int; // sameframes
	public var ana:Analysis;
}

class Replay
{
	public static var version:String = "Alpha 1"; // replay file version

	public var path:String = "";
	public var replay:ReplayJSON;

	public function new(path:String)
	{
		this.path = path;
		replay = {
			songName: "No Song Found",
			songDiff: 1,
			noteSpeed: 1.5,
			isDownscroll: false,
			songNotes: [],
			replayGameVer: version,
			chartPath: "",
			timestamp: Date.now(),
			sf: Std.int(ClientPrefs.safeFrames),
			ana: new Analysis(),
			songJudgements: []
		};
	}

	public static function LoadReplay(path:String):Replay
	{
		var rep:Replay = new Replay(path);

		rep.LoadFromJSON();

		trace('basic replay data:\nSong Name: ' + rep.replay.songName + '\nSong Diff: ' + rep.replay.songDiff);

		return rep;
	}

	public function SaveReplay(notearray:Array<Dynamic>, judge:Array<String>, ana:Analysis)
	{
		var chartPath = "";

		var json = {
			"songName": PlayState.SONG.song,
			"songId": Paths.formatToSongPath(PlayState.SONG.song),
			"songDiff": PlayState.storyDifficulty,
			"chartPath": chartPath,
			"timestamp": Date.now(),
			"replayGameVer": version,
			"sf": Std.int(ClientPrefs.safeFrames),
			"noteSpeed": (PlayState.instance.songSpeed),
			"isDownscroll": ClientPrefs.downScroll,
			"songNotes": notearray,
			"songJudgements": judge,
			"ana": ana
		};

		var data:String = Json.stringify(json, null, "");

		var time = Date.now().getTime();

		#if desktop
		File.saveContent("assets/system/replay-" + Paths.formatToSongPath(PlayState.SONG.song) + "-time" + time + ".theoyeahReplay", data); // FUCK YOU REPLAYS!

		path = "replay-" + Paths.formatToSongPath(PlayState.SONG.song) + "-time" + time + ".theoyeahReplay"; // for score screen shit

		LoadFromJSON();

		replay.ana = ana;
		#end
	}

	public function LoadFromJSON()
	{
		#if desktop
		trace('loading ' + Sys.getCwd() + 'assets/system/' + path + ' replay...');
		try
		{
			var repl:ReplayJSON = cast Json.parse(File.getContent(Sys.getCwd() + "assets/system/" + path));
			replay = repl;
		}
		catch (e)
		{
			trace('failed!\n' + e.message);
		}
		#end
	}
}