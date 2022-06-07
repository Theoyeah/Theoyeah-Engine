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

class NewFlxShapeCross extends FlxShapeCross
{
	public function horizontalVertical(flxShape:FlxShapeCross, horizontal:Bool, length:Bool, ?set:Bool = false, ?valueSet:Float):Dynamic {
		var flx:FlxShapeCross = flxShape;
		if(horizontal) {
			if(set) {
				if(length) {
					flx.horizontalLength = valueSet;
				} else {
					flx.horizontalThickness = valueSet;
				}
			} else {
				if(length) {
					return flx.horizontalLength;
				} else {
					return flx.horizontalThickness;
				}
			}
		} else {
			if(set) {
				if(length) {
					flx.verticalLength = valueSet;
				} else {
					flx.verticalThickness = valueSet;
				}
			} else {
				if(length) {
					return flx.verticalLength;
				} else {
					return flx.verticalThickness;
				}
			}
		}
	}

}
