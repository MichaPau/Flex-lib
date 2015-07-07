package michaPau.utils.astronomy.helper
{
	public class Latitude
	{
		public var degree:Number;
		
		public function Latitude(value:Number) {
			if(value > 90 || value < -90)
				throw new Error("[Latitude] value out of bounds (max. -90 to 90)");
			
			degree = value;
			
		}
		
		public function toRadian():Number {
			return degree*(Math.PI/180);
		}
		public function toString():String {
			if(degree > 0)
				return degree + "° N";
			else if(degree < 0)
				return (degree*-1) + "° S";
			else 
				return "0°";
		}
	}
}