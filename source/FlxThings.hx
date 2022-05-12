package;

import flixel.FlxSprite;

using StringTools;

/*
stoled from HaxeFlixel Docs!!
*/
class FlxThings
{
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

	class MouseThings extends FlxMouse
	{
		public function mousePressed(?returnFalse:Bool = false) {
			if (FlxG.mouse.pressed) {
				return true;
				// The left mouse button is currently pressed
			} else if (returnFalse) {
				return false;
			}
		}

		public function mouseJustPressed(click:String, ?returnFalse:Bool = false) {
			/**
			 * Checks if the click input have just been pressed
			 */

			var clicker:String = click.toLowerCase();
			var right:Bool = switch(clicker) case 'right' | 'rightclick': true default: false;
			var left:Bool = switch(clicker) case 'left' | 'leftclick': true default: false;
			var middle:Bool = switch(clicker) case 'middle' | 'middleclick': true default: false;
			
			if (FlxG.justPressedRight && right) {
				// The right button has just been pressed
				return true;
			} else if (FlxG.mouse.justPressedMiddle && middle) {
				// The middle button has just been pressed
				return true;
			} else if (FlxG.mouse.justPressed && left) {
				// The left mouse button has just been pressed
				return true;
			} else if(returnFalse) {
				return false;
			}
		}

		public function mouseJustReleased(click:String, ?returnFalse:Bool = false) {
			/**
			 * Checks if the click input has been released
			 */
			var clicker:String = click.toLowerCase();
			var right:Bool = switch(clicker) case 'right' | 'rightclick': true default: false;
			var left:Bool = switch(clicker) case 'left' | 'leftclick': true default: false;
			var middle:Bool = switch(clicker) case 'middle' | 'middleclick': true default: false;
			
			if(FlxG.mouse.justReleasedRight && right) {
				return true;
			} else if (FlxG.mouse.justReleased && left) {
				// The left mouse button has just been released
				return true;
			} else if (FlxG.mouse.justReleasedMiddle && middle) {
				return true;
			} else if(returnFalse) {
				return false;
			}
		}
		
	}

	class Colors extends FlxColor
	{
		public function returnColor(color:String, returnFalse:Bool):FlxColor {
			var returnColor:FlxColor;
			switch(color.toUpperCase()) {
				case "TRANSPARENT":
					returnColor = 0x00000000;
				case "WHITE":
					returnColor = 0xFFFFFFFF;
				case "GRAY":
					returnColor = 0xFF808080;
				case "BLACK":
					returnColor = 0xFF000000;
				case "GREEN":
					returnColor = 0xFF008000;
				case "LIME":
					returnColor = 0xFF00FF00;
				case "YELLOW":
					returnColor = 0xFFFFFF00;
				case "ORANGE":
					returnColor = 0xFFFFA500;
				case "RED":
					returnColor = 0xFFFF0000;
				case "PURPLE":
					returnColor = 0xFF800080;
				case "BLUE":
					returnColor = 0xFF0000FF;
				case "BROWN":
					returnColor = 0xFF8B4513;
				case "PINK":
					returnColor = 0xFFFFC0CB;
				case "MAGENTA":
					returnColor = 0xFFFF00FF;
				case "CYAN":
					returnColor = 0xFF00FFFF;
				default: 
					if(returnFalse) {
						returnColor = 0x00000000;
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
		public function getPosition(sound:IEventDispatcher, ?returnPositionIfIsLeft:Bool = false, ?returnPositionIfIsRight:Bool = false):Float {
			if (returnPositionIfIsLeft) {
				return sound.leftPeak;
			} else if(returnPositionIfIsRight) {
				return sound.rightPeak;
			} else {
				return sound.position;
			}
		}
		
	}
	
	class Cameras //with camera it refers to the "windows"
	{
		class MoreCamera extends Camera
		{
			public function getWidthHeight(camera:Camera, returnWidth:Bool, ?returnHeight:Bool = false):Int {
				var heightt:Bool = if(returnWidth) false else true;
				var widthh:Bool = if(returnHeight) false else true;
				var theTwoOfUs:Bool if(returnHeight && returnWidth) true else false;
				if(!theTwoOfUs) {
					if(widthh) {
						return camera.width;
					} else if(heightt) {
						return camera.height;
					}
				}
			}
			
			public function getMotion(camera:Camera, returnLevel, ?returnTimeout = false):Int {
				if(returnLevel) {
					return camera.motionLevel;
				} else {
					return camera.motionTimeout;
				}
			}
			
		}
		
		class MoreFlxCamera extends FlxCamera
		{
			public function getScale(camera:Camera, returnX:Bool, ?returnY:Bool = false):Float {
				if (returnX) {
					return camera.scaleX;
				} else {
					return camera.scaleY;
				}
			}
			
		}
		
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
}
