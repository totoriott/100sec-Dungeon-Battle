package  
{
	/**
	 * contains a path of squares
	 */
	
	public class BoardWalk 
	{
		public var spaces:Array;
		
		public function BoardWalk() 
		{
			spaces = [];
		}
		
		public function deepCopy():BoardWalk {
			var copy:BoardWalk = BoardWalk();
			copy.spaces = Constants.deepCopyArray(spaces);
			return copy;
		}
		
	}

}