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
		
