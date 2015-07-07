package michaPau.utils
{
	public class ColorUtils
	{
		public function ColorUtils()
		{
		}
		
		public static function getBlackOrWhiteContrast(_forColor:uint, _whiteBrightnessLimit:Number = 90):uint {
			var red:Number = (_forColor >> 16 ) & 0xff;
			var green:Number = (_forColor >> 8 ) & 0xff;
			var blue:Number = (_forColor & 0xff );
			
			var brightness:Number = ((red * 299) + (green * 587) + (blue * 114)) / 1000;
			
			var returnColor:uint = 0x000000;
			
			if(brightness <= 90) {
				returnColor = 0xFFFFFF;
			}
			return returnColor;
		}
	}
}