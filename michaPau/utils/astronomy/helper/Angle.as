package michaPau.utils.astronomy.helper
{
	import michaPau.utils.astronomy.CommonUtils;
	import michaPau.utils.astronomy.TimeUtils;

	public class Angle
	{
		public var degrees:int;
		public var minutes:int;
		public var seconds:Number;
		
		public function Angle(d:int = 0, m:int = 0, s:Number = 0) {
			degrees = d;
			minutes = m;
			seconds = s;
		}
		
		public function getDecimalValue():Number {
			var result:Number = Math.abs(degrees) + minutes/60 + seconds/3600;
			
			if(degrees < 0)
				result *= -1;
			
			return result;
		}
		public function getAngleInHours():Time {
			var dT:Number = getDecimalValue()/15;
			return TimeUtils.decimalHoursToTime(dT);
		}
		public function setFromDecimalDegree(value:Number):void {
			degrees = CommonUtils.getIntValue(value);
			var dRest:Number = CommonUtils.shearFraction(Math.abs(value));
			var m:Number = dRest * 60;
			minutes = CommonUtils.getIntValue(m);
			var mRest:Number = CommonUtils.shearFraction(m)*60;
			seconds = toPrecision(mRest, 2);
		}
		
		public function toString(decimal:Boolean = false):String {
			if(decimal)
				return getDecimalValue() + "°";
			else 
				return degrees + "° " + minutes + "' " + seconds + "''";
		}
		
		private function toPrecision(number:Number, precision:int):Number {
			precision = Math.pow(10, precision);
			return Math.round(number * precision)/precision;
		}
	}
}