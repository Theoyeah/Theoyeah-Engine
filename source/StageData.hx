package;

#if MODS_ALLOWED
import sys.io.File;
import sys.FileSystem;
#else
import openfl.utils.Assets;
#end
import haxe.Json;
import haxe.format.JsonParser;
import LayerFile;
import Song;

using StringTools;

typedef StageFile = {
	var name:String;
	var directory:String;
	var defaultZoom:Float;
	var isPixelStage:Bool;

	var boyfriend:Array<Dynamic>;
	var girlfriend:Array<Dynamic>;
	var opponent:Array<Dynamic>;
	var layerArray:Array<LayerFile>;
	var hide_girlfriend:Bool;

	var camera_boyfriend:Array<Float>;
	var camera_opponent:Array<Float>;
	var camera_girlfriend:Array<Float>;
	var camera_speed:Null<Float>;
}

class StageData {
	public static var forceNextDirectory:String = null;
	public static function loadDirectory(SONG:SwagSong) {
		var stage:String = '';
		if(SONG.stage != null) {
			stage = SONG.stage;
		} else if(SONG.song != null) {
			switch (Paths.formatToSongPath(SONG.song.toLowerCase()))
			{
				case 'spookeez' | 'south' | 'monster':
					stage = 'spooky';
				case 'pico' | 'blammed' | 'philly' | 'philly-nice':
					stage = 'philly';
				case 'milf' | 'satin-panties' | 'high':
					stage = 'limo';
				case 'cocoa' | 'eggnog':
					stage = 'mall';
				case 'winter-horrorland':
					stage = 'mallEvil';
				case 'senpai' | 'roses':
					stage = 'school';
				case 'thorns':
					stage = 'schoolEvil';
				case 'ugh' | 'guns' | 'stress':
					stage = 'tank';
				default:
					stage = 'stage';
			}
		} else {
			stage = 'stage';
		}

		var stageFile:StageFile = getStageFile(stage);
		if(stageFile == null) { //preventing crashes
			forceNextDirectory = '';
		} else {
			forceNextDirectory = stageFile.directory;
		}
	}

	public static function convertStage(stage:Dynamic) { // freaking errors everytime i load another song
		if(stage.layerArray == null) stage.layerArray = [];
		if(stage.name == null) stage.name = '';

		return stage;
	}
	public static function getStageFile(stage:String = 'stage'):StageFile {
		var rawJson:String = null;
		var path:String = Paths.getPreloadPath('stages/' + stage + '.json');
		var papath:String = Paths.getPreloadPath('stages/' + stage.toLowerCase() + '.json');

		#if MODS_ALLOWED
		var modPath:String = Paths.modFolders('stages/' + stage + '.json');
		var modPapath:String = Paths.modFolders('stages/' + stage.toLowerCase() + '.json');
		if(FileSystem.exists(modPath)) {
			rawJson = File.getContent(modPath);
		} else if(FileSystem.exists(modPapath)) {
			rawJson = File.getContent(modPapath);
		} else if(FileSystem.exists(path)) {
			rawJson = File.getContent(path);
		} else if(FileSystem.exists(papath)) {
			rawJson = File.getContent(papath);
		}
		#else
		if(Assets.exists(path)) {
			rawJson = Assets.getText(path);
		} else if(Assets.exists(papath)) {
			rawJson = Assets.getText(papath);
		}
		#end
		else
			return null;
		var daStage = cast Json.parse(rawJson);

		return convertStage(daStage);
	}
}
