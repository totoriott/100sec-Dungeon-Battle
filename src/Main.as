package
{
	import net.flashpunk.Engine;
	import net.flashpunk.FP;
	
	public class Main extends Engine
	{
		public function Main()
		{
			super(800, 600, 60, false); // TODO: do you want bigger game
			
			Constants.initGraphics();
			Constants.initCombatGraphics();
			Constants.initTreasureDb();
			Constants.initEnemyDb();
			Constants.initOverlayGraphics();
			
			FP.world = new WorldGameplay;
		}

		override public function init():void
		{
			trace("FlashPunk has started successfully!");
		}

	}
}