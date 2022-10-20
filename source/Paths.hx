package;

import animateatlas.AtlasFrameMaker;
import flash.media.Sound;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import haxe.Json;
import haxe.xml.Access;
import lime.utils.Assets;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import openfl.system.System;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
#if sys
import sys.FileSystem;
import sys.io.File;
#end
using StringTools;

class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;
	inline public static var VIDEO_EXT = "mp4";

	#if MODS_ALLOWED
	public static var ignoreModFolders:Array<String> = [
		'characters',
		'custom_events',
		'custom_notetypes',
		'data',
		'songs',
		'music',
		'sounds',
		'shaders',
		'old_shaders',
		'videos',
		'images',
		'stages',
		'weeks',
		'fonts',
		'scripts',
		'achievements',
		'noteskins'
	];
	public static var customImagesLoaded:Map<String, Bool> = new Map();
	public static var customSoundsLoaded:Map<String, Sound> = new Map();
	#end

	public static function getIsBlankString(s:String, space:Bool = false) {
		if(space && (s == '' || s == ' ' || s == null))
			return true;
		if(s == '' || s == null)
			return true;
		return false;
	}
	inline public static function returnNull(key:String, ?where:String) {
		if(where != null)
			trace('"$key" in "$where" is returning null NOOOO');
		else
			trace('oh no $key is returning null NOOOO');
	}

	public static function excludeAsset(key:String) {
		if (!dumpExclusions.contains(key))
			dumpExclusions.push(key);
	}

	public static function destroyLoadedImages(ignoreCheck:Bool = false) {
		#if MODS_ALLOWED
		if(!ignoreCheck && ClientPrefs.imagesPersist) return; //If there's 20+ images loaded, do a cleanup just for preventing a crash

		for (key in customImagesLoaded.keys()) {
			var graphic:FlxGraphic = FlxG.bitmap.get(key);
			if(graphic != null) {
				graphic.bitmap.dispose();
				graphic.destroy();
				FlxG.bitmap.removeByKey(key);
			}
		}
		Paths.customImagesLoaded.clear();
		#end
	}

	public static var dumpExclusions:Array<String> =
	[
		'assets/music/freakyMenu.$SOUND_EXT',
		'assets/shared/music/breakfast.$SOUND_EXT',
		'assets/shared/music/tea-time.$SOUND_EXT',
	];
	/// haya I love you for the base cache dump I took to the max
	public static function clearUnusedMemory() {
		if(!ClientPrefs.imagesPersist) { // maybe i add it in the future
			// clear non local assets in the tracked assets list
			for (key in currentTrackedAssets.keys()) {
				// if it is not currently contained within the used local assets
				if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key)) {
					// get rid of it
					var obj = currentTrackedAssets.get(key);
					@:privateAccess
					if (obj != null) {
						openfl.Assets.cache.removeBitmapData(key);
						FlxG.bitmap._cache.remove(key);
						obj.destroy();
						currentTrackedAssets.remove(key);
					}
				}
			}
			// run the garbage collector for good measure lmfao
			System.gc();
		}
	}

	// define the locally tracked assets
	public static var localTrackedAssets:Array<String> = [];
	public static function clearStoredMemory(?cleanUnused:Bool = false) {
		if(!ClientPrefs.imagesPersist) {
			// clear anything not in the tracked assets list
			@:privateAccess
			for (key in FlxG.bitmap._cache.keys())
			{
				var obj = FlxG.bitmap._cache.get(key);
				if (obj != null && !currentTrackedAssets.exists(key)) {
					#if PRELOAD_ALL
					openfl.Assets.cache.clear("songs");
					#end
						FlxG.bitmap._cache.remove(key);
					obj.destroy();
				}
			}
		//}
		//if(!ClientPrefs.soundsPersist) {
			// clear all sounds that are cached
			for (key in currentTrackedSounds.keys()) {
				if (!localTrackedAssets.contains(key) 
				    && !dumpExclusions.contains(key) && key != null) {
					//trace('test: ' + dumpExclusions, key);
					Assets.cache.clear(key);
					currentTrackedSounds.remove(key);
				}
			}	
			// flags everything to be cleared out next unused memory clear
			localTrackedAssets = [];
			#if PRELOAD_ALL
			openfl.Assets.cache.clear("songs");
			#end
		}
	}

	static public var currentModDirectory:String = '';
	static public var currentLevel:String;
	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	/**
	* Gets the path
	* @param file file to search
	* @param type type of the file
	* @param library where to search
	* @return i dont know
	*/
	public static function getPath(file:String, type:AssetType, ?library:String, where:String = 'shared')
	{
		if (!getIsBlankString(library))
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath:String = '';
			if(currentLevel != where) {
				levelPath = getLibraryPathForce(file, currentLevel);
				/*#if sys
				if(FileSystem.exists(levelPath, type))
				#else*/
				if (OpenFlAssets.exists(levelPath, type))
				//#end
					return levelPath;
			}

			levelPath = getLibraryPathForce(file, where);
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	/**
	* Gets the library path
	* @param file file to search
	* @param library library
	*/
	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		var returnPath = '$library:assets/$library/$file';
		return returnPath;
	}

	inline public static function assets(key:String) {
		return 'assets/$key';
	}
	inline public static function getPreloadPath(file:String = '')
	{
		return assets(file); //returns 'assets/' + file
	}

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String, where:String = 'shared')
	{
		return getPath(file, type, library, where);
	}

	inline static public function txt(key:String, ?library:String, where:String = 'data')
	{
		return getPath('$where/$key.txt', TEXT, library); //returns getPath('data/' + key + '.txt', TEXT, library)
	}

	inline static public function xml(key:String, ?library:String, where:String = 'data')
	{
		return getPath('$where/$key.xml', TEXT, library); //returns getPath('data/' + key + '.xml', TEXT, library)
	}

	inline static public function json(key:String, ?library:String, where:String = 'data')
	{
		return getPath('$where/$key.json', TEXT, library);
	}

	// _old_ shaders
	inline static public function shaderFragment(key:String, ?library:String, where:String = 'oldShaders')
	{
		return getPath('$where/$key.frag', TEXT, library);
	}
	inline static public function shaderVertex(key:String, ?library:String, where:String = 'oldShaders')
	{
		return getPath('$where/$key.vert', TEXT, library);
	}

	inline static public function lua(key:String, ?library:String)
	{
		return getPath('$key.lua', TEXT, library);
	}

	static public function video(key:String, ?ignoreMods:Bool = false, ?mkvFile:Bool = false, where:String = 'videos')
	{
		#if (MODS_ALLOWED && sys)
		var file:String = modsVideo(key, where);
		var file_:String = modsVideo2(key, where);
		var file2:String = modsVideo2(key, where, true);
		#if MKV_ALLOWED
		if(FileSystem.exists(file_) && !ignoreMods && mkvFile)
			return file_;
		else if(FileSystem.exists(file2) && !ignoreMods && mkvFile)
			return file2;
		else #end if(FileSystem.exists(file) && !ignoreMods)
			return file;
		#end
		if(!getIsBlankString(where, true)) {
			#if MKV_ALLOWED
			if(mkvFile && #if sys FileSystem.exists('assets/$where/$key.mkv') #else OpenFlAssets.exists('assets/$where/$key.mkv') #end )
				return assets('$where/$key.mkv');
			else if(mkvFile && #if sys FileSystem.exists('assets/$where/$key.MKV') #else OpenFlAssets.exists('assets/$where/$key.MKV') #end )
				return assets('$where/$key.MKV');
			else #end if( #if sys FileSystem.exists('assets/$where/$key.$VIDEO_EXT') #else OpenFlAssets.exists('assets/$where/$key.$VIDEO_EXT') #end )
				return assets('$where/$key.$VIDEO_EXT'); //returns 'assets/videos/' + key + '.' + VIDEO_EXT
			else if( #if sys FileSystem.exists('assets/$where/$key.MP4') #else OpenFlAssets.exists('assets/$where/$key.MP4') #end )
				return assets('$where/$key.MP4'); //returns 'assets/videos/' + key + '.' + VIDEO_EXT
		} else {
			#if MKV_ALLOWED
			if(mkvFile && #if sys FileSystem.exists(assets('$key.mkv')) #else OpenFlAssets.exists(assets('$key.mkv')) #end )
				return assets('$key.mkv');
			else #end if( #if sys FileSystem.exists(assets('$key.$VIDEO_EXT')) #else OpenFlAssets.exists(assets('$key.$VIDEO_EXT')) #end )
				return assets('$key.$VIDEO_EXT'); //returns 'assets/videos/' + key + '.' + VIDEO_EXT
		}
		returnNull(key, where);
		return null;
	}

	static public function sound(key:String, ?library:String, where:String = 'sounds'):Sound
	{
		var sound:Sound = returnSound(where, key, library);
		return sound;
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String, where:String = 'sounds')
	{
		return sound(key + FlxG.random.int(min, max), library, where);
	}

	inline static public function music(key:String = 'freakyMenu', ?library:String, where:String = 'music'):Sound
	{
		var file:Sound = returnSound(where, key, library);
		return file;
	}

	inline static public function voices(song:String):Any
	{
		#if PRELOAD_ALL
		var songKey:String = '${song.toLowerCase().replace(' ', '-')}/Voices';
		var voices = returnSound('songs', songKey);
		return voices;
		#else
		var songKey:String = '${song.toLowerCase().replace(' ', '-')}';
		var voices = returnSound(songKey, 'Voices', 'songs');
		return voices;
		#end
	}

	inline static public function inst(song:String):Any
	{
		#if PRELOAD_ALL
		var songKey:String = '${song.toLowerCase().replace(' ', '-')}/Inst';
		var inst = returnSound('songs', songKey);
		return inst;
		#else
		var songKey:String = '${song.toLowerCase().replace(' ', '-')}';
		var inst = returnSound(songKey, 'Inst', 'songs');
		return inst;
		#end
	}

	inline static public function image(key:String, ?library:String, where:String = 'images'):FlxGraphic
	{
		// streamlined the assets process more
		var returnAsset:FlxGraphic = returnGraphic(key, library, where);
		return returnAsset;
	}

	static public function getTextFromFile(key:String, ?ignoreMods:Bool = false):String
	{
		#if sys
		#if MODS_ALLOWED
		if (FileSystem.exists(modFolders(key)) && !ignoreMods)
			return File.getContent(modFolders(key));
		#end

		if (FileSystem.exists(getPreloadPath(key)))
			return File.getContent(getPreloadPath(key));

		if (currentLevel != null)
		{
			var levelPath:String = '';
			if(currentLevel != 'shared') {
				levelPath = getLibraryPathForce(key, currentLevel);
				if (FileSystem.exists(levelPath))
					return File.getContent(levelPath);
			}

			levelPath = getLibraryPathForce(key, 'shared');
			if (FileSystem.exists(levelPath))
				return File.getContent(levelPath);
		}
		#end
		return Assets.getText(getPath(key, TEXT));
	}

	inline static public function font(key:String, where:String = 'fonts')
	{
		#if MODS_ALLOWED
		var file:String = modsFont(key, where);
		if(FileSystem.exists(file))
			return file;
		#end
		return assets('$where/$key');
	}

	inline static public function fileExists(key:String, ?type:AssetType, ignoreMods:Bool = false, ?library:String, prefix:String = '', suffix:String = '', tryLowerCase:Bool = true):Bool
	{
		#if MODS_ALLOWED
		if(FileSystem.exists(currentModKey(prefix + key + suffix))
			|| FileSystem.exists(mods(prefix + key + suffix))
			|| (FileSystem.exists(currentModKey(prefix + key.toLowerCase() + suffix)) && tryLowerCase)
			|| (FileSystem.exists(mods(prefix + key.toLowerCase() + suffix)) && tryLowerCase))
		{
			return true;
		}
		#end

		if(OpenFlAssets.exists(getPath(prefix + key + suffix, type)) || (OpenFlAssets.exists(getPath(prefix + key.toLowerCase() + suffix, type)) && tryLowerCase)) {
			return true;
		}
		return false;
	}
	inline static public function whereExists(key:String, ?type:AssetType, traceThings:Bool = false, whatValueToReturn:Int = 0, ignoreMods:Bool = false, ?library:String) {
		var here:Array<Dynamic> = [];
		var moreThanOne:Bool = false;
		var isNull:Array<Dynamic> = [];
		#if MODS_ALLOWED
		if(FileSystem.exists(currentModKey(key)) && !ignoreMods) {
			here.push(currentModKey(key));
		}
		if(FileSystem.exists(mods(key)) && !ignoreMods) {
			here.push(mods(key));
			if(here.length > 0)
				moreThanOne = true;
		}
		#end

		if(OpenFlAssets.exists(getPath(key, type))) {
			here.push(getPath(key, type));
			if(here.length > 0)
				moreThanOne = true;
		}
		if(here.length > 1 || moreThanOne) {
			if(traceThings) {
				for (i in 0...here.length) {
					trace(here[i]);
				}
			}
			if(whatValueToReturn > here.length)
				return here[here.length];
			return here[whatValueToReturn];
		}
		if(here == isNull) {
			returnNull(key);
			return null;
		}
		return here[0];
	}

	inline static public function getSparrowAtlas(key:String, ?library:String, where:String = 'images'):FlxAtlasFrames
	{
		#if MODS_ALLOWED
		var imageLoaded:FlxGraphic = returnGraphic(key);
		var xmlExists:Bool = false;
		if(FileSystem.exists(modsXml(key)))
			xmlExists = true;

		return FlxAtlasFrames.fromSparrow((imageLoaded != null ? imageLoaded : image(key, library)), (xmlExists ? File.getContent(modsXml(key)) : file('$where/$key.xml', library)));
		#else
		return FlxAtlasFrames.fromSparrow(image(key, library), file('$where/$key.xml', library));
		#end
	}


	inline static public function getPackerAtlas(key:String, ?library:String, where:String = 'images')
	{
		#if MODS_ALLOWED
		var imageLoaded:FlxGraphic = returnGraphic(key);
		var txtExists:Bool = false;
		if(FileSystem.exists(modsTxt(key))) {
			txtExists = true;
		}

		return FlxAtlasFrames.fromSpriteSheetPacker((imageLoaded != null ? imageLoaded : image(key, library)), (txtExists ? File.getContent(modsTxt(key)) : file('$where/$key.txt', library)));
		#else
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('$where/$key.txt', library));
		#end
	}

	inline static public function formatToSongPath(path:String, ?newSystem:Bool = true) {
		if(!newSystem) return path.toLowerCase().replace(' ', '-');

		var invalidChars:EReg = ~/[ ~&\\;:<>#]/;
		var hideChars:EReg = ~/[.,'"%?!]/;

		var path:String = invalidChars.split(path).join("-");
		return hideChars.split(path).join("").toLowerCase();
	}

	// completely rewritten asset loading? fuck!
	public static var currentTrackedAssets:Map<String, FlxGraphic> = [];
	public static function returnGraphic(key:String, ?library:String, where:String = 'images') {
		#if MODS_ALLOWED
		var modKey:String = modsImages(key, where);
		var modKey_:String = modImages2(key, where);
		var thisModKey:String = if(FileSystem.exists(modKey)) modKey else modKey_;
		if(FileSystem.exists(thisModKey)) {
			if(!currentTrackedAssets.exists(thisModKey)) {
				var newBitmap:BitmapData = BitmapData.fromFile(thisModKey);
				var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(newBitmap, false, thisModKey);
				newGraphic.persist = true;
				currentTrackedAssets.set(thisModKey, newGraphic);
			}
			localTrackedAssets.push(thisModKey);
			return currentTrackedAssets.get(thisModKey);
		}
		#end

		var path = getPath('$where/$key.png', IMAGE, library);
		var path_ = getPath('$where/$key.PNG', IMAGE, library);
		var thePath:String = if(OpenFlAssets.exists(path, IMAGE)) path else path_;
		if (OpenFlAssets.exists(thePath, IMAGE)) {
			if(!currentTrackedAssets.exists(thePath)) {
				var newGraphic:FlxGraphic = FlxG.bitmap.add(thePath, false, thePath);
				newGraphic.persist = true;
				currentTrackedAssets.set(thePath, newGraphic);
			}
			localTrackedAssets.push(thePath);
			return currentTrackedAssets.get(thePath);
		}
		returnNull(key, where);
		return null;
	}

	public static var currentTrackedSounds:Map<String, Sound> = [];
	public static function returnSound(path:String, key:String, ?library:String) {
		#if MODS_ALLOWED
		var file:String = modsSounds(path, key);
		#if WAV_ALLOWED
		var file_:String = modsWavSounds(path, key);
		#end
		#if MP3_ALLOWED
		var mp3File:String = modsMP3Sounds(path, key);
		#end
		var theFile:String = if(FileSystem.exists(file)) file #if WAV_ALLOWED else #if MP3_ALLOWED if(FileSystem.exists(file_)) #end file_ #end #if MP3_ALLOWED else mp3File #end;
		if(FileSystem.exists(theFile)) {
			if(!currentTrackedSounds.exists(theFile)) {
				currentTrackedSounds.set(theFile, Sound.fromFile(theFile));
			}
			localTrackedAssets.push(key);
			return currentTrackedSounds.get(theFile);
		}
		#end
		// I hate this so god damn much
		var gottenPath:String = getPath('$path/$key.$SOUND_EXT', SOUND, library);	
		gottenPath = gottenPath.substring(gottenPath.indexOf(':') + 1, gottenPath.length);
		// trace(gottenPath);
		if(!currentTrackedSounds.exists(gottenPath)) 
		#if MODS_ALLOWED
			currentTrackedSounds.set(gottenPath, Sound.fromFile('./$gottenPath'));
		#else
		{
			var folder:String = '';
			#if html5
			if(path == 'songs') folder = 'songs:';
			#end
			currentTrackedSounds.set(gottenPath, OpenFlAssets.getSound(folder + getPath('$path/$key.$SOUND_EXT', SOUND, library)));
		}
		#end
		localTrackedAssets.push(gottenPath);
		return currentTrackedSounds.get(gottenPath);
	}

	#if MODS_ALLOWED
	inline static public function mods(key:String = '') {
		return 'mods/$key';
	}
	inline static public function currentModKey(key:String) {
		return mods('$currentModDirectory/$key');
	}

	inline static public function currentModImages(key:String, where:String = 'images') {
		var img:String = key.endsWith('.png') ? key : '$key.png';
		if(currentModDirectory == '') {
			return mods('$where/$img');
		}
		return currentModKey('$where/$img');
	}
	inline static public function customLua(thing:String, notetype:Bool = true, getPreload:Bool = false, where:String = '') {
		#if LUA_ALLOWED
		var path:String = where;
		if(where == '') {
			if(notetype)
				path = 'custom_notetypes';
			else
				path = 'custom_events';
		}
		if(!getPreload) {
			return modFolders('$path/$thing.lua');
		}
		return getPreloadPath('$path/$thing.lua');
		#end
	}
	inline static public function modsFont(key:String, where:String = 'fonts') {
		return modFolders('$where/$key');
	}

	inline static public function modsJson(key:String, where:String = 'data') {
		return modFolders('$where/$key.json');
	}

	inline static public function modsVideo(key:String, where:String = 'videos', lower:Bool = false) {
		if(lower) return modFolders('$where/$key.MP4');
		return modFolders('$where/$key.$VIDEO_EXT');
	}
	inline static public function modsVideo2(key:String, where:String = 'videos', lower:Bool = false) {
		if(lower) return modFolders('$where/$key.MKV');
		return modFolders('$where/$key.mkv');
	}

	inline static public function modsSounds(path:String, key:String) {
		return modFolders('$path/$key.$SOUND_EXT');
	}
	inline static public function modsWavSounds(path:String, key:String) {
		return modFolders('$path/$key.wav');
	}
	inline static public function modsMP3Sounds(path:String, key:String) {
		return modFolders('$path/$key.mp3');
	}
	inline static public function modsSoundsAll(path:String, key:String, type:String) {
		return modFolders('$path/$key.$type');
	}

	inline static public function modsImages(key:String, where:String = 'images') {
		return modFolders('$where/$key.png');
	}
	inline static public function modImages2(key:String, where:String = 'images') {
		return modFolders('$where/$key.PNG');
	}

	inline static public function modsXml(key:String, where:String = 'images') {
		return modFolders('$where/$key.xml');
	}

	inline static public function modsTxt(key:String, where:String = 'images') {
		return modFolders('$where/$key.txt');
	}

	inline static public function modsShaderFragment(key:String, ?library:String)
	{
		return modFolders('shaders/$key.frag');
	}
	inline static public function modsShaderVertex(key:String, ?library:String, where:String = 'shaders')
	{
		return modFolders('$where/$key.vert');
	}
	inline static public function modsAchievements(key:String, where:String = 'achievements') {
		return modFolders('$where/$key.json');
	}

	static public function modFolders(key:String) {
		if(currentModDirectory != null && currentModDirectory.length > 0) {
			var fileToCheck:String = currentModKey(key);
			var fifileToCheck:String = currentModKey(key.toLowerCase());
			if(FileSystem.exists(fileToCheck))
				return fileToCheck;
			else if(FileSystem.exists(fifileToCheck))
				return fifileToCheck;
		}

		for(mod in getGlobalMods()) {
			var fileToCheck:String = mods(mod + '/' + key);
			var fifileToCheck:String = mods(mod + '/' + key.toLowerCase());
			if(FileSystem.exists(fileToCheck))
				return fileToCheck;
			else if(FileSystem.exists(fifileToCheck))
				return fifileToCheck;
		}
		return mods(key);
	}

	public static var globalMods:Array<String> = [];

 	static public function getGlobalMods()
 		return globalMods;

 	static public function pushGlobalMods() // prob a better way to do this but idc
	{
 		globalMods = [];
		var path:String = 'modsList.txt';
		if(FileSystem.exists(path))
		{
			var list:Array<String> = CoolUtil.coolTextFile(path);
			for (i in list)
			{
				var dat = i.split("|");
				if (dat[1] == "1")
				{
					var folder = dat[0];
					var path = mods(folder + '/pack.json');
					if(FileSystem.exists(path)) {
						try {
							var rawJson:String = File.getContent(path);
							if(rawJson != null && rawJson.length > 0) {
								var stuff:Dynamic = Json.parse(rawJson);
								var global:Bool = Reflect.getProperty(stuff, "runsGlobally");
								if(global && !globalMods.contains(dat[0])) globalMods.push(dat[0]);
							}
						} catch(e:Dynamic) {
							trace(e);
						}
					}
				}
			}
		}
		return globalMods;
	}
	static public function getModDirectories():Array<String> {
		var list:Array<String> = [];
		var modsFolder:String = mods();
		if(FileSystem.exists(modsFolder)) {
			for (folder in FileSystem.readDirectory(modsFolder)) {
				var path = haxe.io.Path.join([modsFolder, folder]);
				if (FileSystem.isDirectory(path) && !ignoreModFolders.contains(folder) && !list.contains(folder)) {
					list.push(folder);
				}
			}
		}
		return list;
	}
	#end
}
