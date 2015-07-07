package michaPau.utils.geom {
	
	/**  
	 *	SimplePoint just to have bindable x, y coordinates
	 **/
	
	[Bindable]
	public class SimplePoint {
		
		public var x:Number;
		public var y:Number;
		
		public function SimplePoint(_x:Number = 0, _y:Number = 0) {
			x = _x;
			y = _y;
		}
	}
}