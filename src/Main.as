package
{
	import net.flashpunk.Engine;
	import net.flashpunk.FP;
	
	public class Main extends Engine
	{
		public function Main()
		{
			super(1024, 768, 60, false);
			
			Constants.initGraphics();
			Constants.initTreasureDb();
			
			FP.world = new WorldGameplay;
		}

		override public function init():void
		{
			trace("FlashPunk has started successfully!");
		}

	}
}