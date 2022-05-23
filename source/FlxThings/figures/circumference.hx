
class Circumference
{
	public function getPerimeter(radius:Float):Float {
		return Math.PI * 2 * radius;
	}
	public function getLengthRadius(radius:Float, numberOfDegrees:Float):Float {
		return (Math.PI * 2* radius * numberOfDegrees) / 360;
	}
	public function getArea(value:Float, ?radius:Bool = true):Float {
		var v:Float = if(!radius) value / 2 else value;
		return Math.PI * Math.pow(v, 2);
	}
	public function getAreaFromPerimeter(p:Float) {
		return getArea(p / (Math.PI * 2), true);
	}
}
