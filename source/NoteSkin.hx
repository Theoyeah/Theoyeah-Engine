package;


using StringTools;

class NoteSkin
{
	inline public function noteSkin():String {
		var skin:String = PlayState.SONG.arrowSkin;
		if((skin == null || skin == '') && ClientPrefs.noteskin != 'Arrows') {
			switch(ClientPrefs.noteskin.toLowerCase().trim()) {
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
	
	var noteSkinB:Void->String = function():String return noteSkin();

	public var noteSkinPlay:Bool = if((noteSkin().length > 0 || noteSkin() != null) && noteSkin() != PlayState.SONG.arrowSkin) true else false;

	public function noteSkinFile(folder:Bool = true) {
		if(folder) {
			if(reloadNoteSkinPlay())
				return 'noteSkins/NOTE_assets' + noteSkin();
			return 'noteSkins/NOTE_assets';
		} else if(reloadNoteSkinPlay())
			return 'NOTE_assets' + noteSkin();
		return 'NOTE_assets';
	}


	public function reloadNoteSkinPlay() {
		noteSkinPlay = if((noteSkin().length > 0 || noteSkin() != null) && noteSkin() != PlayState.SONG.arrowSkin) true else false;
		return noteSkinPlay;
	}

}
