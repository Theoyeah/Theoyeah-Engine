package;

//HaxeFlixel API Packages
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flash.media.Camera;
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
import openfl.AssetType;
import openfl.AssetLibrary;
import flixel.system.FlxAssets.FlxShader;
import openfl.display.BitmapData;
import openfl.display.Shader;
import flixel.system.Shader;
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
import flixel.effects.particles.FlxEmmiter;
import flixel.effects.particles.FlxTypedEmitter;
import flixel.effects.postprocess.PostProcess;
import flixel.system.FlxAssets;
import flixel.util.FlxSave;
import flixel.util.FlxPath;
import flixel.util.FlxTimer;
import flixel.FlxState;
import flixel.FlxSubState;

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

	class Figures //i dont know english :'<
	{
		class NewRectangle extends Rectangle
		{
			//to create a rectangle use this new(x:Float = 0, y:Float = 0, width:Float = 0, height:Float = 0)
			public function getWidthOrHeight(figure:Rectangle, returnWidth:Bool, ?returnHeight:Bool) {
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
		
		public function mousePressed(click:String, ?returnFalse:Bool = false) {
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

 		public function mouseJustPressedTimeInTicks(click:String) {
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
		
	class NewFlxTypedEmitter extends FlxTypedEmitter
	{
		public function setDefaultAngularThings(typedEmitter:FlxTypedEmitter, angularThing:String) {
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
	
	
	
	
	
	
	
	
	
	
}
