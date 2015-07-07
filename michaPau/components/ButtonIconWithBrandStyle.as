package michaPau.components
{
	import mx.core.FlexGlobals;
	import mx.styles.CSSStyleDeclaration;
	
	import flatspark.components.ButtonIcon;
	
	[Style(name="brandStyle", type="uint")]
	public class ButtonIconWithBrandStyle extends ButtonIcon
	{
		private static var classConstructed:Boolean = classConstruct();
		
		protected var brandChanged:Boolean = false;
		
		private static function classConstruct():Boolean {
			
			if (!FlexGlobals.topLevelApplication.styleManager.getStyleDeclaration("components.ButtonIconWithBrandStyle")) {
				var myBrandStyles:CSSStyleDeclaration = new CSSStyleDeclaration();
				myBrandStyles.defaultFactory = function():void
				{
					this.brandStyle = 5;
				}
				FlexGlobals.topLevelApplication.styleManager.setStyleDeclaration("components.ButtonIconWithBrandStyle", myBrandStyles, true);
				
			} else {
				
			}
			return true;
		}
		public function ButtonIconWithBrandStyle() {
			super();
		}
		public override function styleChanged(styleProp:String):void {
			super.styleChanged(styleProp);
			
			if(styleProp == "brandStyle" || !styleProp) {
				brandChanged = true;
				invalidateDisplayList();
				
				return;
			}
		}
		
		protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if(brandChanged) {
				this.brand = getStyle("brandStyle");
				brandChanged = false;
			}
		}
	}
}