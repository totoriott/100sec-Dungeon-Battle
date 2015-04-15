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
		
		internal var hand:Vector.<BoardCard>;
		internal var items:Array = [];
		internal var position:BoardPosition;
		
		internal var legDamage:Boolean = false;
		internal var stunTurnCounter:int = 0;
		internal var flagPoints:int = 0;
		
		internal var card_boardActivated:BoardCard;
		internal var cardBonus_movement:int = 0;
		
		internal var lastMovementRoll:Array = [];
		
		// UX things
		internal var headerStr:Text;
		internal var hpStr:Text;
		internal var statStr:Text;
		internal var pointsStr:Text;
		
		public function Player(mName:String, mPosition:BoardPosition) 
		{
			name = mName;
			position = mPosition.deepCopy();
			hand = new Vector.<BoardCard>();
			
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
			if (legDamage) { // grr
				return 0;
			}
			
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
		
		public function getPosition():BoardPosition
		{
			return position.deepCopy();
		}
		
		public function getCards():Vector.<BoardCard>
		{
			return hand; // TODO: do i need to deep copy lol
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
			moves += cardBonus_movement;
			
			return moves;
		}
		
		public function doMovementRoll():int
		{
			lastMovementRoll = [];
			// TODO: display roll somewhere
			lastMovementRoll.push(Math.ceil(FP.rand(5)+1));
			return getMovementRollValue();
		}

		public function moveToSpace(newSpace:BoardPosition):void
		{
			position = newSpace;
		}
		
		public function awardFlagPoints(pts:int):void {
			flagPoints += pts;
		}
		
		public function changeHp(delta:int):void {
			hp += delta;
			
			if (hp < 0) {
				hp = 0;
				// TODO: oh no! you died
			}
			if (hp > getMaxHp()) {
				hp = getMaxHp();
			}
		}
		
		// TODO - you could sort the hands even though you hella don't in battle hunter
		public function giveCard(newCard:BoardCard):void
		{
			if (hand.length >= Constants.HAND_CARD_LIMIT)
			{
				trace("Recieved a card even though hand is at max size");
			}
			else if (newCard != null)
			{
				hand.push(newCard.deepCopy());
			}
		}
		
		public function sufferFromTrap(value:int):void {
			switch (value) {
				case Constants.TRAP_DAMAGE:
					changeHp(-1 * Math.ceil(hp / 2)); // lose half your HP
					break;
					
				case Constants.TRAP_EMPTY:
					hand = hand.slice(0, 0); // now you have no more cards
					break;
					
				case Constants.TRAP_LEG:
					legDamage = true; // prevents your move bonus
					break;
					
				case Constants.TRAP_STUN:
					stunTurnCounter = 2; // this turn and next
					break;
			}
		}
		
		public function prepareForTurn():void {
			card_boardActivated = null;
			cardBonus_movement = 0;
			
			initUX();
		}
		
		public function finishTurn():void {
			if (stunTurnCounter > 0) {
				stunTurnCounter--;
			}
			
			initUX();
		}
		
		public function isStunned():Boolean {
			return stunTurnCounter > 0;
		}
		
		// use a card when moving about the board
		public function activateCardOnBoard(index:int):BoardCard
		{
			var card:BoardCard = hand[index];
			card_boardActivated = card;
			
			// EXIT card is handled on return
			if (card.type == Constants.CARD_MOVE) {
				cardBonus_movement = card.value;
			}
			
			if (card.type == Constants.CARD_DEF) {
				// TODO: increase trap evasion
			}
			
			if (card.type == Constants.CARD_TRAP) {
				// TODO: place trap
			}
			
			// ATK cards should not be usable on board
			
			hand.splice(index, 1); // remove the card from the hand	
			
			return card;
		}
		
		public function getActivatedCardBoard():BoardCard {
			return card_boardActivated;
		}
		
		// UX things
		
		public function initUX():void
		{
			// TODO: UX for trap damage?
			
			var nameAndStatusString:String = name;
			if (isStunned()) {
				name = "[STUN] " + name;
			}
			
			headerStr = new Text(name + " Lv." + level.toString());
			headerStr.font = "Segoe";
			headerStr.color = 0x000000;
			
			hpStr = new Text(hp.toString() + " / " + getMaxHp().toString() + " HP");
			hpStr.font = "Segoe";
			hpStr.color = 0x000000;
				
			statStr = new Text(getAttack().toString() + " ATK / " + getDefense().toString() + " DEF / +" + getMoveBonus().toString() + " MOVE");
			statStr.font = "Segoe";
			statStr.color = 0x000000;
			
			var totalPoints:int = flagPoints;
			pointsStr = new Text(totalPoints.toString() + "pts");
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