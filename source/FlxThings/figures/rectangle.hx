class NewRectangle extends Rectangle
{
	//to create a rectangle use this new(x:Float = 0, y:Float = 0, width:Float = 0, height:Float = 0)
	public function getWidthOrHeight(figure:Rectangle, returnWidth:Bool, ?returnHeight:Bool):Dynamic {
		var heightt:Bool = if(returnWidth) false else true;
		var widthh:Bool = if(returnHeight) false else true;
		var theTwoOfUs:Bool if(returnHeight && returnWidth) true else false;
		if(!theTwoOfUs) {
			if(widthh) {
				return figure.width;
			} else if(heightt) {
				return figure.height;
			}
		}
	}

}
		
