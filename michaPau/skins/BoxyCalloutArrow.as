package michaPau.skins
{
	import spark.skins.spark.supportClasses.CalloutArrow;
	
	/**
	 from: blogs.adobe.com/jasonsj/2011/11/skinning-callout-and-calloutbutton.html
	 **/
	
	public class BoxyCalloutArrow extends CalloutArrow
	{
		public function BoxyCalloutArrow()
		{
			super();
			
			//borderThickness = 1; 
			//borderColor = 0x333333; 
			gap = 0;
			useBackgroundGradient = false;
		}
	}
}