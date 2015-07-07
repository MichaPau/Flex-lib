package michaPau.utils
{
	import flash.globalization.DateTimeFormatter;
	import flash.globalization.LocaleID;

	public class DateUtils {
		public function DateUtils() {
		}
		
		public static function checkForToday(date:Date):Boolean {
			var today:Date = new Date();
			
			if(date.fullYear == today.fullYear && date.month == today.month && date.date == today.date)
				return true;
			else
				return false;
		}
		static public function getISO8601_DateTimeString(date:Date = null):String {
			if(!date)
				date = new Date();
			
			var dF:DateTimeFormatter = new DateTimeFormatter(LocaleID.DEFAULT);
			dF.setDateTimePattern("yyyy-MM-dd HH:mm:ss");
			return dF.format(date);
		}
		
		static public function getTimeFromMilliseconds(value:int, separator:String=":", showHrs:Boolean=true, showMins:Boolean=true, showSecs:Boolean=false):String {
			//milliseconds to hrs:mins:secs
			var hrs_str:String
			var mins_str:String;
			var secs_str:String;
			var time:String = "";
			
			var secs:Number;
			var mins:Number;
			var hrs:Number;
			
			if( value == 0 ) {
				secs = 0;
				mins =0;
				hrs = 0;
			} else {
				secs = Math.floor( value/1000 );
				mins = Math.floor(secs/60);
				hrs = Math.floor(mins/60);
				
				secs %= 60;
				mins %= 60;
			}
			if( hrs < 10 ){
				hrs_str = "0" + String( hrs );
			}else{
				hrs_str = String( hrs );
			}
			if( mins < 10 ){
				mins_str = "0" + String( mins );
			}else{
				mins_str = String( mins );
			}
			if( secs < 10 ){
				secs_str = "0" + String( secs );
			}else{
				secs_str = String( secs );
			}
			
			if( showHrs ){
				time += hrs_str + separator;
			}
			if( showMins ){
				time += mins_str + separator;
			}
			if( showSecs ){
				time += secs_str + separator;
			}
			time = time.substring( 0, time.length-1 );
			
			return time;
		}
	}
}