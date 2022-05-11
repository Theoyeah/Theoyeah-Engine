package;

import flixel.FlxSprite;

using StringTools;

/*
stoled from HaxeFlixel Docs!!
*/
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

class MouseThings {
	function mousePressed(returnFalse:Bool) {
		if (FlxG.mouse.pressed) {
			return true;
			// The left mouse button is currently pressed
		} else if (returnFalse) {
			return false;
		}
	}

	function mouseJustPressed(returnFalse:Bool) {
		if (FlxG.mouse.justPressed) {
			// The left mouse button has just been pressed
			return true;
		} else if(returnFalse) {
			return false;
		}
	}

    if (FlxG.mouse.justReleased)
    {
        // The left mouse button has just been released
    }
