package flxthings.figures;

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

class Circumference
{
	public function getPerimeter(radius:Float):Float {
		return Math.PI * 2 * radius;
	}
	public function getLengthRadius(radius:Float, numberOfDegrees:Float):Float {
		return (Math.PI * 2* radius * numberOfDegrees) / 360;
	}
	public function getArea(value:Float, ?radius:Bool = true):Float {
		var v:Float = if(!radius) value / 2 else value;
		return Math.PI * Math.pow(v, 2);
	}
	public function getAreaFromPerimeter(p:Float) {
		return getArea(p / (Math.PI * 2), true);
	}
}
