/* ok, this file modifies all the freaking files, this files have acces to ALL the files that you'll need for the
freaking future, and also this file is for more useful functions for you to use, only use "import FlxThings" to import
thisfile, and then use the classes that are down, like "Random.int(0, 7)" to use the "int()" function of the "Random"
class, also use this method to all the other classes, bye!
*/
package flxthings;

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
stoled from HaxeFlixel Docs!! But better!
*/
//class FlxThings
//{
	//var nothing:Dynamic;

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
		public function titleSprite(sprite:FlxSprite, graphicSize:Int = Std.int(sprite.width * 0.8), antialiasing:Bool = true):Void {
			sprite.visible = false;
			sprite.setGraphicSize(graphicSize);
			sprite.updateHitbox();
			sprite.screenCenter(X);
			if(antialiasing) {
				sprite.antialiasing = ClientPrefs.globalAntialiasing;
			}
		}
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

	class Dates extends Date
	{
		public function returnRandomDate():Date {
			var fuck:Date = new Date(flxthings.Random.int(0, 10000), flxthings.Random.int(0, 11), flxthings.Random.int(1, 31), flxthings.Random.int(0, 23), flxthings.Random.int(0, 59), flxthings.Random.int(0, 59));
			return fuck;
		}

	}

	//class Colors
	//{
		class NewFlxColor extends FlxColor
		{
			/**
			 * returns the color of the string gived
			 * @param color 
			 * @return `FlxColor`
			 */
			public function returnColor(color:String):FlxColor {
				var wtf:FlxColor = FlxColor.fromCMYK(Math.random(), Math.random(), Math.random(), Math.random(), 1);
				var colors:Array<Array<Dynamic>> = [
					//[name,    flxColor or other name,     flxColor in case that other name],
					["transparent", 0x00000000],
					['white', 0xFFFFFFFF],
					['gray', 0xFF808080],
					['black', 0xFF000000],
					['green', 0xFF008000],
					['lime', 0xFF00FF00],
					["yellow", 0xFFFFFF00],
					['orange', 0xFFFFA500],
					['red', 'blood', 0xFFFF0000],
					['purple', 0xFF800080],
					['blue', 0xFF0000FF],
					['brown', 0xFF8B4513],
					['pink', 0xFFFFC0CB],
					['magenta', 0xFFFF00FF],
					['cyan', 0xFF00FFFF],
					
					
					['wtf', 'random', wtf]
				]; //please, fill up this with colors
				// down is the code shit
				for (i in colors) {
					if(colors[i][2] != null) { //in case that the color can be called in two different ways
						if(colors[i][1].toLowerCase() == color.toLowerCase() || colors[i][0].toLowerCase() == color.toLowerCase()) {
							return colors[i][2];
						}
					}
					if (colors[i][0].toLowerCase() == color.toLowerCase()) {
						return colors[i][1];
					}
				}
				return 0x00000000; //in case that it didn't found any color, return transparent
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
	//}

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

	/*class NewLoader
	{*/
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
	//}
	
	
	
	
	
	
	
	
//}
