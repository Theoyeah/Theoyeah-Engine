/* ok, this file modifies all the freaking files, this files have acces to ALL the files that you'll need for the
freaking future, and also this file is for more useful functions for you to use, only use "import FlxThings" to import
thisfile, and then use the classes that are down, like "Random.int(0, 7)" to use the "int()" function of the "Random"
class, also use this method to all the other classes, bye!
*/
package flxthings;

//HaxeFlixel API Packages
import flixel.effects.particles.FlxEmitter;
import flash.display.LoaderInfo;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
//import flash.media.Camera;
import flixel.FlxObject;
import flixel.FlxCamera;
import flash.media.SoundChannel;
import flixel.input.FlxPointer;
import flixel.util.FlxDestroyUtil;
import openfl.geom.Rectangle;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import openfl.Assets;
import haxe.Json;
import flixel.input.mouse.FlxMouse;
import flixel.addons.ui.FlxUIMouse;
import flash.display.Sprite;
import flash.system.System;
import lime.app.Application;
import flixel.text.FlxText;
import openfl.filters.BitmapFilter;
import openfl.filters.ShaderFilter;
import openfl.Vector;
import openfl.Assets;
import openfl.utils.AssetType;
import openfl.utils.AssetLibrary;
import flixel.system.FlxAssets.FlxShader;
import openfl.display.BitmapData;
import openfl.display.Shader;
//import flixel.system.Shader;
import openfl.display.ShaderInput;
import openfl.utils.Assets;
import flixel.FlxG;
import openfl.Lib;
import flixel.graphics.FlxGraphic;
import flixel.animation.FlxAnimation;
import flixel.FlxBasic;
import flixel.system.FlxSound;
import flixel.util.FlxStringUtil;
import flixel.effects.FlxFlicker;
import flixel.effects.particles.FlxParticle;
//import flixel.effects.particles.FlxEmmiter;
//import flixel.effects.particles.FlxTypedEmitter;
import flixel.effects.postprocess.PostProcess;
import flixel.system.FlxAssets;
import flixel.util.FlxSave;
import flixel.util.FlxPath;
import flixel.util.FlxTimer;
import flixel.FlxState;
import flixel.FlxSubState;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.geom.ColorTransform;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.FlxBasic.IFlxBasic;
import flixel.animation.FlxAnimationController;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.graphics.frames.FlxTileFrames;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxBitmapDataUtil;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxDirectionFlags;

using StringTools;
using flixel.util.FlxColorTransformUtil;

/*
stoled from HaxeFlixel api Docs!! But better!
*/
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
		public var howMany:Array<FlxSprite> = [];

		override public function new(?x:Float = 0, ?y:Float = 0, ?graphic:Null<FlxGraphicAsset>):FlxSprite {
			super(x, y, graphic);
			howMany.push(this);
		}
		public function titleSprite(sprite:FlxSprite, graphicSize:Int = Std.int(sprite.width * 0.8), antialiasing:Bool = true):Void {
			sprite.visible = false;
			sprite.setGraphicSize(graphicSize);
			sprite.updateHitbox();
			sprite.screenCenter(X);
			if(antialiasing) {
				sprite.antialiasing = ClientPrefs.globalAntialiasing;
			}
		}
		public function resetSprite(sprite:FlxSprite) {
			sprite.origin;
			if(sprite.flipY) sprite.flipY;
			if(sprite.flipX) sprite.flipX;
			sprite.centerOrigin;
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

	class Dates
	{
		/**
		 * Returns a random date
		 * @return Date
		 */
		public function returnRandomDate():Date {
			var fuck:Date = new Date(flxthings.Random.int(0, 10000), flxthings.Random.int(0, 11), flxthings.Random.int(1, 31), flxthings.Random.int(0, 23), flxthings.Random.int(0, 59), flxthings.Random.int(0, 59));
			return fuck;
		}

	}

	//class Colors
	//{
	class NewFlxColor
		{
			/**
			 * returns the color of the string gived
			 * @param color 
			 * @return `FlxColor`
			 */
			public function returnColor(color:String):FlxColor {
				var wtf:FlxColor = FlxColor.fromCMYK(Math.random(), Math.random(), Math.random(), Math.random(), 1);
				var c:String = color.toLowerCase().replace('-', '').replace('_', '').replace('.', '').replace(',', '');
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
				var isHere:Dynamic = 0x00000000;
				for (i in colors) {
					if(colors[i][2] != null) { //in case that the color can be called in two different ways
						if(colors[i][1].toLowerCase() == c || colors[i][0].toLowerCase() == c) {
							isHere = colors[i][2];
							break;
						}
					}
					if (colors[i][0].toLowerCase() == c) {
						isHere = colors[i][1];
						break;
					}
				}
				return isHere; //in case that it didn't found any color, return transparent
			}

		}

		class NewColorTransform extends ColorTransform
		{
			// to use this do this:
			// new(redMultiplier:Float = 1, greenMultiplier:Float = 1, blueMultiplier:Float = 1, alphaMultiplier:Float = 1, redOffset:Float = 0, greenOffset:Float = 0, blueOffset:Float = 0, alphaOffset:Float = 0)
			public function offsetOrMultiplier(transform:ColorTransform, multiplier:Bool, type:String, ?set:Bool = false, ?setRedValue:Float = 0, ?setBlueValue:Float = 0, ?setAlphaValue:Float = 0, ?setGreenValue:Float = 0):Dynamic {
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
						if(!multiplier)
							return color.alphaOffset;
						return color.alphaMultiplier;
					} else if(blue) {
						if(!multiplier)
							return color.blueOffset;
						return color.blueMultiplier;
					} else if(red) {
						if(!multiplier)
							return color.redOffset;
						return color.redMultiplier;
					} else if(green) {
						if(!multiplier)
							return color.greenOffset;
						return color.greenMultiplier;
					}
				} else if(!multiplier)
					return color.setOffsets(color, setRedValue, setGreenValue, setBlueValue, setAlphaValue);
				return color.setMultipliers(color, setRedValue, setGreenValue, setBlueValue, setAlphaValue);
			}

		}

	class FlxMoreText extends FlxText
	{
		public function deleteStupidCharacters(s:String, toCase:Int = 0, firstToLowerCase:Bool = true, otherCharacter:String = '') {// 1 is lower case, 2 is upper case
			var r:String = '';
			var string:String = s;
			if(firstToLowerCase)
				string = s.toLowerCase();
			r = string.replace('"', '').replace("'", '').replace('-', '').replace('_', '').replace('.', '').replace(',', '').replace('*', '').replace('&', '').replace('#', '').replace('@', '').replace("$", '').replace('^', '').replace('£', '').replace('º', '').replace('%', '').replace('€', '').replace(otherCharacters, '');
			switch(toCase) {
				case 1:
					return r.toLowerCase();
				case 2:
					return r.toUpperCase();
			}
			return r;
		}

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
			if(color)
				return text.borderColor;
			else if(qua)
				return text.borderQuality;
			else if(size)
				return text.borderSize;
			return text.borderStyle;
		}

	}

	class NewSoundChannel
	{
		/*public function getPosition(sound:IEventDispatcher, ?returnPositionIfIsLeft:Bool = false, ?returnPositionIfIsRight:Bool = false):Float {
			if (returnPositionIfIsLeft)
				return sound.leftPeak;
			else if(returnPositionIfIsRight)
				return sound.rightPeak;
			return sound.position;
		}*/

	}

	/*class NewFlxTypedEmitter extends FlxTypedEmitter<T>
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
			if(acceleration)
				typedEmitter.angularAcceleration;
			else if(drag)
				typedEmitter.angularDrag;
			typedEmitter.angularVelocity;
		}
	}*/

	class NewLoaderInfo extends flash.display.LoaderInfo
	{
		public function getBytes(loader:Dynamic, type:String):Dynamic {
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
			if(loaded)
				return loader.bytesLoaded; //returns an Int
			else if(normal)
				return loader.bytes; //returns a ByteArray
			return loader.bytesTotal; //returns an Int
			
		}
	}
	//}
	
	
	
	
	
	
	
	
//}
