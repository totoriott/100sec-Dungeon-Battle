package  
{
	import net.flashpunk.FP;
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.graphics.Text;
	import net.flashpunk.utils.*;
	
	public class Player 
	{
		internal var level:int = 1;
		internal var skillPoints:Array = [1, 1, 1, 1];
		
		internal var name:String = "Nameless"; // TODO - funny default name
		internal var hp:int = 10;
		internal var credits:int = 0;
		
		internal var hand:Array = [];
		internal var items:Array = [];
		internal var position:Array = [];
		internal var points:int = 0;
		
		internal var lastMovementRoll:Array = [];
		
		// UX things
		internal var headerStr:Text;
		internal var hpStr:Text;
		internal var statStr:Text;
		internal var pointsStr:Text;
		
		public function Player(mName:String, mPosition:Array) 
		{
			name = mName;
			position = Constants.deepCopyArray(mPosition);
			
			initUX();
		}		
		
		public function getName():String
		{
			return name;
		}
		
		public function getLevel():int
		{
			return level;
		}
		
		public function getAttack():int
		{
			var atk:int = skillPoints[Constants.SKILL_ATK];
			return atk;
		}
		
		public function getDefense():int
		{
			var def:int = skillPoints[Constants.SKILL_DEF] / 2;
			return def;
		}
		
		public function getMoveBonus():int
		{
			var move:int = skillPoints[Constants.SKILL_MOVE] / 3;
			return move;
		}
		
		public function getHp():int
		{
			return hp;
		}
		
		public function getMaxHp():int
		{
			var maxHp:int = (skillPoints[Constants.SKILL_HP] * 3) + 7;
			return maxHp;
		}
		
		public function getPosition():Array
		{
			return Constants.deepCopyArray(position);
		}
		
		public function getCards():Array
		{
			return Constants.deepCopyArray(hand);
		}
		
		public function getMovementRoll():Array  
		{
			return Constants.deepCopyArray(lastMovementRoll);
		}
		
		public function getMovementRollValue():int  
		{
			var moves:int = getMoveBonus();
			for (var i:int = 0; i < lastMovementRoll.length; i++) {
				moves += lastMovementRoll[i];
			}
			return moves;
		}
		
		public function doMovementRoll():int
		{
			lastMovementRoll = [];
			// TODO: display roll somewhere
			lastMovementRoll.push(Math.ceil(FP.rand(5)+1));
			return getMovementRollValue();
		}

		public function moveToSpace(newSpace:Array):void
		{
			position = newSpace;
		}
		
		// TODO - you could sort the hands even though you hella don't in battle hunter
		public function giveCard(newCard:Array):void
		{
			if (hand.length >= Constants.HAND_CARD_LIMIT)
			{
				trace("Recieved a card even though hand is at max size");
			}
			else if (newCard != null)
			{
				hand.push(Constants.deepCopyArray(newCard));
			}
		}
		
		// use a card when moving about the board
		public function activateCardOnBoard(index:int):void
		{
			hand.splice(index, 1); // remove the card from the hand	
			
			// TODO: gain its effect
		}
		
		// UX things
		
		public function initUX():void
		{
			headerStr = new Text(name + " - Lv. " + level.toString());
			headerStr.font = "Segoe";
			headerStr.color = 0x000000;
			
			hpStr = new Text(hp.toString() + " / " + getMaxHp().toString() + " HP");
			hpStr.font = "Segoe";
			hpStr.color = 0x000000;
				
			statStr = new Text(getAttack().toString() + " ATK / " + getDefense().toString() + " DEF / +" + getMoveBonus().toString() + " MOVE");
			statStr.font = "Segoe";
			statStr.color = 0x000000;
			
			pointsStr = new Text(points.toString() + "pts");
			pointsStr.font = "Segoe";
			pointsStr.color = 0x000000;
		}
		
		public function getHeaderStr():Text
		{
			return headerStr;
		}
		
		public function getHpStr():Text
		{
			return hpStr;
		}
		
		public function getStatStr():Text
		{
			return statStr;
		}
		
		public function getPointsStr():Text
		{
			return pointsStr;
		}
	}

}