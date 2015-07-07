package michaPau.utils.astronomy.helper
{
	public class Longitude
	{
		public var degree:Number;
		
		public function Longitude(value:Number) {
			degree = value;
			
		}
		
		public function toRadian():Number {
			return degree*(Math.PI/180);
		}
		
		public function toString():String {
			if(degree > 0)
				return degree + "° E";
			else if(degree < 0)
				return (degree*-1) + "° W";
			else 
				return "0°";
		}
		
		
	}
}