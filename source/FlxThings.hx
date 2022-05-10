package;

import flixel.FlxSprite;

using StringTools;

class NewFlxSprite extends FlxSprite
{
	public function createSprite(name:String, ?image:String) {
		var name = new FlxSprite();
		if(image != null) {
			name.loadGraphic(image);
		}
		add(name);
	}


}
