package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

class NoteSplash extends FlxSprite
{
	public var colorSwap:ColorSwap = null;
	private var idleAnim:String;
	private var textureLoaded:String = null;

	public static function noteS():String { // from noteSplashes
		var hola:String = 'noteSplashes';
		switch(ClientPrefs.noteSplashes.toLowerCase()) {
			case 'inverted': hola = 'inverted';
			case 'red': hola = 'red';
			case 'cyan': hola = 'cyan';
			case 'green': hola = 'green';
			case 'pink': hola = 'pink';
			case 'idk': hola = 'idk';
			case 'original': hola = 'og';
			case 'green original': hola = 'og green';
			case 'blue original': hola = 'og blue';
			case 'pink original': hola = 'og pink';
			case 'purple original': hola = 'og purple';
			case 'idk original': hola = 'og idk';
			default: hola = 'noteSplashes';
		}
		var holaQue:String = StringTools.replace(" ", hola, '_');
		if(hola != 'noteSplashes') {
			return holaQue.toLowerCase() + '_noteSplashes';
		} else {
			return holaQue;
		}
	}

	/**
	 * Generates a noteSplash
	 * @param x x
	 * @param y y
	 * @param note what note is (in numbers)
	 */
	public function new(x:Float = 0, y:Float = 0, ?note:Int = 0) {
		super(x, y);

		var skin:String = noteS();
		if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0 && PlayState.SONG.splashSkin != 'noteSplashes') skin = PlayState.SONG.splashSkin;

		loadAnims(skin);
		
		colorSwap = new ColorSwap();
		shader = colorSwap.shader;

		setupNoteSplash(x, y, note);
		antialiasing = ClientPrefs.globalAntialiasing;
	}

	public function setupNoteSplash(x:Float, y:Float, note:Int = 0, texture:String = null, hueColor:Float = 0, satColor:Float = 0, brtColor:Float = 0) {
		setPosition(x - Note.swagWidth * 0.95, y - Note.swagWidth);
		alpha = 0.6;

		if(texture == null) {
			texture = noteS();
			if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0 && PlayState.SONG.splashSkin != 'noteSplashes') texture = PlayState.SONG.splashSkin;
		}

		if(textureLoaded != texture) {
			loadAnims(texture);
		}
		colorSwap.hue = hueColor;
		colorSwap.saturation = satColor;
		colorSwap.brightness = brtColor;
		if(StringTools.startsWith(texture, 'og')) {
			offset.set(80, 90);
		} else {
			offset.set(10, 10);
		}
		var animNum:Int = FlxG.random.int(1, 2);
		animation.play('note' + note + '-' + animNum, true);
		if(animation.curAnim != null) animation.curAnim.frameRate = 24 + FlxG.random.int(-2, 2);
	}

	function loadAnims(skin:String) {
		frames = Paths.getSparrowAtlas('noteSplashes/' + skin);
		for (i in 1...3) {
			animation.addByPrefix("note1-" + i, "note splash blue " + i, 24, false);
			animation.addByPrefix("note2-" + i, "note splash green " + i, 24, false);
			animation.addByPrefix("note0-" + i, "note splash purple " + i, 24, false);
			animation.addByPrefix("note3-" + i, "note splash red " + i, 24, false);
		}
	}

	override function update(elapsed:Float) {
		if(animation.curAnim != null)if(animation.curAnim.finished) kill();

		super.update(elapsed);
	}
}
