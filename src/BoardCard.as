package  
{
	import net.flashpunk.graphics.Image;
	/**
	 * ...
	 * @author ...
	 */
	public class BoardCard 
	{
		public var image:Image;
		public var type:int;
		public var value:int;
		
		public function BoardCard(i:Image, t:int, v:int) 
		{
			image = i;
			type = t;
			value = v;
		}
		
		public static function BoardCardFromArray(a:Array):BoardCard {
			return new BoardCard(a[0], a[1], a[2]);
		}
		
		public function deepCopy():BoardCard {
			return new BoardCard(image, type, value);
		}
		
	}

}