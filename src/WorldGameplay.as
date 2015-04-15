package
{
	import net.flashpunk.World;
	public class WorldGameplay extends World
	{
		public function WorldGameplay()
		{
			trace("Creating the World for Gameplay.");
			
			add (new Board);
		}
	}
}