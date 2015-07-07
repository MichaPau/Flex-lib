package michaPau.components
{
	import flash.display.Sprite;
	import flash.events.EventPhase;
	
	import mx.core.FlexGlobals;
	import mx.core.IFlexDisplayObject;
	import mx.core.IFlexModule;
	import mx.core.IFlexModuleFactory;
	import mx.core.UIComponent;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.managers.ISystemManager;
	import mx.managers.PopUpManager;
	
	import spark.components.Alert;
	import spark.components.RichText;
	import spark.components.supportClasses.TextBase;
	
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.elements.TextFlow;
	
	public class AlertMessageTextFlow extends Alert {
		
		[SkinPart(required="true")]
		public var flowMessageDisplay:TextBase;
		
		private var _flowMessage:String = "";
		
		public static function show(message:String = "", title:String = "", flags:uint = OK, parent:Sprite = null, closeHandler:Function = null,
									iconClass:Class = null, defaultButtonFlag:uint = Alert.OK, moduleFactory:IFlexModuleFactory = null):Alert {
			
			var modal:Boolean = (flags & Alert.NONMODAL) ? false : true;
			
			if (!parent) {
				var sm:ISystemManager = ISystemManager(FlexGlobals.topLevelApplication.systemManager);
				// no types so no dependencies
				var mp:Object = sm.getImplementation("mx.managers.IMarshallPlanSystemManager");
				if (mp && mp.useSWFBridge()) {
					parent = Sprite(sm.getSandboxRoot());
				} else {
					parent = Sprite(FlexGlobals.topLevelApplication);
				}
			}
			
			var alert:AlertMessageTextFlow = new AlertMessageTextFlow();
			alert.buttonsFlag = flags;
			alert.defaultButtonFlag = defaultButtonFlag;
			
			alert.flowMessage = message;
			alert.title = title;
			//(alert.messageDisplay as RichText).textFlow = new TextFlow();
			alert.iconClass = iconClass;
			
			if (closeHandler != null) {
				alert.addEventListener(CloseEvent.CLOSE, closeHandler);
			}
			
			// Setting a module factory allows the correct embedded font to be found.
			if (moduleFactory) {
				alert.moduleFactory = moduleFactory;
			} else if (parent is IFlexModule) {
				alert.moduleFactory = IFlexModule(parent).moduleFactory;
			} else {
				if (parent is IFlexModuleFactory) {
					alert.moduleFactory = IFlexModuleFactory(parent);
				} else {
					alert.moduleFactory = FlexGlobals.topLevelApplication.moduleFactory;
				}
				
				// also set document if parent isn't a UIComponent
				if (!parent is UIComponent) {
					alert.document = FlexGlobals.topLevelApplication.document;
				}
			}
			
			alert.addEventListener(FlexEvent.CREATION_COMPLETE, staticCreationComplete);
			PopUpManager.addPopUp(alert, parent, modal);
			
			return alert;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Class event handlers
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		private static function staticCreationComplete(event:FlexEvent):void {
			if (event.target is IFlexDisplayObject && event.eventPhase == EventPhase.AT_TARGET) {
				var alert:AlertMessageTextFlow = AlertMessageTextFlow(event.target);
				alert.removeEventListener(FlexEvent.CREATION_COMPLETE, staticCreationComplete);
				alert.setActualSize(alert.getExplicitOrMeasuredWidth(), alert.getExplicitOrMeasuredHeight());
				PopUpManager.centerPopUp(alert);
			}
		}
		
		public function AlertMessageTextFlow() {
			super();
			//title = "";
			//message = "";
			flowMessage = "";
		}
		
		public function get flowMessage():String {
			return _flowMessage;
		}
		public function set flowMessage(value:String):void {
			if (_flowMessage == value) {
				return;
			}
			_flowMessage = value;
			
			if (flowMessageDisplay) {
				//editor.textFlow = TextConverter.importToFlow(_str, converterFormat);
				//messageDisplay.text = _message;
				(flowMessageDisplay as RichText).textFlow = TextConverter.importToFlow(_flowMessage, TextConverter.TEXT_FIELD_HTML_FORMAT);
			}
		}
		override protected function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			if (partName == "flowMessageDisplay") {
				(flowMessageDisplay as RichText).textFlow = TextConverter.importToFlow(_flowMessage, TextConverter.TEXT_FIELD_HTML_FORMAT);
				flowMessageDisplay.styleName = getStyle("messageStyleName");
			}
			
		}
	}
}