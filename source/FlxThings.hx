package;

import flixel.FlxSprite;

using StringTools;

class NewFlxSprite extends FlxSprite
{
	public function setGraphic(sprite:FlxSprite, x:Float, y:Float) {
		sprite.x = x;
		sprite.y = y;
		
	}
	
	public function createGraphic(sprite:FlxSprite, ?image:String) {
		if(image != null) {
			sprite.loadGraphic(image);
		}
		add(name);
	}
	
	public function moveSpriteScreen(tween:FlxTween, sprite:FlxSprite, x:Float, y:Float, duration:Float) {
		tween.tween(sprite, { x:x , y:y }, duration);
	}

	
}
