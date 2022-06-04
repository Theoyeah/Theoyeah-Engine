package;

import animateatlas.AtlasFrameMaker;
import flixel.math.FlxPoint;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import openfl.geom.Rectangle;
import flixel.math.FlxRect;
import haxe.xml.Access;
import openfl.system.System;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import lime.utils.Assets;
import flixel.FlxSprite;
#if MODS_ALLOWED
import sys.io.File;
import sys.FileSystem;
#end
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;

import flash.media.Sound;

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
		'videos',
		'images',
		'stages',
		'weeks',
		'fonts',
		'scripts',
		'achievements'
	];
	#end

	public static function excludeAsset(key:String) {
		if (!dumpExclusions.contains(key))
			dumpExclusions.push(key);
	}

	public static var dumpExclusions:Array<String> =
	[
		'assets/music/freakyMenu.$SOUND_EXT',
		'assets/shared/music/breakfast.$SOUND_EXT',
		'assets/shared/music/tea-time.$SOUND_EXT',
	];
	/// haya I love you for the base cache dump I took to the max
	public static function clearUnusedMemory() {
		// clear non local assets in the tracked assets list
		for (key in currentTrackedAssets.keys()) {
			// if it is not currently contained within the used local assets
			if (!localTrackedAssets.contains(key) 
				&& !dumpExclusions.contains(key)) {
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

	// define the locally tracked assets
	public static var localTrackedAssets:Array<String> = [];
	public static function clearStoredMemory(?cleanUnused:Bool = false) {
		// clear anything not in the tracked assets list
		@:privateAccess
		for (key in FlxG.bitmap._cache.keys())
		{
			var obj = FlxG.bitmap._cache.get(key);
			if (obj != null && !currentTrackedAssets.exists(key)) {
				openfl.Assets.cache.removeBitmapData(key);
				FlxG.bitmap._cache.remove(key);
				obj.destroy();
			}
		}

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
		openfl.Assets.cache.clear("songs");
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
	public static function getPath(file:String, type:AssetType, ?library:Null<String> = null)
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath:String = '';
			if(currentLevel != 'shared') {
				levelPath = getLibraryPathForce(file, currentLevel);
				/*#if sys
				if(FileSystem.exists(levelPath, type))
				#else*/
				if (OpenFlAssets.exists(levelPath, type))
				//#end
					return levelPath;
			}

			levelPath = getLibraryPathForce(file, "shared");
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

	inline public static function getPreloadPath(file:String = '')
	{
		return 'assets/$file'; //returns 'assets/' + file
	}

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
	{
		return getPath(file, type, library);
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('data/$key.txt', TEXT, library); //returns getPath('data/' + key + '.txt', TEXT, library)
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library); //returns getPath('data/' + key + '.xml', TEXT, library)
	}

	inline static public function json(key:String, ?library:String)
	{
		return getPath('data/$key.json', TEXT, library);
	}

	// shaders
	inline static public function shaderFragment(key:String, ?library:String)
	{
		return getPath('shaders/$key.frag', TEXT, library);
	}
	inline static public function shaderVertex(key:String, ?library:String)
	{
		return getPath('shaders/$key.vert', TEXT, library);
	}

	inline static public function lua(key:String, ?library:String)
	{
		return getPath('$key.lua', TEXT, library);
	}

	static public function video(key:String, ?ignoreMods:Bool = false)
	{
		#if MODS_ALLOWED
		var file:String = modsVideo(key);
		if(FileSystem.exists(file) && !ignoreMods) {
			return file;
		}
		#end
		return 'assets/videos/$key.$VIDEO_EXT'; //returns 'assets/videos/' + key + '.' + VIDEO_EXT
	}

	static public function sound(key:String, ?library:String):Sound
	{
		var sound:Sound = returnSound('sounds', key, library);
		return sound;
	}
	
	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String):Sound
	{
		var file:Sound = returnSound('music', key, library);
		return file;
	}

	inline static public function voices(song:String):Any
	{
		var songKey:String = '${song.toLowerCase().replace(' ', '-')}/Voices';
		var voices = returnSound('songs', songKey);
		return voices;
	}

	inline static public function inst(song:String):Any
	{
		var songKey:String = '${formatToSongPath(song)}/Inst';
		var inst = returnSound('songs', songKey);
		return inst;
	}

	inline static public function image(key:String, ?library:String):FlxGraphic
	{
		// streamlined the assets process more
		var returnAsset:FlxGraphic = returnGraphic(key, library);
		return returnAsset;
	}

	static public function getTextFromFile(key:String, ?ignoreMods:Bool = false):String
	{
		#if sys
		#if MODS_ALLOWED
		if (FileSystem.exists(modFolders(key)) && !ignoreMods)
			return File.getContent(modFolders(key));
		else if(File.exists(modFolders(key.toLowerCase())) && !ignoreMods)
			return File.getContent(modFolders(key.toLowerCase()));
		else if(File.exists(modFolders(key.toUpperCase())) && !ignoreMods)
			return File.getContent(modFolders(key.toUpperCase()));
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
				else if (FileSystem.exists(levelPath.toLowerCase()))
					return File.getContent(levelPath.toLowerCase());
				if (FileSystem.exists(levelPath.toUpperCase()))
					return File.getContent(levelPath.toUpperCase());
			}

			levelPath = getLibraryPathForce(key, 'shared');
			if (FileSystem.exists(levelPath))
				return File.getContent(levelPath);
			else if (FileSystem.exists(levelPath.toLowerCase()))
				return File.getContent(levelPath.toLowerCase());
			else if (FileSystem.exists(levelPath.toUpperCase()))
				return File.getContent(levelPath.toUpperCase());
		}
		#end
		return Assets.getText(getPath(key, TEXT));
	}

	inline static public function font(key:String)
	{
		#if MODS_ALLOWED
		var file:String = modsFont(key);
		if(FileSystem.exists(file)) {
			return file;
		}
		#end
		return 'assets/fonts/$key';
	}

	inline static public function fileExists(key:String, type:AssetType, ?ignoreMods:Bool = false, ?library:String)
	{
		#if MODS_ALLOWED
		if(FileSystem.exists(mods(currentModDirectory + '/' + key)) || FileSystem.exists(mods(key))
		   || FileSystem.exists(mods(currentModDirectory + '/' + key.toLowerCase())) || FileSystem.exists(mods(key.toLowerCase()))
		   || FileSystem.exists(mods(currentModDirectory + '/' + key.toUpperCase())) || FileSystem.exists(mods(key.toUpperCase()))) {
			return true;
		}
		#end
		
		if(OpenFlAssets.exists(getPath(key, type)) || OpenFlAssets.exists(getPath(key.toLowerCase(), type)) || OpenFlAssets.exists(getPath(key.toUpperCase(), type))) {
			return true;
		}
		return false;
	}

	inline static public function getSparrowAtlas(key:String, ?library:String):FlxAtlasFrames
	{
		#if MODS_ALLOWED
		var imageLoaded:FlxGraphic = returnGraphic(key);
		var xmlExists:Bool = false;
		if(FileSystem.exists(modsXml(key))) {
			xmlExists = true;
		}

		return FlxAtlasFrames.fromSparrow((imageLoaded != null ? imageLoaded : image(key, library)), (xmlExists ? File.getContent(modsXml(key)) : file('images/$key.xml', library)));
		#else
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
		#end
	}


	inline static public function getPackerAtlas(key:String, ?library:String)
	{
		#if MODS_ALLOWED
		var imageLoaded:FlxGraphic = returnGraphic(key);
		var txtExists:Bool = false;
		if(FileSystem.exists(modsTxt(key))) {
			txtExists = true;
		}

		return FlxAtlasFrames.fromSpriteSheetPacker((imageLoaded != null ? imageLoaded : image(key, library)), (txtExists ? File.getContent(modsTxt(key)) : file('images/$key.txt', library)));
		#else
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
		#end
	}

	inline static public function formatToSongPath(path:String) {
		return path.toLowerCase().replace(' ', '-');
	}

	// completely rewritten asset loading? fuck!
	public static var currentTrackedAssets:Map<String, FlxGraphic> = [];
	public static function returnGraphic(key:String, ?library:String) {
		#if MODS_ALLOWED
		var modKey:String = modsImages(key);
		var modKey_:String = modsImages(key.toLowerCase());
		var modKey2:String = modsImages(key.toUpperCase());
		if(FileSystem.exists(modKey)) {
			if(!currentTrackedAssets.exists(modKey)) {
				var newBitmap:BitmapData = BitmapData.fromFile(modKey);
				var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(newBitmap, false, modKey);
				newGraphic.persist = true;
				currentTrackedAssets.set(modKey, newGraphic);
			}
			localTrackedAssets.push(modKey);
			return currentTrackedAssets.get(modKey);
		} else if(FileSystem.exists(modKey2)) {
			if(!currentTrackedAssets.exists(modKey2)) {
				var newBitmap:BitmapData = BitmapData.fromFile(modKey2);
				var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(newBitmap, false, modKey2);
				newGraphic.persist = true;
				currentTrackedAssets.set(modKey2, newGraphic);
			}
			localTrackedAssets.push(modKey2);
			return currentTrackedAssets.get(modKey2);
		} else if(FileSystem.exists(modKey_)) {
			if(!currentTrackedAssets.exists(modKey_)) {
				var newBitmap:BitmapData = BitmapData.fromFile(modKey_);
				var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(newBitmap, false, modKey_);
				newGraphic.persist = true;
				currentTrackedAssets.set(modKey_, newGraphic);
			}
			localTrackedAssets.push(modKey_);
			return currentTrackedAssets.get(modKey_);
		}
		#end

		var path = getPath('images/$key.png', IMAGE, library);
		var path_ = getPath('images/$key.PNG', IMAGE, library);
		var papath = getPath('images/' + key.toLowerCase(). + '.png', IMAGE, library);
		var papapath = getPath('images/' + key.toUpperCase(). + '.png', IMAGE, library);
		var papapapath = getPath('images/' + key.toLowerCase(). + '.PNG', IMAGE, library);
		var papapapapath = getPath('images/' + key.toUpperCase(). + '.PNG', IMAGE, library);
		if (OpenFlAssets.exists(path, IMAGE)) {
			if(!currentTrackedAssets.exists(path)) {
				var newGraphic:FlxGraphic = FlxG.bitmap.add(path, false, path);
				newGraphic.persist = true;
				currentTrackedAssets.set(path, newGraphic);
			}
			localTrackedAssets.push(path);
			return currentTrackedAssets.get(path);
		} else if (OpenFlAssets.exists(path_, IMAGE)) {
			if(!currentTrackedAssets.exists(path_)) {
				var newGraphic:FlxGraphic = FlxG.bitmap.add(path_, false, path_);
				newGraphic.persist = true;
				currentTrackedAssets.set(path_, newGraphic);
			}
			localTrackedAssets.push(path_);
			return currentTrackedAssets.get(path_);
		} else if (OpenFlAssets.exists(papath, IMAGE)) {
			if(!currentTrackedAssets.exists(papath)) {
				var newGraphic:FlxGraphic = FlxG.bitmap.add(papath, false, papath);
				newGraphic.persist = true;
				currentTrackedAssets.set(papath, newGraphic);
			}
			localTrackedAssets.push(papath);
			return currentTrackedAssets.get(papath);
		} else if (OpenFlAssets.exists(papapath, IMAGE)) {
			if(!currentTrackedAssets.exists(papapath)) {
				var newGraphic:FlxGraphic = FlxG.bitmap.add(papapath, false, papapath);
				newGraphic.persist = true;
				currentTrackedAssets.set(papapath, newGraphic);
			}
			localTrackedAssets.push(papapath);
			return currentTrackedAssets.get(papapath);
		} else if (OpenFlAssets.exists(papapapath, IMAGE)) {
			if(!currentTrackedAssets.exists(papapapath)) {
				var newGraphic:FlxGraphic = FlxG.bitmap.add(papapapath, false, papapapath);
				newGraphic.persist = true;
				currentTrackedAssets.set(papapapath, newGraphic);
			}
			localTrackedAssets.push(papapapath);
			return currentTrackedAssets.get(papapapath);
		} else if (OpenFlAssets.exists(papapapapath, IMAGE)) {
			if(!currentTrackedAssets.exists(papapapapath)) {
				var newGraphic:FlxGraphic = FlxG.bitmap.add(papapapapath, false, papapapapath);
				newGraphic.persist = true;
				currentTrackedAssets.set(papapapapath, newGraphic);
			}
			localTrackedAssets.push(papapapapath);
			return currentTrackedAssets.get(papapapapath);
		}
		trace('oh no $key is returning null NOOOO');
		return null;
	}

	public static var currentTrackedSounds:Map<String, Sound> = [];
	public static function returnSound(path:String, key:String, ?library:String) {
		#if MODS_ALLOWED
		var file:String = modsSounds(path, key);
		var file2:String = modsSounds(path, key.toLowerCase());
		var file3:String = modsSounds(path, key.toUpperCase());
		if(FileSystem.exists(file)) {
			if(!currentTrackedSounds.exists(file)) {
				currentTrackedSounds.set(file, Sound.fromFile(file));
			}
			localTrackedAssets.push(key);
			return currentTrackedSounds.get(file);
		} else if(FileSystem.exists(file2)) {
			if(!currentTrackedSounds.exists(file2)) {
				currentTrackedSounds.set(file2, Sound.fromFile(file2));
			}
			localTrackedAssets.push(key.toLowerCase());
			return currentTrackedSounds.get(file2);
		} else if(FileSystem.exists(file3)) {
			if(!currentTrackedSounds.exists(file3)) {
				currentTrackedSounds.set(file3, Sound.fromFile(file3));
			}
			localTrackedAssets.push(key.toUpperCase());
			return currentTrackedSounds.get(file3);
		}
		#end
		// I hate this so god damn much
		var gottenPath:String = getPath('$path/$key.$SOUND_EXT', SOUND, library);	
		gottenPath = gottenPath.substring(gottenPath.indexOf(':') + 1, gottenPath.length);
		// trace(gottenPath);
		if(!currentTrackedSounds.exists(gottenPath)) 
		#if MODS_ALLOWED
			currentTrackedSounds.set(gottenPath, Sound.fromFile('./' + gottenPath));
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

	inline static public function currentModImages(key:String) {
		var img:String = if(StringTools.contains(key, '.png')) key else key + '.png';
		if(currentModDirectory == '') {
			return 'mods/images/$img';
		}
		return 'mods/$currentModDirectory/images/$img';
	}
	#if LUA_ALLOWED
	inline static public function customLua(thing:String, notetype:Bool = true, getPreload:Bool = false) {
		if(!getPreload) {
			if(notetype) {
				return modFolders('custom_notetypes/$thing.lua');
			}
			return modFolders('custom_events/' + thing + '.lua');
		} else {
			if(notetype) {
				return getPreloadPath('custom_notetypes/' + thing + '.lua');
			}
			return getPreloadPath('custom_events/' + thing + '.lua');
		}
	}
	#end
	inline static public function modsFont(key:String) {
		return modFolders('fonts/$key');
	}

	inline static public function modsJson(key:String) {
		return modFolders('data/$key.json');
	}

	inline static public function modsVideo(key:String) {
		return modFolders('videos/$key.$VIDEO_EXT');
	}

	inline static public function modsSounds(path:String, key:String) {
		return modFolders('$path/$key.$SOUND_EXT');
	}

	inline static public function modsImages(key:String) {
		return modFolders('images/$key.png');
	}

	inline static public function modsXml(key:String) {
		return modFolders('images/$key.xml');
	}

	inline static public function modsTxt(key:String) {
		return modFolders('images/$key.txt');
	}

	inline static public function modsShaderFragment(key:String, ?library:String)
	{
		return modFolders('shaders/$key.frag');
	}
	inline static public function modsShaderVertex(key:String, ?library:String)
	{
		return modFolders('shaders/$key.vert');
	}
	inline static public function modsAchievements(key:String) {
		return modFolders('achievements/$key.json');
	}

	static public function modFolders(key:String) {
		if(currentModDirectory != null && currentModDirectory.length > 0) {
			var fileToCheck:String = mods(currentModDirectory + '/' + key);
			var file2:String = mods(currentModDirectory + '/' + key.toLowerCase());
			var file3:String = mods(currentModDirectory + '/' + key.toUpperCase());
			if(FileSystem.exists(fileToCheck)) {
				return fileToCheck;
			} else if(FileSystem.exists(file2)) {
				return file2;
			} else if(FileSystem.exists(file3)) {
				return file3;
			}
		}
		return 'mods/$key';
	}
	static public function getModDirectories():Array<String> {
		var list:Array<String> = [];
		var modsFolder:String = mods();
		if(FileSystem.exists(modsFolder)) {
			for (folder in FileSystem.readDirectory(modsFolder)) {
				var path = haxe.io.Path.join([modsFolder, folder]);
				if (sys.FileSystem.isDirectory(path) && !ignoreModFolders.contains(folder) && !list.contains(folder)) {
					list.push(folder);
				}
			}
		}
		return list;
	}
	#end
}
