package;

//HaxeFlixel API Packages
import flash.*;
import flixel.*;
import haxe.*;
import hscript.*;
import lime.*;
import nape.*;
import openfl.*;
import spinehaxe.*;


//Game States
import Shaders;
import PlayState;
import Character;
import HealthIcon;
import BGSprite;
import Controls;
import CoolUtil;
import CreditsState;
import ClientPrefs;
import Discord;
import GameOverSubState;
import InputFormatter;
import Main;
import MainMenuState;
import MusicBeatState;
import MusicBeatSubState;
import Note;
import StrumNote;
import NoteSplash;
import Paths;
import Song;
import StageData;
import WeekData;
import animateatlas.AtlasFrameMaker;
import animateatlas.JSONData;
import animateatlas.JSONData2020;
import animateatlas.HelperEnums;
import animateatlas.Main;
import animateatlas.displayobject.SpriteAnimationLibrary;
import animateatlas.displayobject.SpriteMovieClip;
import animateatlas.displayobject.SpriteSymbol;
import animateatlas.tilecontainer.TileAnimationLibrary;
import animateatlas.tilecontainer.TileContainerMovieClip;
import animateatlas.tilecontainer.TileContainerSymbol;

using StringTools;

/*
stoled from HaxeFlixel Docs!!
*/
class FlxThings
{
	class MoreArray /*extends Array *///wtf i dont know
	{
		public function deleteAllVExceptFirst(array:Array):Void { //can someone please prove it for me?
			for (v in array.length-2) {
				array.pop();
			}
		}
	}

	class SaveThings 
	{
		public function createSaveVar(varUsed:Dynamic, loadPrefsFunction:Bool):Void { // THIS ISN'T PROVED!! MAY CAUSE ERRORS!!
			FlxG.save.data.varUsed = varUsed;
			if(loadPrefsFunction && FlxG.save.data.varUsed != null) {
				varUsed = FlxG.save.data.varUsed;
			}
		}
	}

	class NewFlxSprite extends FlxSprite
	{
		public function setGraphic(sprite:FlxSprite, x:Float, y:Float):Void {
			sprite.x = x;
			sprite.y = y;
		}
	
		public function createGraphic(sprite:FlxSprite, ?image:String, ?addTheSprite:Bool = true):Void {
			if(image != null) {
				sprite.loadGraphic(image);
			}
			if(addTheSprite) {
				add(name);
			}
		}
	
		public function moveSpriteScreen(tween:FlxTween, sprite:FlxSprite, x:Float, y:Float, duration:Float):Void {
			tween.tween(sprite, { x:x , y:y }, duration);
		}


	}

	class Figures //i dont know english :'<
	{
		class NewRectangle extends Rectangle
		{
			//to create a rectangle use this new(x:Float = 0, y:Float = 0, width:Float = 0, height:Float = 0)
			public function getWidthOrHeight(figure:Rectangle, returnWidth:Bool, ?returnHeight:Bool):Dynamic {
				var heightt:Bool = if(returnWidth) false else true;
				var widthh:Bool = if(returnHeight) false else true;
				var theTwoOfUs:Bool if(returnHeight && returnWidth) true else false;
				if(!theTwoOfUs) {
					if(widthh) {
						return figure.width;
					} else if(heightt) {
						return figure.height;
					}
				}
			}

		}
		
	}

	class MouseThings extends FlxMouse
	{
		public function mousePressed(?returnFalse:Bool = false):Dynamic {
			if (FlxG.mouse.pressed) {
				return true;
				// The left mouse button is currently pressed
			} else if (returnFalse) {
				return false;
			}
		}

		public function mouseJustPressed(click:String, ?returnFalse:Bool = false):Dynamic {
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

		public function mouseJustReleased(click:String, ?returnFalse:Bool = false):Dynamic {
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

		public function mousePressed(click:String, ?returnFalse:Bool = false):Dynamic {
 			/**
 			 * Checks if the click input has pressed
 			 */
 			var clicker:String = click.toLowerCase();
 			var right:Bool = switch(clicker) case 'right' | 'rightclick': true default: false;
 			var left:Bool = switch(clicker) case 'left' | 'leftclick': true default: false;
 			var middle:Bool = switch(clicker) case 'middle' | 'middleclick': true default: false;

 			if(FlxG.mouse.pressedRight && right) {
 				return true;
 			} else if (FlxG.mouse.pressed && left) {
 				// The left mouse button has pressed
 				return true;
 			} else if (FlxG.mouse.pressedMiddle && middle) {
 				return true;
 			} else if(returnFalse) {
 				return false;
 			}
 		}

 		public function mouseJustPressedTimeInTicks(click:String):Dynamic {
 			/**
 			 * Time in ticks of last click input mouse button press.
 			 */
 			var clicker:String = click.toLowerCase();
 			var right:Bool = switch(clicker) case 'right' | 'rightclick': true default: false;
 			var left:Bool = switch(clicker) case 'left' | 'leftclick': true default: false;
 			var middle:Bool = switch(clicker) case 'middle' | 'middleclick': true default: false;

 			if(right) {
 				return FlxG.mouse.justPressedTimeInTicksRight;
 			} else if (left) {
 				return FlxG.mouse.justPressedTimeInTicks;
 			} else if (middle) {
 				return FlxG.mouse.justPressedTimeInTicksMiddle;
 			}
 		}

	}

	class Colors
	{
		class NewFlxColor extends FlxColor
		{
			public function returnColor(color:String):FlxColor {
				var returnColor:FlxColor;
				var colors:Array<Array<String><FlxColor>> = [
					["transparent", 0x00000000],
					['white', 0xFFFFFFFF],
					['gray', 0xFF808080],
					['black', 0xFF000000],
					['green', 0xFF008000],
					['lime', 0xFF00FF00],
					["yellow", 0xFFFFFF00],
					['orange', 0xFFFFA500],
					['red', 0xFFFF0000],
					['purple', 0xFF800080]
				]; //please, fill up this with colors
				for (i in colors) {
					if (colors[i][0].toLowerCase() == color.toLowerCase()) {
						return colors[i][1];
					}
				}
				return 0x00000000; //in case that it didnt found any color, return transparent
				/*switch(color.toUpperCase()) {
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
						returnColor = 0x00000000; //in case there isn't any color, it will return transparent
				}
				return returnColor;*/
			}

		}

		class NewColorTransform extends ColorTransform extends FlxColorTransformUtil
		{
			// to use this do this:
			// new(redMultiplier:Float = 1, greenMultiplier:Float = 1, blueMultiplier:Float = 1, alphaMultiplier:Float = 1, redOffset:Float = 0, greenOffset:Float = 0, blueOffset:Float = 0, alphaOffset:Float = 0)
			public function offsetOrMultiplier(transform:ColorTransform, multiplier:Bool, type:String, ?set:Bool = false, ?setRedValue:Float, ?setBlueValue:Float, ?setAlphaValue:Float, ?setGreenValue:Float):Dynamic {
				var color:ColorTransform = transform;
				var type_:String = type.toLowerCase();
				var alpha:Bool = switch(type_) {
					case 'alpha': true;
					default: false;
				}
				var blue:Bool = switch(type_) {
					case 'blue': true;
					default: false;
				}
				var red:Bool = switch(type_) {
					case 'red': true;
					default: false;
				}
				var green:Bool = switch(type_) {
					case 'green': true;
					default: false;
				}
				if(!set) {
					if(alpha) {
						if(!multiplier) {
							return color.alphaOffset;
						} else {
							return color.alphaMultiplier;
						}
					} else if(blue) {
						if(!multiplier) {
							return color.blueOffset;
						} else {
							return color.blueMultiplier;
						}
					} else if(red) {
						if(!multiplier) {
							return color.redOffset;
						} else {
							return color.redMultiplier;
						}
					} else if(green) {
						if(!multiplier) {
							return color.greenOffset;
						} else {
							return color.greenMultiplier;
						}
					}
				} else {
					if(!multiplier) {
						return color.setOffsets(color, setRedValue, setGreenValue, setBlueValue, setAlphaValue);
					} else {
						return color.setMultipliers(color, setRedValue, setGreenValue, setBlueValue, setAlphaValue);
					}
				}
			}

		}

		//class ColorsInGeneral extends NewColorTransform extends NewFlxColor {} //for having all the functions in one single class
	}

	class FlxMoreText extends FlxText
	{
		public function clearFormat(flxText:FlxText):Void {
			flxText.clearFormat();
		}

		public function border(text:FlxText, type:String/*, ?set:Bool, ?setValue:Float*/) { // i'll finish it in home
			var t:String = type.toLowerCase();
			var color:Bool = switch(t) {
				case 'color': true;
				default: false;
			}
			var qua:Bool = switch(t) {
				case 'quality': true;
				default: false;
			}
			var size:Bool = switch(t) {
				case 'size': true;
				default: false;
			}
			var style:Bool = switch(t) {
				case 'style': true;
				default: false;
			}
			if(color) {
				return text.borderColor;
			} else if(qua) {
				return text.borderQuality;
			} else if(size) {
				return text.borderSize;
			} else if(style) {
				return text.borderStyle;
			}
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
			public function getWidthHeight(camera:Camera, returnWidth:Bool, ?returnHeight:Bool = false):Dynamic {
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

	class NewFlxTypedEmitter extends FlxTypedEmitter
	{
		public function setDefaultAngularThings(typedEmitter:FlxTypedEmitter, angularThing:String):Dynamic {
			var acceleration:Bool = switch(angularThing.toLowerCase()) {
				case 'acceleration' | 'angularacceleration': true;
				default: false;
			}
			var drag:Bool = switch(angularThing.toLowerCase()) {
				case 'drag' | 'angulardrag': true;
				default: false;
			}
			var velocity:Bool = switch(angularThing.toLowerCase()) {
				case 'velocity' | 'angularvelocity': true;
				default: false;
			}
			if(acceleration) {
				typedEmitter.angularAcceleration;
			} else if(drag) {
				typedEmitter.angularDrag;
			} else if(velocity) {
				typedEmitter.angularVelocity;
			}
		}
	}

	class NewLoader
	{
		class NewLoaderInfo extends LoaderInfo
		{
			public function getBytes(loader:LoaderInfo, /*i dont know*/type:String):Dynamic {
				var loaded:Bool = switch(type.loLowerCase()) {
					case 'loaded' | 'bytesloaded': true;
					default: false;
				}
				var normal:Bool = switch(type.loTowerCase()) {
					case 'bytes' | 'normal': true;
					default: false;
				}
				var total:Bool = switch(type.toLowerCase()) {
					case 'total' | 'bytestotal': true;
					default: false;
				}
				if(loaded) {
					return loader.bytesLoaded; //returns an Int
				} else if(normal) {
					return loader.bytes; //returns a ByteArray
				} else if(total) {
					return loader.bytesTotal; //returns an Int
				}
			}
		}
	}
	
	
	
	
	
	
	
	
}
