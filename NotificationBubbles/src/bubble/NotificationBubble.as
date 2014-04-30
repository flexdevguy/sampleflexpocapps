package bubble
{
	import flash.events.Event;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Point;
	
	import mx.core.UIComponent;
	import mx.core.FlexGlobals;
	import mx.events.MoveEvent;
	import mx.managers.PopUpManager;
	
	import spark.components.SkinnablePopUpContainer;
	import spark.components.Label;
	
	public class NotificationBubble extends SkinnablePopUpContainer
	{
		private var label:Label;
		//TODO:update position when resize
		private var updateBubblePosition:Boolean = false;
		
		private var minDigits:int = 1;
		private var isTextChanged:Boolean = false;
		private var _text:String = "";
		public function get text():String
		{
			return _text;
		}
		public function set text(value:String):void
		{
			if(_text == value) return;
			
			_text = value;
			isTextChanged = true;
			invalidateProperties();
		}
		
		public function NotificationBubble() {
		
			super();
			this.minHeight = 20;
			this.minWidth = 20;
			this.setStyle("skinClass",NotificationBubbleSkin);
		}
		
		public function show(owner:DisplayObjectContainer, text:String = ""):void
		{
			if(isOpen) return;
			
			this.text = text;
			this.open(owner, false);
			
			owner.addEventListener(Event.RESIZE, onOwnerResize_Handler);
			owner.addEventListener(MoveEvent.MOVE, onOwnerMoved_Handler);
			owner.addEventListener(Event.REMOVED_FROM_STAGE, onOwnerRemovedFromStage_Handler);
			
		}
		
		private function onOwnerResize_Handler(event:Event):void
		{
			trace("Bubble owner resize handler");
			updateBubblePosition = true;
			invalidateDisplayList();
		}
		
		private function onOwnerMoved_Handler(event:Event):void
		{
			trace("Bubble owner Moved handler");
			updateBubblePosition = true;
			invalidateDisplayList();
		}
		
		private function onOwnerRemovedFromStage_Handler(event:Event):void
		{
			trace("Bubble owner removed handler");
			this.close();
		}
		
		override public function close(commit:Boolean=false, data:*=null):void
		{
			owner.removeEventListener(Event.RESIZE, onOwnerResize_Handler);
			owner.removeEventListener(MoveEvent.MOVE, onOwnerMoved_Handler);
			owner.removeEventListener(Event.REMOVED_FROM_STAGE, onOwnerRemovedFromStage_Handler);
			
			super.close(commit, data);
		}

		override protected function createChildren():void
		{
			super.createChildren();
			
			if(!label)
				label = new Label();
			label.horizontalCenter = 0;
			label.verticalCenter = 0;
			label.maxDisplayedLines = 1;
			label.minHeight = 0;
			label.minWidth = 0;
			label.setStyle('textAlign', 'center');
			label.setStyle('color', '0xFFFFFF');
			label.setStyle('fontFamily', 'Arial');
			label.setStyle('paddingTop', 3);
			label.setStyle('paddingBottom', 1);
			label.setStyle('paddingLeft', 1);
			label.setStyle('paddingRight', 1);
			this.addElement(label);
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if(isTextChanged)
			{
				if(label)
				{
					label.text = text;
					isTextChanged = false;
				}
			}
		
		
			var textLength:int = text.length;
			/* var fontSize:int = 12;
			if(label)
				fontSize = label.getStyle("fontSize"); */
			if(textLength > minDigits)
			{
				this.width = (textLength * 2.5) + minWidth;
				//this.height = textLength * fontSize;
			}
		}
		
		override public function updatePopUpPosition():void
		{
			if(!owner) return;
			
			var ownerComponent:UIComponent = owner as UIComponent;
			PopUpManager.centerPopUp(this);
			//this.validateNow();
			this.x = this.x + (ownerComponent.width / 2);
			this.y = this.y - (ownerComponent.height / 2);
		}
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if(isOpen && updateBubblePosition)
			{
				updatePopUpPosition();
				updateBubblePosition = false;
			}
		}
		
	}
}