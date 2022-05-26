package;


using StringTools;

class NoteSkin
{
	public static function noteSkin():String {
		var skin:String = PlayState.SONG.arrowSkin;
		if((skin == null || skin == '') && ClientPrefs.noteskin != 'Arrows') {
			switch(ClientPrefs.noteskin.toLowerCase()) {
				case 'circles':
					skin = '-Circles';
				default:
					skin = '';
			}
		} else {
			skin = PlayState.SONG.arrowSkin;
		}
		return skin;
	}

	public static var noteSkinPlay:Bool = if((noteSkin().length > 0 || noteSkin() != null) && noteSkin() != PlayState.SONG.arrowSkin) true else false;

	public static function noteSkinFile(folder:Bool = true) {
		if(folder) {
			if(noteSkinPlay) {
				return 'noteSkins/NOTE_assets' + noteSkin();
			} else {
				return 'noteSkins/NOTE_assets';
		} else {
			if(noteSkinPlay) {
				return 'NOTE_assets' + noteSkin();
			} else {
				return 'NOTE_assets';
			}
		}
	}
}
