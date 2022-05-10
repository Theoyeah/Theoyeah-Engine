package;

import flixel.FlxSprite;

using StringTools;

class NewFlxSprite extends FlxSprite
{
	public function setGraphic(name:FlxSprite, x:Float, y:Float) {
		name.x = x;
		name.y = y;
		
	}
	public function createGraphic(name:FlxSprite, ?image:String) {
		if(image != null) {
			name.loadGraphic(image);
		}
		add(name);
	}


}
