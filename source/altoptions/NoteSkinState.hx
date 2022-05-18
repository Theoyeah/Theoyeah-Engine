package altoptions;

import sys.FileSystem;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.group.FlxGroup;
import flixel.addons.text.FlxTypeText;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.math.FlxMath;
import flixel.util.FlxColor;

using StringTools;

class NoteSkinState extends MusicBeatState {

    private var grpSkins:FlxTypedGroup<Alphabet>;
    private var skinText:Alphabet;
    private var helpText:FlxText;
    public static var curSelected:Int = 0;

    var bg:FlxSprite;
    var camFollow:FlxObject;
    var camFollowPos:FlxObject;
    var skinList:Array<Dynamic> = [];

    override function create() {

        bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);
		bg.screenCenter();

		// camFollow = new FlxObject(0, 0, 1, 1);
		// camFollowPos = new FlxObject(0, 0, 1, 1);
		// add(camFollow);
		// add(camFollowPos);

        // FlxG.camera.follow(camFollowPos, null, 1);

        grpSkins = new FlxTypedGroup<Alphabet>();
		add(grpSkins);

        var path:String = 'assets/shared/images/playerSkins/';

        if(FileSystem.exists(path)) {
            trace("Note skins found");
            for(file in FileSystem.readDirectory(path)) {
                if(StringTools.contains(file, '.xml')) {
                    var skinName = StringTools.replace(file, ".xml", "");
                    trace('Found note skin ' + skinName);
                    skinList.push(skinName);

                }
            }
        }
        else {
            trace("No note skins found");
        }

        // for(i in 0...skinList.length) {
        //     // Make flixel text
        //     var skinName = skinList[i];
        //     var skinText = new Alphabet(0, (70 * i) + 30, skinName, true, false);
        //     skinText.isMenuItem = true;
        //     skinText.targetY = i;
        //     grpSkins.add(skinText);
        // }

        skinText = new Alphabet(0, 100, skinList[curSelected], true, false);
        skinText.isMenuItem = true;
        skinText.screenCenter();
        grpSkins.add(skinText);

        helpText = new FlxText((FlxG.width/2) - 300, (FlxG.height/2) + 100, FlxG.width, "Use the up and down arrow keys to select a skin. Press enter to select.");
        helpText.scrollFactor.set();
        helpText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        add(helpText);
    }    


    override function update(elapsed:Float) {
        var downP = controls.UI_DOWN_P;
        var upP = controls.UI_UP_P;
        var accepted = controls.ACCEPT;

        if(downP) {
            changeSkin();
        }
        else if(upP) {
            changeSkin(false);
        }
        if(accepted) {
            acceptSkin();
        }
    }

    function changeSkin(down:Bool = true) {
        if(down) {   
            curSelected++;
        }
        else {
            curSelected--;
        }    
        if(curSelected >= skinList.length) {
            curSelected = 0;
        }
        else if(curSelected < 0) {
            curSelected = skinList.length - 1;
        }
        skinText.changeText(skinList[curSelected]);
    }

    function acceptSkin() {
        var skinName = skinList[curSelected];
        FlxG.save.data.arrowSkin = 'noteSkins\x2f'+skinName;
        trace(FlxG.save.data.arrowSkin);
        MusicBeatState.switchState(new altoptions.PauseOptionsState());
    }
} 