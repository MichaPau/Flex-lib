package michaPau.utils.astronomy
{
	import michaPau.utils.astronomy.helper.Angle;
	import michaPau.utils.astronomy.helper.Latitude;
	import michaPau.utils.astronomy.helper.Longitude;
	import michaPau.utils.astronomy.helper.Time;

	public class CoordinateUtils
	{
		//1980
		//public static const GALACTIC_POLE_ASCENSION:Angle = new Angle(192, 15, 0);
		//public static const GALACTIC_POLE_DECLINATION:Angle = new Angle(27, 24, 0);
		//public static const GALACTIC_PLANE:Angle = new Angle(33, 0, 0);
		
		//2010
		public static const GALACTIC_POLE_ASCENSION:Angle = new Angle(192, 51, 28.8);
		public static const GALACTIC_POLE_DECLINATION:Angle = new Angle(27, 7, 41.88);
		public static const GALACTIC_PLANE:Angle = new Angle(23, 26, 21.48);
		
		public static var AU_IN_KM:Number =  149597870.700 //in km
		
		
		/**  
		 *	§ 36 Calculate aberrationDelta
		 * 
		 *  @param hourAngle in Time
		 * 
		 *  @param declination in Angle
		 * 
		 *  @param latitude in Latitude
		 * 
		 *  @param temperature in degrees
		 * 
		 *  @param pressure in millibars
		 * 
		 *  @return a generic object in the form of hourAngle: [Time], declination: [Angle]
		 * 
		 */
		 public static function calculateRefraction(hourAngle:Time, declination:Angle, latitude:Latitude, temperature:Number, pressure:Number):Object {
		 
			var hResult:Object = CoordinateUtils.convertEquatorial_To_horizonCoordinate(hourAngle, declination, latitude);
			var alti:Number = (hResult.altitude as Angle).getDecimalValue();
			//var azi:Number = (hResult.azituth as Angle).getDecimalValue();
			var z:Number = 90 - alti;
			
			var result:Object;
			
			var r:Number;
			
			if(alti > 15) {
				r = 0.00452 * pressure * Math.tan(CommonUtils.toRadian(z)) / (273 + temperature);
				
			} else {
				r = (pressure * (0.1594 + 0.0196*alti + 0.00002*Math.pow(alti, 2))) / ((273 + temperature) * (1 + 0.505*alti + 0.0845*Math.pow(alti, 2)));
			}
			
			var newAlti:Number = alti + r;
			var altiAngle:Angle = new Angle();
			altiAngle.setFromDecimalDegree(newAlti);
			result = CoordinateUtils.convertHorizon_To_equatorialCoordiante(altiAngle, hResult.azimuth, latitude);
			
		 	return {hourAngle: result.hourAngle, declination: result.declination};
		 }
		/**  
		 *	§ 36 Calculate aberrationDelta
		 * 
		 *  @param eclipticLongitude as Angle
		 * 
		 *  @param eclipticLatitude as Angle
		 * 
		 *  @param sunLongitude as Angle
		 *
		 * 	@return a generic object in the form of longitudeDelta: [Number], latitudeDelta: [Number] in decimalDegree
		 *
		 */
		public static function calculateAberrationDelta(eclipticLongitude:Angle, eclipticLatitude:Angle, sunLongitude:Angle):Object {
			
			var eLongRad:Number = CommonUtils.toRadian(eclipticLongitude.getDecimalValue());
			var eLatRad:Number = CommonUtils.toRadian(eclipticLatitude.getDecimalValue());
			var sunLongRad:Number = CommonUtils.toRadian(sunLongitude.getDecimalValue());
			
			var longDeltaArcsec:Number = -20.5 * Math.cos(sunLongRad - eLongRad) / Math.cos(eLatRad);
			var latDeltaArcsec:Number  = -20.5 * Math.sin(sunLongRad - eLongRad) * Math.sin(eLatRad);
			
			var longDelta:Number = longDeltaArcsec/3600;
			var latDelta:Number = latDeltaArcsec/3600;
			
			return {longitudeDelta: longDelta, latitudeDelta: latDelta};
		}
		/**  
		 *	§ 35 Calculate nutation for a given date
		 * 
		 *  @param date 
		 *
		 * 	@return a generic object in the form of nutationLongitude: [Number], nutationObliquity: [Number], the return values are arcseconds
		 *
		 */
		public static function calculateNutationForDate(date:Date):Object {
		
			var jd:Number = TimeUtils.calculateJulianDate(date);
			var t:Number = (jd - 2415020)/36525;
			
			var a:Number = 100.002136*t;
			var l:Number = 279.6967 + 360*(a - CommonUtils.getIntValue(a));
			
			while(l < 0 || l > 360) {
				if(l < 0)
					l += 360;
				else if(l > 360)
					l -= 360;
			}
			
			var b:Number = 5.372617*t;
			
			var moonNode:Number = 259.1833 - 360*(b - CommonUtils.getIntValue(b));
			
			while(moonNode < 0 || moonNode > 360) {
				if(moonNode < 0)
					moonNode += 360;
				else if(moonNode > 360)
					moonNode -= 360;
			}
			var nutLong:Number = -17.2 * Math.sin(CommonUtils.toRadian(moonNode)) - 1.3 * Math.sin(2*CommonUtils.toRadian(l));  
			var nutObl:Number  = 9.2 * Math.cos(CommonUtils.toRadian(moonNode)) + 0.5 * Math.cos(2*CommonUtils.toRadian(l));
			
			return {nutationLongitude: nutLong, nutationObliquity: nutObl};
		}
		/**  
		 *	§ 33 Calculate the rising and setting
		 * 
		 *  @param ascension
		 *
		 * 	@param declination
		 * 
		 *  @param date/time
		 * 
		 *  @param latitude
		 * 
		 *  @param longitude
		 * 
		 * 	@return a generic object in the form of rising: [Time], setting: [Time] , azimuthRising: [Angle], azimuthSetting: [Angle], the return times are UT
		 *
		 */
		
		public static function getRisingAndSetting(ascension:Time, declination:Angle, date:Date, latitude:Latitude, longitude:Longitude):Object {
			
			var ascDec:Number = TimeUtils.timeToDecimalHours(ascension);
			var declDec:Number = declination.getDecimalValue();
			
			var ascRad:Number = CommonUtils.toRadian(ascDec);
			var declRad:Number = CommonUtils.toRadian(declDec);
			
			var cosAziR:Number = Math.sin(declRad) / Math.cos(latitude.toRadian());
			
			var aziR:Number = CommonUtils.toDegree(Math.acos(cosAziR));
			var aziS:Number = 360 - aziR;
			
			var check:Number = -Math.tan(latitude.toRadian()) * Math.tan(declRad);
			
			if(check > 1 || check < -1) {
				trace("TODO no rising or circumpolar");
				var visibility:Boolean = true;
				if(check > 1)
					visibility = false;
				
				return {rising: null, setting: null, visible:visibility};
			}
			var h:Number = (1/15) * CommonUtils.toDegree(Math.acos(check));
			
			var lstR:Number = 24 + ascDec - h;
			if(lstR > 24)
				lstR -= 24;
			
			var lstS:Number = ascDec + h;
			if(lstS > 24)
				lstS -= 24;
			
			
			var lstRTime:Time = TimeUtils.decimalHoursToTime(lstR);
			var lstSTime:Time = TimeUtils.decimalHoursToTime(lstS);
			var gstR:Time = TimeUtils.lstTime_To_gstTime(lstRTime, longitude);
			var gstS:Time = TimeUtils.lstTime_To_gstTime(lstSTime, longitude);
			
			var dateR:Date = new Date(date.fullYear, date.month, date.date, gstR.hours, gstR.minutes, gstR.seconds, gstR.milliseconds);
			var dateS:Date = new Date(date.fullYear, date.month, date.date, gstS.hours, gstS.minutes, gstS.seconds, gstS.milliseconds);
			
			var utR:Time = TimeUtils.dateGST_To_UTTime(dateR);
			var utS:Time = TimeUtils.dateGST_To_UTTime(dateS);
			
			var aziRising:Angle = new Angle();
			var aziSetting:Angle = new Angle();
			aziRising.setFromDecimalDegree(aziR);
			aziSetting.setFromDecimalDegree(aziS);
			
			return {rising: utR, setting: utS, azimuthRising: aziRising, azimuthSetting: aziSetting, lstR: lstRTime, lstS: lstSTime, gstR: gstR, gstS:gstS};
		}
		/**  
		 *	§ 32 The angle between two celestial objects
		 * 
		 * 	@param ascension1
		 * 
		 *  @param declination1
		 *
		 * 	@param ascension2
		 * 
		 *  @param declination2
		 * 
		 * 	@return the angular distance 
		 *
		 */
		public static function angularDistanceBetweenCelestialObjects(ascension1:Time, declination1:Angle, ascension2:Time, declination2:Angle):Angle {
			var asc1Dec:Number = TimeUtils.timeToDecimalHours(ascension1);
			var decl1Dec:Number = declination1.getDecimalValue();
			var decl1Rad:Number = CommonUtils.toRadian(decl1Dec);
			var asc2Dec:Number = TimeUtils.timeToDecimalHours(ascension2);
			var decl2Dec:Number = declination2.getDecimalValue()
			var decl2Rad:Number = CommonUtils.toRadian(decl2Dec);
			
			var ascDist:Number = (asc1Dec - asc2Dec);
			var ascDistDeg:Number = (asc1Dec - asc2Dec)*15;
			var ascDistRad:Number = CommonUtils.toRadian(ascDistDeg);
			
			var cosD:Number = Math.sin(decl1Rad) * Math.sin(decl2Rad) 
				+ Math.cos(decl1Rad) * Math.cos(decl2Rad) * Math.cos(ascDistRad);
			
			var d:Number = CommonUtils.toDegree(Math.acos(cosD));
			
			var dAngle:Angle = new Angle();
			dAngle.setFromDecimalDegree(d);
			
			return dAngle;
			
		}
		/**  
		 *	§ 30 Galactic to equatorial coordinate conversion
		 * 
		 * 	@param galacticLongitude
		 *
		 *	@param galacticLAtitude
		 * 
		 * 	@return a generic object in the form of ascension: [Time], declination: [Angle]
		 *
		 */
		public static function convertGalactic_To_equatorialCoordiante(galacticLongitude:Angle, galacticLatitude:Angle):Object {
			
			var longDec:Number = galacticLongitude.getDecimalValue();
			var latDec:Number  = galacticLatitude.getDecimalValue();
			
			var longRad:Number = CommonUtils.toRadian(longDec);
			var latRad:Number = CommonUtils.toRadian(latDec);
			
			var galAscRad:Number = CommonUtils.toRadian(GALACTIC_POLE_ASCENSION.getDecimalValue());
			var galDeclRad:Number = CommonUtils.toRadian(GALACTIC_POLE_DECLINATION.getDecimalValue());
			var galPlaneRad:Number = CommonUtils.toRadian(GALACTIC_PLANE.getDecimalValue());
			
			var sinDecl:Number = Math.cos(latRad) * Math.cos(galDeclRad) * Math.sin(longRad - galPlaneRad)
				+ Math.sin(latRad) * Math.sin(galDeclRad);
			
			var declDeg:Number = CommonUtils.toDegree(Math.asin(sinDecl));
			
			var y:Number = Math.cos(latRad) * Math.cos(longRad - galPlaneRad);
			
			var x:Number = Math.sin(latRad) * Math.cos(galDeclRad) - Math.cos(latRad) * Math.sin(galDeclRad) * Math.sin(longRad - galPlaneRad);
			
			var ascRad:Number = Math.atan2(y, x);
			
			var ascDeg:Number = CommonUtils.toDegree(ascRad);
			
			ascDeg += GALACTIC_POLE_ASCENSION.getDecimalValue();
			
			if(ascDeg < 0)
			 ascDeg += 360;
			
			var ascH:Number = ascDeg/15;
			
			var ascension:Time = TimeUtils.decimalHoursToTime(ascH);
			var declination:Angle = new Angle();
			
			declination.setFromDecimalDegree(declDeg);
			
			return {ascension: ascension, declination: declination};
		}
		/**  
		 *	§ 29 Equatorial to galactic coordinate conversion
		 * 
		 * 	@param ascension the right ascension
		 *
		 *	@param declination the declination
		 * 
		 * 	@return a generic object in the form of galacticLatitude: [Angle], galacticLongitude: [Angle]
		 *
		 */
		public static function convertEquatorial_To_galacticCoordiante(ascension:Time, declination:Angle):Object {
			
			var ascDec:Number = TimeUtils.timeToDecimalHours(ascension) * 15;
			var declDec:Number = declination.getDecimalValue();
			
			var ascRad:Number = CommonUtils.toRadian(ascDec);
			var declRad:Number = CommonUtils.toRadian(declDec);
			
			var galAscRad:Number = CommonUtils.toRadian(GALACTIC_POLE_ASCENSION.getDecimalValue());
			var galDeclRad:Number = CommonUtils.toRadian(GALACTIC_POLE_DECLINATION.getDecimalValue());
			
			var temp:Number = CommonUtils.toRadian(ascDec - GALACTIC_POLE_ASCENSION.getDecimalValue());
			//ascRad - galAscRad
			var sinB:Number = Math.cos(declRad) * Math.cos(galDeclRad) * Math.cos(temp) + Math.sin(declRad) * Math.sin(galDeclRad);
			
			var b:Number = CommonUtils.toDegree(Math.asin(sinB));
			
			var y:Number = Math.sin(declRad) - sinB * Math.sin(galDeclRad);
			
			var x:Number = Math.cos(declRad) * Math.sin(ascRad - galAscRad) * Math.cos(galDeclRad);
		
			var lRad:Number = Math.atan2(y, x);
			var lDeg:Number = CommonUtils.toDegree(lRad);
			
			var l:Number = lDeg + GALACTIC_PLANE.getDecimalValue(); 
			
			if(lDeg < 0)
				lDeg += 360;
			
			var galacticLongitude:Angle = new Angle();
			var galacticLatitude:Angle = new Angle();
			
			galacticLongitude.setFromDecimalDegree(l);
			galacticLatitude.setFromDecimalDegree(b);
			
			return {galacticLatitude: galacticLatitude, galacticLongitude: galacticLongitude};
			
		}
		/**  
		 *	§ 28 Equatorial to ecliptic coordinate conversion
		 * 
		 * 	@param ascension the right ascension
		 *
		 *	@param declination the declination
		 * 
		 *  @param yearOfEpoch the year of the epoch e.x 1980 or 2014 ...
		 * 
		 * 	@return a generic object in the form of eclipticLatitude: [Angle], eclipticLongitude: [Angle]
		 *
		 */
		public static function convertEquatorial_To_eclipticCoordiante(ascension:Time, declination:Angle, yearOfEpoch:Number):Object {
			
			var ascDec:Number = TimeUtils.timeToDecimalHours(ascension);
			var declDec:Number = declination.getDecimalValue();
			
			var eclipticObliquity:Number = Angle(CoordinateUtils.getEclipticObliquityForDate(yearOfEpoch)).getDecimalValue();
			
			var ascDecDeg:Number = ascDec * 15;
			
			var sinLat:Number = Math.sin(CommonUtils.toRadian(declDec))*Math.cos(CommonUtils.toRadian(eclipticObliquity))
				-Math.cos(CommonUtils.toRadian(declDec))*Math.sin(CommonUtils.toRadian(eclipticObliquity))*Math.sin(CommonUtils.toRadian(ascDecDeg));
			
			var latDec:Number = CommonUtils.toDegree(Math.asin(sinLat));
			
			var y:Number = Math.sin(CommonUtils.toRadian(ascDecDeg))*Math.cos(CommonUtils.toRadian(eclipticObliquity))
				+ Math.tan(CommonUtils.toRadian(declDec))*Math.sin(CommonUtils.toRadian(eclipticObliquity));
					
			var x:Number = Math.cos(CommonUtils.toRadian(ascDecDeg));
			
			var longRad:Number = Math.atan2(y, x);
			var longDec:Number = CommonUtils.toDegree(longRad);
			
			if(longDec < 0)
				longDec += 360;
			
			var latAngle:Angle = new Angle();
			var longAngle:Angle = new Angle();
			
			latAngle.setFromDecimalDegree(latDec);
			longAngle.setFromDecimalDegree(longDec);
			
			return {eclipticLatitude: latAngle, eclipticLongitude: longAngle};
			
		}
		/**  
		 *	§ 27 Ecliptic to equatorial coordinate conversion
		 * 
		 * 	@param ecliptic longitude angle
		 *
		 *	@param ecliptic latitude angle
		 * 
		 *  @param yearOfEpoch the year of the epoch e.x 1980 or 2014 ...
		 * 
		 * 	@return a generic object in the form of rightAscension: [Time], declination: [Angle]
		 *
		 */
		public static function convertEcliptic_To_equatorialCoordiante(longitudeAngle:Angle, latitudeAngle:Angle, yearOfEpoch:Number):Object {
			
			var longDec:Number = longitudeAngle.getDecimalValue();
			var latDec:Number = latitudeAngle.getDecimalValue();
			
			var eclipticObliquity:Number = Angle(CoordinateUtils.getEclipticObliquityForDate(yearOfEpoch)).getDecimalValue();
			
			var sinDecl:Number = Math.sin(CommonUtils.toRadian(latDec))*Math.cos(CommonUtils.toRadian(eclipticObliquity))
				+ Math.cos(CommonUtils.toRadian(latDec))*Math.sin(CommonUtils.toRadian(eclipticObliquity))*Math.sin(CommonUtils.toRadian(longDec));
			
			var declDec:Number = CommonUtils.toDegree(Math.asin(sinDecl));
			
			var y:Number = Math.sin(CommonUtils.toRadian(longDec))*Math.cos(CommonUtils.toRadian(eclipticObliquity))
				- Math.tan(CommonUtils.toRadian(latDec))*Math.sin(CommonUtils.toRadian(eclipticObliquity));
			
			var x:Number = Math.cos(CommonUtils.toRadian(longDec));
			
			var aRad:Number = Math.atan2(y, x);
			var alpha:Number = CommonUtils.toDegree(aRad);
			
			if(alpha < 0)
				alpha += 360;
			
			var alphaH:Number = alpha/15;
			
			var ascension:Time = TimeUtils.decimalHoursToTime(alphaH);
			var declination:Angle = new Angle();
			declination.setFromDecimalDegree(declDec);
				
			return {rightAscension: ascension, declination: declination};	
		}
		/**  
		 *	§ 26 Horizon to equatorial coordinate conversion
		 * 
		 * 	@param altitude
		 *
		 *	@param azimuth
		 * 
		 *  @param latitude the observers latitude
		 * 
		 * 	@return a generic object in the form of declination: [Angle], hourAngle: [Time]
		 *
		 * 	@langversion ActionScript 3.0
		 *	@playerversion Flash 9.0
		 *	@tiptext
		 */
		public static function convertHorizon_To_equatorialCoordiante(altitude:Angle, azimuth:Angle, latitude:Latitude):Object {
			
			var azimuthDec:Number = azimuth.getDecimalValue();
			var altitudeDec:Number = altitude.getDecimalValue();
			
			
			var sinDecl:Number = (Math.sin(CommonUtils.toRadian(altitudeDec)) * Math.sin(latitude.toRadian())) + (Math.cos(CommonUtils.toRadian(altitudeDec)) * Math.cos(latitude.toRadian()) * Math.cos(CommonUtils.toRadian(azimuthDec)));
			
			var decl:Number = Math.asin(sinDecl);
			
			var cosH:Number = (Math.sin(CommonUtils.toRadian(altitudeDec)) - (Math.sin(latitude.toRadian()) * Math.sin(decl))) / (Math.cos(latitude.toRadian()) * Math.cos(decl));
			var h:Number = CommonUtils.toDegree(Math.acos(cosH));
			
			var sinA:Number = Math.sin(CommonUtils.toRadian(azimuthDec));
			
			var hourDec:Number;
			
			if(sinA <= 0)
				hourDec = h;
			else {
				hourDec = 360 - h;
			}
			
			var hourAngle:Time = new Time();
			var declinationAngle:Angle = new Angle();
			declinationAngle.setFromDecimalDegree(CommonUtils.toDegree(decl));
			
			hourAngle = TimeUtils.decimalHoursToTime(hourDec/15);
			
			return {declination: declinationAngle, hourAngle: hourAngle};
		}
		/**  
		 *	§ 25 Equatorial to horizon coordinate conversion
		 * 
		 * 	@param hour angle (see convertRightAscensionAndHourAngle)
		 *
		 *	@param declination
		 * 
		 *  @param latitude the observers latitude
		 * 
		 * 	@return a generic object in the form of azimuth: [azimuthAngle], altitude: [altitudeAngle]
		 *
		 * 	@langversion ActionScript 3.0
		 *	@playerversion Flash 9.0
		 *	@tiptext
		 */			
		public static function convertEquatorial_To_horizonCoordinate(hourAngle:Time, declination:Angle, latitude:Latitude):Object {
		
			var h:Number = TimeUtils.timeToDecimalHours(hourAngle);
			var h1:Number = h*15;
			
			var aD:Number = declination.getDecimalValue();
			var sinA:Number = (Math.sin(CommonUtils.toRadian(aD)) * Math.sin(latitude.toRadian())) + (Math.cos(CommonUtils.toRadian(aD)) * Math.cos(latitude.toRadian()) * Math.cos(CommonUtils.toRadian(h1)));
			
			var a:Number = Math.asin(sinA);
			
			var cosA:Number = (Math.sin(CommonUtils.toRadian(aD)) - (Math.sin(latitude.toRadian()) * Math.sin(a))) / (Math.cos(latitude.toRadian()) * Math.cos(a));
			var a1:Number = Math.acos(cosA);
			
			var sinH:Number = Math.sin(CommonUtils.toRadian(h1));
			
			var azimuth:Number;
			
			if(sinH <= 0)
				azimuth = CommonUtils.toDegree(a1);
			else {
				azimuth = 360 - CommonUtils.toDegree(a1);
			}
			
			var azimuthAngle:Angle = new Angle();
			var altitudeAngle:Angle = new Angle();
			
			azimuthAngle.setFromDecimalDegree(azimuth);
			altitudeAngle.setFromDecimalDegree(CommonUtils.toDegree(a));
			
			return {azimuth: azimuthAngle, altitude: altitudeAngle};
		
		}
		
		/**  
		 *	§ 24 Converting between right ascension and hour angle or hour angle back to right ascension
		 * 
		 * 	@param ascensionOrHourAngle Right ascension as time angle or hour angle
		 *
		 *	@param longitude a point (negative if W positive if E)
		 * 
		 *  @param utDate the Date (hace to be UT)
		 * 
		 * 	@return the hour angle or the right ascension (depends on the first param)
		 *
		 * 	@langversion ActionScript 3.0
		 *	@playerversion Flash 9.0
		 *	@tiptext
		 */			
		public static function convertRightAscensionAndHourAngle(ascensionOrHourAngle:Time, longitude:Longitude, utDate:Date):Time {
			var gst:Time = TimeUtils.dateUT_To_GSTime(utDate);
			var lst:Time = TimeUtils.gstTime_To_lstTime(gst, longitude);
			var lstD:Number = TimeUtils.timeToDecimalHours(lst);
			var dH:Number = TimeUtils.timeToDecimalHours(ascensionOrHourAngle);
			
			var h:Number = lstD - dH;
			
			if(h < 0) {
				h += 24;
			}
			
			return TimeUtils.decimalHoursToTime(h);
		}
		
		
		public static function getEclipticObliquityForDate(year:Number):Angle {
			var utDate:Date = new Date(year-1, 11, 31);
			var jD:Number = TimeUtils.calculateJulianDate(utDate);
			var jD2:Number = jD - 2451545;
			
			var t:Number = jD2/36525;
			
			var deltaE:Number = 46.815*t + 0.0006*(Math.pow(t, 2)) - 0.00181*(Math.pow(t, 3));
			var deltaE2:Number = deltaE/3600;
			
			var epsilonDec:Number = 23.439292 - deltaE2;
			
			var angle:Angle = new Angle();
			angle.setFromDecimalDegree(epsilonDec);
			return angle;
		}
	}
}