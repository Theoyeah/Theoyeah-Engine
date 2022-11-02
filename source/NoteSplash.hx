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

	public static function noteS(?skin:String):String { // from noteSplashes
		var hola:String = 'noteSplashes';
		var notesplash:String = if(skin == null) ClientPrefs.noteSplashes.toLowerCase() else skin.toLowerCase();
		switch(notesplash) {
			case 'original': hola = 'og';
			case 'inverted' | 'red' | 'cyan' | 'green' | 'pink' | 'idk' | 'saturated': hola = ClientPrefs.noteSplashes.toLowerCase();
		}
		if(hola != 'noteSplashes') return hola.toLowerCase() + '_noteSplashes';
		return hola;
	}

	/**
	 * Generates a noteSplash
	 * @param x x
	 * @param y y
	 * @param note what note is (in numbers)
	 */
	public function new(x:Float = 0, y:Float = 0, ?note:Int = 0, animationsCount:Int = 3) {
		super(x, y);

		var skin:String = noteS();
		if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0 && PlayState.SONG.splashSkin != 'noteSplashes') skin = PlayState.SONG.splashSkin;

		loadAnims(skin, animationsCount);

		colorSwap = new ColorSwap();
		shader = colorSwap.shader;

		setupNoteSplash(x, y, note, null, 0, 0, 0, animationsCount);
		antialiasing = ClientPrefs.globalAntialiasing;
	}

	public function setupNoteSplash(x:Float, y:Float, note:Int = 0, texture:String = null, hueColor:Float = 0, satColor:Float = 0, brtColor:Float = 0, animationsCount:Int = 3) {
		setPosition(x - Note.swagWidth * 0.95, y - Note.swagWidth);
		alpha = 0.6;

		if(texture == null || texture.length < 1) {
			texture = noteS();
			if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0 && PlayState.SONG.splashSkin != 'noteSplashes') texture = PlayState.SONG.splashSkin;
		}

		if(textureLoaded != texture) {
			loadAnims(texture, animationsCount);
		}
		colorSwap.hue = hueColor;
		colorSwap.saturation = satColor;
		colorSwap.brightness = brtColor;
		if(texture.endsWith('og_noteSplashes')) {
			offset.set(Std.int(0.3 * width), Std.int(0.3 * height));
		} else {
			offset.set(10, 10);
		}
		var animNum:Int = FlxG.random.int(1, 2);
		animation.play('note' + note + '-' + animNum, true);
		if(animation.curAnim != null) animation.curAnim.frameRate = 24 + FlxG.random.int(-2, 2);
	}

	function loadAnims(skin:String, animationsCount:Int = 3) {
		frames = Paths.getSparrowAtlas((skin.startsWith('noteSplashes/') || skin.startsWith('noteskins/')) ? skin : 'noteSplashes/' + skin);
		for (i in 1...animationsCount) {
			animation.addByPrefix("note0-" + i, "note splash purple " + i, 24, false);
			animation.addByPrefix("note1-" + i, "note splash blue " + i, 24, false);
			animation.addByPrefix("note2-" + i, "note splash green " + i, 24, false);
			animation.addByPrefix("note3-" + i, "note splash red " + i, 24, false);
		}
	}

	override function update(elapsed:Float) {
		if(animation.curAnim != null && animation.curAnim.finished) kill();

		super.update(elapsed);
	}
}
