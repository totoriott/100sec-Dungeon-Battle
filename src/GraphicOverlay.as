package  
{	
	import flash.display.Graphics;
	import flash.utils.Dictionary;
	import net.flashpunk.FP;
	import net.flashpunk.Entity;
	import net.flashpunk.Graphic;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.graphics.Text;
	import net.flashpunk.utils.*;
	
	/**
	 * this is something we show over the board during the progress of a game. it halts progress and stuff to display a thing
	 */
	public class GraphicOverlay 
	{
		protected var textCache:Dictionary;
		
		protected var timer:int = 0;
		
		protected var curTimerSchedule:int = 0; // used with functions for alpha fadein/out below 
		protected var fadeOutStartTime:int = 0; // override this in subclasses
		protected var fadeOutLength:int = 0; // override this in subclasses
		
		public function GraphicOverlay() 
		{
			
		}
		
		public function render(x:int, y:int):void
		{
			// timer should be handled in subclasses
		}
			
		public function update(inputArray:Array):void 
		{
			// timer should be handled in subclasses
		}
		
		public function isDoneShowing():Boolean 
		{
			return true;
		}
		
		// Caches text strings and returns/creates them intelligently
		public function getText(text:String, size:int):Text {
			if (textCache == null) {
				textCache = new Dictionary();
			}
			
			var key:String = text + size;
			if (textCache[key] == null) {
				var newText:Text = new Text(text, 0, 0, { "size": size } );
				newText.font = "Segoe";
				newText.color = 0xFFFFFF; // TODO: modify this?
				textCache[key] = newText;
			}
			
			return textCache[key];
		}
		
		// Functions for easily managing alpha fade-in/out timing 
		public function startTimerSchedule():void {
			curTimerSchedule = 0;
		}
		
		// uses the timer schedule to figure out what the alpha should be at this point.
		// assumes everything should fade out at the same time at the end of the overlay (TODO: maybe change)
		public function fadeInForAndDelayAfter(fadeTime:int, delayTime:int):Number {
			var alpha:Number = Constants.graphicsAnimationPercentFromTiming(timer, curTimerSchedule, fadeTime, fadeOutStartTime, fadeOutLength);
			
			curTimerSchedule += fadeTime + delayTime;
			
			return alpha;
		}
	}

}