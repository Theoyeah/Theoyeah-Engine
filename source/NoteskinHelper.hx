package;

import haxe.Json;

#if sys
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;

typedef NoteSkinFile = // this is for custom noteskins
{
	var name:String;
	var imageFile:String;
}

class NoteskinHelper
{
	/**
		hardcoded noteskins should go here
		otherwise follow the template json and add it to your mods folder
		with the assets attached to them

		-BeastlyGhost
	**/
	public static var noteSkins:Map<String, String> = [
		'arrows' => 'NOTE_assets',
		'circles' => 'CIRCLENOTE_assets',
		'bars' => 'BARNOTE_assets',
		'saturated' => 'SATURATEDNOTE_assets'
	];

	public static function reloadNoteSkinFiles()
	{
		#if sys
		var directories:Array<String> = [
			#if MODS_ALLOWED
			Paths.mods('noteskins/'),
			Paths.mods(Paths.currentModDirectory + '/noteskins/'),
			#end
			Paths.getPreloadPath('noteskins/')
		];

		for (i in 0...directories.length)
		{
			var directory:String = directories[i];
			if (FileSystem.exists(directory))
			{
				for (file in FileSystem.readDirectory(directory))
				{
					var path = haxe.io.Path.join([directory, file]);
					if (!FileSystem.isDirectory(path) && file.endsWith('.json'))
					{
						var rawJson:String = File.getContent(path).trim();
						while (!rawJson.endsWith("}"))
						{
							rawJson = rawJson.substr(0, rawJson.length - 1);
							// LOL GOING THROUGH THE BULLSHIT TO CLEAN IDK WHATS STRANGE
						}
						var json:NoteSkinFile = cast Json.parse(rawJson);
						if (!noteSkins.exists(json.name))
							noteSkins.set(json.name, json.imageFile);
					}
				}
			}
		}
		#end
	}

	public static function getNoteSkin(skin:String = 'Arrows', pixel:Bool = false)
	{
		var path:String = 'noteskins/';
		if (pixel)
			path = 'pixelUI/noteskins/';

		if (noteSkins.exists(skin.toLowerCase()))
			path += noteSkins.get(skin.toLowerCase());
		else if(noteSkins.exists(skin))
			path += noteSkins.get(skin);
		else
			path += noteSkins.get('arrows');

		return path;
	}
}