package michaPau.utils.astronomy
{
	public class CommonUtils
	{
		public static function getIntValue(value:Number):Number {
			
			var result:Number = Math.floor(Math.abs(value));
			if(value < 0)
				return -result;
			else
				return result;
		}
		public static function shearFraction(value:Number):Number {
			return value = value % 1;
		}
		
		public static function toRadian(angle:Number):Number {
			return angle*(Math.PI/180);
		}
		public static function toDegree(radian:Number):Number {
			return radian*(180/Math.PI);
		}
	}
}