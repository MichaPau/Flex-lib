package michaPau.utils
{
	public class MathUtils
	{
		public function MathUtils()
		{
		}
		
		public static function randomRange(_min:Number, _max:Number):Number {
			return Math.floor(Math.random() * (1 + _max - _min)) + _min;
		}
		public static function toFixed(number:Number, precision:Number):Number {
			precision = Math.pow(10, precision);
			return (Math.round(number * precision)/precision);
		}
	}
}