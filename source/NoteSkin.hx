package;


using StringTools;

class NoteSkin
{
	inline public static function noteSkin():String {
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

	inline public static function noteSkinFile(folder:Bool = true) {
		if(folder) {
			if(reloadNoteSkinPlay()) {
				return 'noteSkins/NOTE_assets' + noteSkin();
			} else {
				return 'noteSkins/NOTE_assets';
			}
		} else {
			if(reloadNoteSkinPlay()) {
				return 'NOTE_assets' + noteSkin();
			} else {
				return 'NOTE_assets';
			}
		}
	}


	inline public static function reloadNoteSkinPlay() {
		noteSkinPlay = if((noteSkin().length > 0 || noteSkin() != null) && noteSkin() != PlayState.SONG.arrowSkin) true else false;
		return noteSkinPlay;
	}

}
