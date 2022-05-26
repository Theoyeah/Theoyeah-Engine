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
	public static function noteSkinFile(folder:Bool = true) {
		if(folder) {
			if((noteSkin() != null || noteSkin().length > 0) && noteSkin() != PlayState.SONG.arrowSkin) {
				return 'noteSkins/NOTE_assets' + noteSkin();
			} else {
				return 'noteSkins/NOTE_assets';
		} else {
			if(noteSkin().length > 0 || noteSkin() != null) {
				return 'NOTE_assets' + noteSkin();
			} else {
				return 'NOTE_assets';
			}
		}
	}
}
