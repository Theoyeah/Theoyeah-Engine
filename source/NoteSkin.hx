package;


using StringTools;

class NoteSkin extends Note extends StrumNote extends NoteSplash
{
	public static function noteSkin():String {
		var skin:String = PlayState.SONG.arrowSkin;
		if((skin == null || skin == '' || skin.length < 1) && ClientPrefs.noteskin != 'Arrows') {
			switch(ClientPrefs.noteskin.toLowerCase()) {
				case 'circles':
					skin = '-Circles';
				default:
					skin = '';
			}
		}
		return skin;
	}
	public static function noteSkinFile(folder:Bool = true) {
		if(folder) {
			if(noteSkin() != PlayState.SONG.arrowSkin) {
				return 'noteSkins/NOTE_assets' + noteSkin();
			}
		} else {
			return 'NOTE_assets' + noteSkin();
		}
	}
}
