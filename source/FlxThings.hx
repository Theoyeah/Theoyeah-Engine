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

class MouseThings extends FlxMouse implements IFlxInputManager
{
	public function mousePressed(returnFalse:Bool):Void {
		if (FlxG.mouse.pressed) {
			return true;
			// The left mouse button is currently pressed
		} else if (returnFalse) {
			return false;
		}
	}

	public function mouseJustPressed(returnFalse:Bool):Void {
		if (FlxG.mouse.justPressed) {
			// The left mouse button has just been pressed
			return true;
		} else if(returnFalse) {
			return false;
		}
	}

	public function mouseJustReleased(returnFalse:Bool):Void {
		if (FlxG.mouse.justReleased) {
			// The left mouse button has just been released
			return true;
		} else if(returnFalse) {
			return false;
		}
	}
}

class Colors extends FlxColor
{
	public function returnColor(color:String, returnFalse:Bool) {
		var returnColor:FlxColor;
		switch(color.toUpperCase()) {
			case "TRANSPARENT": returnColor = 0x00000000;
			case "WHITE": returnColor = 0xFFFFFFFF;
			case "GRAY": returnColor = 0xFF808080;
			case "BLACK": returnColor = 0xFF000000;
			case "GREEN": returnColor = 0xFF008000;
			case "LIME": returnColor = 0xFF00FF00;
			case "YELLOW": returnColor = 0xFFFFFF00;
			case "ORANGE": returnColor = 0xFFFFA500;
			case "RED": returnColor = 0xFFFF0000;
			case "PURPLE": returnColor = 0xFF800080;
			case "BLUE": returnColor = 0xFF0000FF;
			case "BROWN": returnColor = 0xFF8B4513;
			case "PINK": returnColor = 0xFFFFC0CB;
			case "MAGENTA": returnColor = 0xFFFF00FF;
			case "CYAN": returnColor = 0xFF00FFFF;
			default: 
				if(returnFalse) {
					return false;
				}
		}
		return returnColor;
	}
}

class FlxMoreText extends FlxText
{
	public function clearFormat(flxText:FlxText) {
		flxText.clearFormat();
	}
}

class NewSoundChannel extends SoundChannel
{
	public function getPosition(sound:IEventDispatcher, ?left:Bool = false, ?right:Bool = false):Float {
		if (left) {
			return sound.leftPeak;
		} else if(right) {
			return sound.rightPeak;
		} else {
			return sound.position;
		}
	}
}
