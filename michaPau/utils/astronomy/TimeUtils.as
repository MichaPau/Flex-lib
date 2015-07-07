package michaPau.utils.astronomy
{
	
	import mx.utils.ObjectUtil;
	
	import michaPau.utils.astronomy.helper.Longitude;
	import michaPau.utils.astronomy.helper.Time;

	public class TimeUtils
	{
		public static const MINUTES_PER_DAY:Number = 24*60;
		public static const SECONDS_PER_DAY:Number = 24*3600;
		public static const MILLISECONDS_PER_DAY:Number = 24*3600*1000;
		public function TimeUtils()
		{
		}
		
		//Time §15
		public static function lstTime_To_gstTime(time:Time, longitude:Longitude):Time {
			var dT:Number = TimeUtils.timeToDecimalHours(time);
			
			var longDif:Number = longitude.degree/15;
			var gst:Number = dT + (-longDif);
			if(gst > 24)
				gst -= 24;
			else if(gst < 0)
				gst += 24;
			
			return TimeUtils.decimalHoursToTime(gst);
		}
		public static function gstTime_To_lstTime(time:Time, longitude:Longitude):Time {
			var dT:Number = TimeUtils.timeToDecimalHours(time);
			var longDif:Number = longitude.degree/15;
			var lst:Number = dT + longDif;
			if(lst > 24)
				lst -= 24;
			else if(lst < 0)
				lst += 24;
			
			return TimeUtils.decimalHoursToTime(lst);
		}
		public static function dateGST_To_UTTime(date:Date):Time {
			//be sure it is time: 0h
			var dateGST:Date = new Date(date.fullYear, date.month, date.date);
			var jd:Number = TimeUtils.calculateJulianDate(dateGST);
			var s:Number = jd - 2451545;
			var t:Number = s/36525;
			var t0:Number = 6.697374558 + (2400.051336 * t) + (0.000025862 * Math.pow(t, 2));
			
			while(!(t0 > -1 && t0 < 25)) {
				if(t0 < 0) {
					t0 += 24;
				} else {
					t0 -= 24;
				}
			}
			
			var timeGST:Time = new Time(date.hours, date.minutes, date.seconds, date.milliseconds);
			var dT:Number = TimeUtils.timeToDecimalHours(timeGST) - t0;
			
			if(dT > 24)
				dT -= 24;
			else if(dT < 0)
				dT += 24;
			
			dT *= 0.9972695663;
			
			return TimeUtils.decimalHoursToTime(dT);
			
				
		}
		//the date have to be a UT Date
		public static function dateUT_To_GSTime(date:Date):Time {
			//be sure it is time: 0h
			var dateUT:Date = new Date(date.fullYear, date.month, date.date);
			var jd:Number = TimeUtils.calculateJulianDate(dateUT);
			var s:Number = jd - 2451545;
			var t:Number = s/36525;
			var t0:Number = 6.697374558 + (2400.051336*t) + (0.000025862 * Math.pow(t, 2));
			
			while(!(t0 > -1 && t0 < 25)) {
				if(t0 < 0) {
					t0 += 24;
				} else {
					t0 -= 24;
				}
			}
			
			var timeUT:Time = new Time(date.hours, date.minutes, date.seconds, date.milliseconds);
			var dT:Number = TimeUtils.timeToDecimalHours(timeUT)*1.002737909;
			
			t0 += dT;
			
			if(t0 > 24)
				t0 -= 24;
			else if(t0 < 0)
				t0 += 24;
			
			return TimeUtils.decimalHoursToTime(t0);
			
				
		}
		
		public static function localTimeToUTTime(localTime:Time, timeZoneCorrection:Number, daylightSaving:Boolean = false):Time {
		
			var time:Number = TimeUtils.timeToDecimalHours(localTime);
			
			time -= timeZoneCorrection;
			
			if(daylightSaving)
				time -= 1;
			
			if(time < 0)
				time += 24;
			else if(time > 24)
				time -= 24;
			
			return TimeUtils.decimalHoursToTime(time);
		}
		
		public static function utTimeToLocalTime(utTime:Time, timeZoneCorrection:Number, daylightSaving:Boolean = false):Time {
			
			var time:Number = TimeUtils.timeToDecimalHours(utTime);
			
			time += timeZoneCorrection;
			
			if(daylightSaving)
				time += 1;
			
			if(time < 0)
				time += 24;
			else if(time > 24)
				time -= 24;
			
			return TimeUtils.decimalHoursToTime(time);
		}
		
		public static function calculateDateFromJulianDate(jd:Number):Date {
			
			jd += 0.5;
			var i:Number = Math.floor(jd);
			var f:Number = CommonUtils.shearFraction(jd);
			
			var b:Number;
			
			if(i > 2299160) {
				var a:Number = Math.floor((i - 1867216.25)/36524.25);
				b = i + 1 + a - Math.floor(a/4);
			} else {
				b = i;
			}
			
			var c:Number = b + 1524;
			var d:Number = CommonUtils.getIntValue((c - 122.1)/365.25);
			var e:Number = CommonUtils.getIntValue(365.25 * d);
			var g:Number = CommonUtils.getIntValue((c - e)/30.6001);
			
			var dayValue:Number = c - e + f - (CommonUtils.getIntValue(30.6001 * g));
			
			var day:int = Math.floor(dayValue);
			var dayF:Number = CommonUtils.shearFraction(dayValue);
			
			var hour:int = 0;
			var minute:int = 0;
			var second:int = 0;
			var millisecond:int = 0;
			
			if(dayF != 0) {
				hour = Math.floor(dayF*24);
				var hourF:Number = CommonUtils.shearFraction(dayF*24);
				minute = Math.floor(hourF*60);
				var minuteF:Number = CommonUtils.shearFraction(hourF*60);
				second = Math.floor(minuteF*60);
				var secondF:Number = CommonUtils.shearFraction(minuteF*60);
				millisecond = Math.floor(secondF*1000);
			}
			var month:Number;
			
			if(g < 13.5) {
				month = g - 1;
			} else if (g > 13.5) {
				month = g - 13;
			}
			
			var year:Number;
			
			if(month > 2.5) {
				year = d - 4716;
			} else if(month < 2.5) {
				year = d - 4715;
			}
			
			return new Date(year, month - 1, day, hour, minute, second, millisecond);
		}
		
		/**  
		 *	§ 4 Julian day Numbers
		 * 
		 * 	@param date
		 *
		 * 	@return Number 
		 *
		 */
		public static function calculateJulianDate(date:Date):Number {
			
			var year:Number = date.fullYear;
			var month:Number = date.month + 1;
			var day:Number = date.date;
			day += date.hours/24;
			day += date.minutes/TimeUtils.MINUTES_PER_DAY;
			day += date.seconds/TimeUtils.SECONDS_PER_DAY;
			day += date.milliseconds/TimeUtils.MILLISECONDS_PER_DAY;
			
			if(month < 3) {
				year -= 1;
				month += 12;
			}
			
			//compare date with 1582 October 15
			var someDate:Date = new Date(1582, 9, 15);
			var dateCompare:int = ObjectUtil.dateCompare(someDate, date);
			var b:Number;
			if(dateCompare == -1) {
				var a:Number = Math.floor(year/100);
				b = 2 - a + Math.floor(a/4);
			} else {
				b = 0;
			}
			
			var c:Number;
			
			if(year < 0) {
				c = CommonUtils.getIntValue(365.25 * year - 0.75);
			} else {
				c = Math.floor(365.25 * year);
			}
			
			var d:Number = Math.floor(30.6001 * (month + 1));
			
			var jd:Number = b + c + d + day + 1720994.5; 
			
			return jd;
		}
		
		/**  
		 *	§ 3 Converting the date to day number
		 * 
		 * 	@param date
		 *
		 * 	@return dayNumber 
		 *
		 */
		public static function dateToDayNumber(date:Date):Number {
			var month:Number = date.month + 1;
			var result:Number;
			if(month < 3) {
				month -= 1;
				if(TimeUtils.isLeapYear(date.fullYear)) 
					result = Math.floor((62 * month)/2);
				else
					result = Math.floor((63 * month)/2);
			} else {
				month += 1;
				result = month * 30.6;
				if(TimeUtils.isLeapYear(date.fullYear))
					result = Math.floor(result)- 62;
				else 
					result = Math.floor(result) - 63;
			}
			
			return (result+date.date);
		}
		
		/**  
		 *	§ 2 The date of Easter
		 * 
		 * 	@param fullYear
		 *
		 * 	@return Date 
		 *
		 */
		public static function getEasterDateForYear(fullYear:Number):Date {
		
			var a:Number = Math.round(CommonUtils.shearFraction(fullYear/19)*19);
			var b:Number = Math.floor(fullYear/100);
			var c:Number = Math.round(CommonUtils.shearFraction(fullYear/100)*100);
			var d:Number = Math.floor(b/4);
			var e:Number = Math.round(CommonUtils.shearFraction(b/4)*4);
			var expF:Number = (b+8)/25;
			var f:Number = Math.floor((b+8)/25);
			var g:Number = Math.floor((b-f+1)/3);
			var h:Number = Math.round(CommonUtils.shearFraction((19*a + b - d - g + 15)/30)*30);
			var i:Number = Math.floor(c/4);
			var k:Number = Math.round(CommonUtils.shearFraction(c/4)*4);
			var l:Number = Math.round(CommonUtils.shearFraction((32 + 2*e + 2*i - h - k)/7)*7);
			var m:Number = Math.floor((a + 11*h + 22*l)/451);
			
			var exp1:Number = h + l - 7*m + 114;
			var n:Number = Math.floor(exp1/31);
			var p:Number = Math.round(CommonUtils.shearFraction(exp1/31)*31);
			
			var day:Number = p + 1;
			var month:Number = n - 1;
			
			return new Date(fullYear, month, day);
			
			
		}
		
		public static function isLeapYear(fullYear:Number):Boolean {
			if(fullYear % 4 != 0)
				return false;
			else if (fullYear % 100 != 0)
				return true;
			else if(fullYear % 400 != 0)
				return false;
			else 
				return true;
		}
		
		public static function decimalHoursToTime(value:Number):Time {
			var time:Time = new Time();
			time.hours = Math.floor(value);
			var m:Number = CommonUtils.shearFraction(Math.abs(value))*60;
			time.minutes = Math.floor(m);
			var s:Number = CommonUtils.shearFraction(m)*60;
			time.seconds = Math.floor(s);
			time.milliseconds = Math.round(CommonUtils.shearFraction(s)*1000);
			return time;
		}
		public static function timeToDecimalHours(time:Time):Number {
			
			var dT:Number = Math.abs(time.hours);
			
			var msF:Number = time.milliseconds/1000;
			var sF:Number = (time.seconds + msF)/60;
			var mF:Number = (time.minutes + sF)/60;
			
			dT += mF;
			
			if(time.hours < 0)
				dT *= -1;
			
			return dT; 
			
			
		}
		
		
		
		
	}
}