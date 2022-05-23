package flxthings.random;

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
class Random {
	public static inline function bool():Bool
 	{
 		return Math.random() < 0.5;
 	}

 	public static inline function int(from:Int, to:Int):Int
 	{
 		return from + Math.floor(((to - from) * Math.random()));
 	}

 	public static inline function float(from:Float, to:Float):Float
 	{
 		return from + ((to - from) * Math.random());
 	}

 	public static inline function fromArray<T>(arr:Array<T>):Null<T>
 	{
 		return (arr != null && arr.length > 0) ? arr[int(0, arr.length - 1)] : null;
 	}
}
