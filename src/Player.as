package  
{
	import net.flashpunk.FP;
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.graphics.Text;
	import net.flashpunk.utils.*;
	
	public class Player 
	{
		internal var playerNumber:int = -1;
		
		internal var level:int = 1;
		protected var skillPoints:Array = [14, 2, 3, 3];
		
		internal var name:String = "Nameless"; // TODO - funny default name
		internal var hp:int = 10;
		internal var maxHp:int = 10;
		internal var credits:int = 0;
		
		internal var hand:Vector.<BoardCard>;
		internal var items:Vector.<BoardItem>;
		internal var position:BoardPosition;
		
		internal var legDamage:Boolean = false;
		internal var stunTurnCounter:int = 0;
		
		internal var handicapLevels:int = 0; // levels below highest player. handicap points from this
		internal var flagPoints:int = 0;
		internal var damageGiven:int = 0; // attack points calculated from these two
		internal var enemiesKOed:int = 0;
		internal var stepsWalked:int = 0; // move points calculated 
		// item points calculated from items obtained
		
		internal var card_boardActivated:BoardCard;
		internal var cardBonus_movement:int = 0;
		
		internal var card_combatActivated:BoardCard;
		internal var cardBonus_attack:int = 0;
		internal var cardBonus_defense:int = 0;
		internal var cardBonus_escape:int = 0;
		internal var cardBonus_evade:int = 0;
		
		internal var lastEscapeRoll:Array = [];
		internal var lastMovementRoll:Array = [];
		internal var lastCombatRoll:Array = [];
		
		// UX things
		internal var headerStr:Text;
		internal var hpStr:Text;
		internal var statStr:Text;
		internal var pointsStr:Text;
		
		public function Player(number:int, mName:String, mPosition:BoardPosition) 
		{
			playerNumber = number;
			name = mName;
			position = mPosition.deepCopy();
			initSelf();
		}		
		
		public function initSelf():void {
			hand = new Vector.<BoardCard>();
			items = new Vector.<BoardItem>();
			
			maxHp = (skillPoints[Constants.SKILL_HP] * 3) + 7;
			
			initUX();
		}
		
		public function getPlayerNumber():int {
			return playerNumber;
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
			
			for (var i:int = 0; i < items.length; i++) {
				var item:BoardItem = items[i];
				atk += item.getAttackBonus();
			}
			
			return atk;
		}
		
		public function getDefense():int
		{
			var def:int = skillPoints[Constants.SKILL_DEF] / 2;
			
			for (var i:int = 0; i < items.length; i++) {
				var item:BoardItem = items[i];
				def += item.getDefenseBonus();
			}
				
			return def;
		}
		
		public function getMoveBonus():int
		{
			var move:int = 0;
			
			for (var i:int = 0; i < items.length; i++) {
				var item:BoardItem = items[i];
				move += item.getMoveBonus();
			}
			
			if (!legDamage) {
				move += skillPoints[Constants.SKILL_MOVE] / 3;
			}
			
			return move;
		}
		
		public function getHp():int
		{
			return hp;
		}
		
		public function getMaxHp():int
		{
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
		
		public function getItems():Vector.<BoardItem> {
			return items; // TODO: does this need deep copy
		}
		
		public function removeItem(index:int):BoardItem {
			return items.splice(index, 1)[0];
		}
		
		public function addItem(item:BoardItem):void {
			items.push(item);
		}
		
		// TODO: does this hilariously wreck MVC modeling? yes but w/e
		public function createMovementRollOverlay():OverlayMovementRoll {
			return new OverlayMovementRoll(this, getMovementRoll(), getMoveBonus(), cardBonus_movement, getMovementRollValue());
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
			lastMovementRoll.push(Math.ceil(FP.rand(6)+1));
			return getMovementRollValue();
		}
		
		public function getCombatRoll():Array  
		{
			return Constants.deepCopyArray(lastCombatRoll);
		}
		
		public function getCombatRollValue(onAttack:Boolean):int {
			var combat:int = onAttack ? getAttack() : getDefense();
			for (var i:int = 0; i < lastCombatRoll.length; i++) {
				combat += lastCombatRoll[i];
			}
			combat += onAttack ? cardBonus_attack : cardBonus_defense;
			
			return combat;
		}
		
		public function doCombatRoll(onAttack:Boolean):int
		{
			lastCombatRoll = [];
			// TODO: display roll somewhere
			lastCombatRoll.push(Math.ceil(FP.rand(6)+1));
			lastCombatRoll.push(Math.ceil(FP.rand(6) + 1));
			var noun:String = onAttack ? "attack" : "defense";
			trace(name + " " + noun + " roll: " + lastCombatRoll[0] + "," + lastCombatRoll[1] + " -> " + getCombatRollValue(onAttack));
			return getCombatRollValue(onAttack);
		}
		
		public function getEscapeRoll():Array  
		{
			return Constants.deepCopyArray(lastEscapeRoll);
		}
		
		public function getEscapeRollValue():int {
			var escapeVal:int = getMoveBonus();
			for (var i:int = 0; i < lastEscapeRoll.length; i++) {
				escapeVal += lastEscapeRoll[i];
			}
			escapeVal += cardBonus_escape;
			
			return escapeVal;
		}
		
		public function getCardBonusEscape():int {
			return cardBonus_escape;
		}
		
		public function getCardBonusAttack():int {
			return cardBonus_attack;
		}
		
		public function getCardBonusDefense():int {
			return cardBonus_defense;
		}
		
		public function doEscapeRoll():int
		{
			lastEscapeRoll = [];
			// TODO: display roll somewhere
			lastEscapeRoll.push(Math.ceil(FP.rand(6)+1));
			lastEscapeRoll.push(Math.ceil(FP.rand(6) + 1));
			trace(name + " escape roll: " + lastEscapeRoll[0] + "," + lastEscapeRoll[1] + " -> " + getEscapeRollValue());
			return getEscapeRollValue();
		}

		public function moveToSpace(newSpace:BoardPosition):void
		{
			position = newSpace;
		}
		
		public function incrementStepsWalked(count:int):void {
			stepsWalked += count;
		}
		
		public function setHandicapFromMaxLevel(maxLv:int):void {
			if (level < maxLv) {
				handicapLevels = maxLv - level;
			}
		}
		
		public function awardFlagPoints(pts:int):void {
			flagPoints += pts;
		}
		
		public function incrementDamageGiven(dmg:int):void {
			damageGiven += dmg;
		}
		
		public function incrementEnemiesKOed(dmg:int):void {
			enemiesKOed += dmg;
		}
		
		public function changeHp(delta:int):void {
			hp += delta;
			
			if (hp < 0) {
				hp = 0;
				// if you die, respawning will happen manually
			}
			if (hp > getMaxHp()) {
				hp = getMaxHp();
			}
		}
		
		public function respawn():void {
			if (hp <= 0) {
				maxHp = Math.ceil(maxHp / 2); // cut max hp in half when you die
				
				hp = maxHp;
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
		
		// TODO - i have literally no idea how this works in the real game
		public function rollToEvadeTrap():Boolean {
			if (cardBonus_evade >= 99999) { // perfect evade from cards
				return true;
			}
			
			// temporary formula
			var totalEvade:int = getMoveBonus() + cardBonus_evade + 1;
			return Math.random() * 25 < totalEvade;
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
		
		public function giveTreasureWithId(treasureId:int):void {
			var newItem:BoardItem = BoardItem.BoardItemFromId(treasureId);
			newItem.fromThisBoard = true;
			items.push(newItem);
		}
		
		public function prepareForTurn():void {
			card_boardActivated = null;
			cardBonus_movement = 0;
			cardBonus_attack = 0;
			cardBonus_defense = 0;
			cardBonus_escape = 0;
			cardBonus_evade = 0;
			card_combatActivated = null;
			card_boardActivated = null;
			
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
				cardBonus_evade = card.value;
				
				if (card.value == Constants.DEF_A || card.value == Constants.DEF_D) {
					cardBonus_evade = 99999; // always perfect evade (TODO: confirm this)
				}
			}
			
			// TRAPs placed on board in update_doRoll
			
			// ATK cards should not be usable on board
			
			hand.splice(index, 1); // remove the card from the hand	
			
			return card;
		}
		
		public function getLastCombatCard():BoardCard {
			return card_combatActivated;
		}
		
		public function activateCardOnCombat(index:int, opponent:Player):BoardCard
		{
			var card:BoardCard = hand[index];
			card_combatActivated = card;
			
			if (card.type == Constants.CARD_MOVE) {
				cardBonus_escape = card.value;
				
				if (card.value == Constants.MOVE_EXIT) {
					cardBonus_escape = 99999; // always guaranteed victory
				}
			}
			
			if (card.type == Constants.CARD_DEF) {
				cardBonus_defense = card.value;
				
				if (card.value == Constants.DEF_A) {
					cardBonus_defense = 99999; // always perfect defense
				}
				
				if (card.value == Constants.DEF_D) {
					cardBonus_defense = getDefense(); // double defense
				}
			}
			
			if (card.type == Constants.CARD_ATK) {
				cardBonus_attack = card.value;
				
				if (card.value == Constants.ATK_S) {
					cardBonus_attack = getAttack(); // double attack
				}
				
				if (card.value == Constants.ATK_C) {
					cardBonus_attack = opponent.getAttack(); // + opponent's attack
				}
			}
			
			// TRAP cards should not be usable on combat
			
			hand.splice(index, 1); // remove the card from the hand	
			
			return card;
		}
		
		public function getActivatedCardBoard():BoardCard {
			return card_boardActivated;
		}
		
		public function calculateTotalPoints():int {
			var totalPoints:int = 0;
			totalPoints += handicapLevels * Constants.POINTS_PER_HANDICAP_LEVEL;
			totalPoints += stepsWalked * Constants.POINTS_PER_STEP;
			totalPoints += damageGiven * Constants.POINTS_PER_ATTACK_DAMAGE;
			totalPoints += enemiesKOed * Constants.POINTS_PER_KO;
			totalPoints += flagPoints;
			for (var i:int = 0; i < items.length; i++) {
				var item:BoardItem = items[i];
				if (item.fromThisBoard) {
					totalPoints += item.pointValue;
				}
			}
			return totalPoints;
		}
		
		// UX things
		
		public function initUX():void
		{
			// TODO: UX for trap damage?
			
			var nameAndStatusString:String = name;
			if (isStunned()) {
				nameAndStatusString = "[STUN] " + name;
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
			
			var totalPoints:int = calculateTotalPoints();
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
		
		public function getPlayerSprite():Image {
			return Constants.PLAYER_SPRITES[getPlayerNumber()];
		}
	}

}