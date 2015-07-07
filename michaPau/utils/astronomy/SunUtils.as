package michaPau.utils.astronomy
{
	import michaPau.utils.astronomy.helper.Angle;
	import michaPau.utils.astronomy.helper.Latitude;
	import michaPau.utils.astronomy.helper.Longitude;
	import michaPau.utils.astronomy.helper.Time;

	public class SunUtils
	{
		//1980
		/*public static var SUN_ECLIPTIC_LONGITUDE:Number = 279.403303;
		public static var SUN_ECLIPTIC_LONGITUDE_PERIGEE:Number = 282.768422;
		public static var SUN_ECCENTRICITY_OF_ORBIT:Number = 0.016713;
		public static var SUN_SEMI_MAJOR_AXIS:Number = 1.495985*Math.pow(10, 8);
		public static var SUN_ANGULAR_DIAMETER:Number = 0.533128;*/
		//2010
		public static var SUN_ECLIPTIC_LONGITUDE:Number = 279.557208;
		public static var SUN_ECLIPTIC_LONGITUDE_PERIGEE:Number = 283.112438;
		public static var SUN_ECCENTRICITY_OF_ORBIT:Number = 0.016705;
		public static var SUN_SEMI_MAJOR_AXIS:Number = 1.495985*Math.pow(10, 8);
		public static var SUN_ANGULAR_DIAMETER:Number = 0.533128;
		/**  
		 *	§ 49 Sunrise and sunset
		 * 
		 * 	@param date
		 * 
		 *  @param latitude the observers latitude
		 * 
		 *  @param longitude the observers longitude
		 *
		 * 	@return a generic object in the form of sunrise: [Time], sunset: [Time]
		 *
		 */
		public static function calculateSunriseAndSunset(date:Date, latitude:Latitude, longitude:Longitude, timeZoneCorrection:Number = 0, dayLightSaving:Boolean = false):Object {
		
			var date1:Date = new Date(date.fullYear, date.month, date.date);
			var result1:Object = calculateSunPosition(date1);
			
			//var asc1:Number = TimeUtils.timeToDecimalHours(result1.rightAscension);
			//var desc1:Number = (result1.declination as Angle).getDecimalValue();
			
			var asc1:Time = result1.rightAscension;
			var decl1:Angle = result1.declination;
			
			var sunLong2:Number = result1.sunLongitude + 0.985647;
			var sunLongAngle:Angle = new Angle();
			sunLongAngle.setFromDecimalDegree(sunLong2);
			
			var result2:Object = CoordinateUtils.convertEcliptic_To_equatorialCoordiante(sunLongAngle, new Angle(0, 0, 0), date.fullYear);
			
			//var asc2:Number = TimeUtils.timeToDecimalHours(result2.rightAscension);
			//var des2:Number = (result2.declination as Angle).getDecimalValue();
			
			var asc2:Time = result2.rightAscension;
			var decl2:Angle = result2.declination;
			
			var rs1Result:Object = CoordinateUtils.getRisingAndSetting(asc1, decl1, date, latitude, longitude);
			var rs2Result:Object = CoordinateUtils.getRisingAndSetting(asc2, decl2, date, latitude, longitude);
			
			if(rs1Result.rising == null || rs2Result.rising == null) {
				return {sunrise: null, sunset: null, visible:rs1Result.visible};
			}
			var gst1R:Number = TimeUtils.timeToDecimalHours(rs1Result.gstR);
			var gst1S:Number = TimeUtils.timeToDecimalHours(rs1Result.gstS);
			
			var gst2R:Number = TimeUtils.timeToDecimalHours(rs2Result.gstR);
			var gst2S:Number = TimeUtils.timeToDecimalHours(rs2Result.gstS);
			
			var t00:Number = TimeUtils.timeToDecimalHours(TimeUtils.dateUT_To_GSTime(date));
			var temp:Number = (longitude.degree/15)*1.002738; //TODO not exactly the same result as in the book
			t00 -= temp;
			if(t00 < 0)
				t00 += 24;
			
			if(gst1R < t00) {
				gst1R += 24;
				gst2R += 24;
			}
			
			if(gst1S < t00) {
				gst1S += 24;
				gst2S += 24;
			}
			
			var gstR:Number = (24.07 * gst1R - t00*(gst2R - gst1R)) / 24.07 + gst1R - gst2R;
			var gstS:Number = (24.07 * gst1S - t00*(gst2S - gst1S)) / 24.07 + gst1S - gst2S;
			
			var gstRTime:Time = TimeUtils.decimalHoursToTime(gstR);
			var gstSTime:Time = TimeUtils.decimalHoursToTime(gstS);
			
			var gstRDate:Date = new Date(date.fullYear, date.month, date.date, gstRTime.hours, gstRTime.minutes, gstRTime.seconds, gstRTime.milliseconds);
			var gstSDate:Date = new Date(date.fullYear, date.month, date.date, gstSTime.hours, gstSTime.minutes, gstSTime.seconds, gstSTime.milliseconds);
			
			var utR:Time = TimeUtils.dateGST_To_UTTime(gstRDate);
			var utS:Time = TimeUtils.dateGST_To_UTTime(gstSDate);
			
			var localRising:Time = TimeUtils.utTimeToLocalTime(utR, timeZoneCorrection, dayLightSaving);
			var localSetting:Time = TimeUtils.utTimeToLocalTime(utS, timeZoneCorrection, dayLightSaving);
			
			return {sunrise: localRising, sunset: localSetting};
		}
		/**  
		 *	§ 48 Calculating the Sun's distance and angular size
		 * 
		 * 	@param date
		 *
		 *	@param galacticLAtitude
		 * 
		 * 	@return a generic object in the form of distance: [Number] in km, angularSize: [Angle]
		 *
		 */
		public static function calculateSunDistanceAndAngularSize(date:Date):Object {
		
			var sunPos:Object = calculateSunPosition(date);
			var v:Number = sunPos.trueAnomaly;
			var vRad:Number = toRadian(v);
			
			var f:Number = (1 + SUN_ECCENTRICITY_OF_ORBIT * Math.cos(vRad))/(1 - Math.pow(SUN_ECCENTRICITY_OF_ORBIT, 2));
			
			var r:Number = SUN_SEMI_MAJOR_AXIS / f;
			
			var aS:Number = f * SUN_ANGULAR_DIAMETER;
			var aT:Time = TimeUtils.decimalHoursToTime(aS);
			return {distance: r, angularSize: aT};
		}
		/**  
		 *	§ 46 Calculate the position of the Sun
		 * 
		 * 	@param date
		 *
		 *	@param galacticLAtitude
		 * 
		 * 	@return a generic object in the form of rightAscension: [Time], declination: [Angle], trueAnomaly [Number], sunLongitude: [Number]
		 *
		 */
		public static function calculateSunPosition(date:Date):Object {
			
			var jd:Number = TimeUtils.calculateJulianDate(date);
			var t:Number = (jd - 2415020)/36525;
			
			//var eL:Number = getEclipticLongitude(t);
			//var pL:Number = getPerigeeLongitude(t);
			//var oE:Number = getSunEarthOrbitEccentricity(t);
			
			var eL:Number = SUN_ECLIPTIC_LONGITUDE;
			var pL:Number = SUN_ECLIPTIC_LONGITUDE_PERIGEE;
			var oE:Number = SUN_ECCENTRICITY_OF_ORBIT;
			
			var d:Number = TimeUtils.dateToDayNumber(date);
			
			var yearDiff:Number = date.fullYear - 1990;
			var sign:Number;
			if(yearDiff < 0)
				sign = -1;
			else
				sign = 1;
			
			if(TimeUtils.isLeapYear(date.fullYear))
				d += (1 * sign);
				
			for(var i:int = 1; i <= Math.abs(yearDiff); i++) {
				var year:Number = date.fullYear + (i * sign);
				if(TimeUtils.isLeapYear(year))
					d += (1 * sign);
				d += (365 * sign);
			}
			
			var n:Number = (360/365.242191)*d;
			
			while(n < 0 || n > 360) {
				if(n < 0)
					n += 360;
				else 
					n -= 360;
			}
			
			var mM:Number =  n + eL - pL;
			if(mM < 0)
				mM += 360;
			
			var eC:Number = (360/Math.PI) * oE * Math.sin(toRadian(mM));
			
			var v:Number = n + eC;
			
			var sunEL:Number = n + eC + eL;
			
			if(sunEL > 360)
				sunEL -= 360;
			
			var longitude:Angle = new Angle();
			longitude.setFromDecimalDegree(sunEL);
			var latitude:Angle = new Angle(0, 0, 0);
			
			var result:Object = CoordinateUtils.convertEcliptic_To_equatorialCoordiante(longitude, latitude, date.fullYear);
			result.trueAnomaly = v;
			result.sunLongitude = sunEL;
			return result;
		}
		
		private static function getEclipticLongitude(t:Number):Number {
			var result:Number = 279.6966778 + 36000.76892*t + 0.0003025 * Math.pow(t, 2);
			return result;
		}
		private static function getPerigeeLongitude(t:Number):Number {
			var result:Number = 281.2208444 + 1.719175*t + 0.000452778 * Math.pow(t, 2);
			return result;
		}
		private static function getSunEarthOrbitEccentricity(t:Number):Number {
			var result:Number = 0.01675104 - 0.0000418*t - 0.000000126 * Math.pow(t, 2);
			return result;
		}
		
		private static function toRadian(angle:Number):Number {
			return angle*(Math.PI/180);
		}
		private static function toDegree(radian:Number):Number {
			return radian*(180/Math.PI);
		}
	}
}