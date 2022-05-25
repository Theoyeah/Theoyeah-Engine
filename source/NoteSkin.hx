package;


using StringTools;

class NoteSkins
{
	public function noteSkin():String {
		var skin:String = PlayState.SONG.arrowSkin;
		if((skin == 'noteSplashes' || skin == '') && ClientPrefs.noteskin != 'Arrows') {
			switch(ClientPrefs.noteskin.toLowerCase()) {
				case 'circles':
					skin = '-Circles';
				default:
					skin = '';
			}
		}
		return skin;
	}
	public function noteSkinFile(folder:Bool = true) {
		if(folder) {
			if(noteSkin() != PlayState.SONG.arrowSkin) {
				return 'noteSkins/NOTE_assets' + noteSkin();
			}
		} else {
			return 'NOTE_assets' + noteSkin();
		}
	}
}
