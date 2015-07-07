package michaPau.utils.astronomy.helper
{
	public class Time
	{
		public var hours:int;
		public var minutes:int;
		public var seconds:int;
		public var milliseconds:int;
		public function Time(h:int = 0, m:int = 0, s:int = 0, ms:int = 0) {
			hours = h;
			minutes = m;
			seconds = s;
			milliseconds = ms;
		}
		
		public function toString():String {
			
			var sN:Number = seconds + (milliseconds/1000);
			var sStr:String = sN.toFixed(3);
			return hours +"h "+minutes+"m "+sStr+"s";
		}
		public function toTimeString(showSeconds:Boolean = false, showMilliseconds:Boolean = false):String {
			var ret:String = "";
			
			if(hours < 10)
				ret += "0"+hours+":";
			else 
				ret += hours +":";
			
			if(minutes < 10)
				ret += "0"+minutes;
			else
				ret += minutes;
			
			if(showSeconds) {
				if(seconds < 10)
					ret += ":0"+seconds;
				else
					ret += ":"+seconds;
			}
			
			if(showMilliseconds) {
				var ms:Number = milliseconds/1000;
				var msStr:String = ms.toFixed(3);
				ret+="."+msStr.substr(msStr.indexOf(".")+1);
			}
			return ret;
		}
	}
}