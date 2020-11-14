/*********************************************************************

	FILE: create_ygo_db.sql
    DATE: 2020-05-06
    AUTHOR: Jory A. Wernette
    DESCRIPTION:
		Builds the database, related tables, and stored procedures for the Yu-Gi-Oh Database.

*********************************************************************/

DROP DATABASE IF EXISTS ygo_db;
CREATE DATABASE ygo_db;

USE ygo_db;

/* ************************************************************
	Create statement for the Players table
*********************************************************** */
DROP TABLE IF EXISTS Players;
CREATE TABLE Players(
	PlayerName VARCHAR(256) PRIMARY KEY COMMENT 'The name or nickname for a player who uses the database.'
    , PlayerId INT(10) NOT NULL COMMENT 'The Konami ID for the player.'
    
) COMMENT 'The table describing each player who uses the database.'
;

/* ************************************************************
	Create statement for the Cards table
*********************************************************** */
DROP TABLE IF EXISTS Cards;
CREATE TABLE Cards(
	CardID CHAR(9) NOT NULL COMMENT 'The Set ID for the card.'
    , CardName VARCHAR(75) PRIMARY KEY COMMENT 'The name of the Card.'
    , CardCategory ENUM('Monster', 'Spell', 'Trap') NOT NULL COMMENT 'The category of the card.'
    , CardType ENUM('Normal', 'Effect', 'Fusion', 'Synchro', 'Xyz', 'Link', 'Ritual', 'Field' 
		, 'Equip', 'Quick-Effect', 'Continuous', 'Counter')
        NOT NULL COMMENT 'The type of the Card.'
    , MonsterType ENUM('Aqua', 'Beast', 'Beast-Warrior', 'Cyberse', 'Dinosaur', 'Divine-Beast'
		, 'Dragon', 'Fairy', 'Fiend', 'Fish', 'Insect', 'Machine', 'Plant', 'Psychic', 'Pyro'
        , 'Reptile', 'Rock', 'Sea Serpent', 'Spellcaster', 'Thunder', 'Warrior', 'Winged-Beast'
        , 'Wyrm', 'Zombie', '') NOT NULL COMMENT 'The type of monster of a monster card.'
	, SubType ENUM ('Flip', 'Gemini', 'Pendulum', 'Spirit', 'Toon', 'Tuner', 'Union', '')
		NOT NULL COMMENT 'The sub type of a monster card'
	, Attribute ENUM ('Dark', 'Divine', 'Earth', 'Fire', 'Light', 'Water', 'Wind', '') NOT NULL
		COMMENT 'The attribute of a monster card.'
	, LevelRank ENUM ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12') NULL
		COMMENT 'The Level or Rank of a monster.'
	, Attack INT NULL COMMENT 'The attack points of a monster'
    , Defense INT NULL COMMENT 'The defense points of a monster'
    , PendulumScale INT NULL COMMENT 'The Scale of a Pendulum monster.'
    , LinkNumber INT NULL COMMENT 'The Link Number of a Link monster.'
    , Banlist ENUM ('Banned', 'Limited', 'Semi-Limited', 'Unlimited') NOT NULL COMMENT 'Where the cards sits with regards to the banlist.'
    , CardText VARCHAR(1000) NOT NULL COMMENT 'The effect or flavor text of a card.'
    , SetName VARCHAR(256) NOT NULL COMMENT 'The name of the set this card was originally released in.'
    
    /*
    , CONSTRAINT fk_CardsSetName_SetListSetName
		FOREIGN KEY (SetName) REFERENCES SetList(SetName)
    Error Code: 1824. Failed to open the referenced table 'setlist'

    */
    
) COMMENT 'General information about what a card is made of.'
;

/* ************************************************************
	Create statement for the CardsAuditTrail table
*********************************************************** */
DROP TABLE IF EXISTS CardsAuditTrail;
CREATE TABLE CardsAuditTrail(
		ChangeDescription VARCHAR(256) NOT NULL COMMENT 'The type of change made to the cards table.'
        , UserId VARCHAR(256) NOT NULL COMMENT 'The user who made the change.' 
        , ChangeDateTime DATETIME NOT NULL COMMENT 'The date and time when the change was made.' 
) COMMENT 'The table that tracks changes made to the cards table.'
;

/* ************************************************************
	Create statement for Decks table
*********************************************************** */
DROP TABLE IF EXISTS Decks;
CREATE TABLE Decks(
	DeckName VARCHAR(50) PRIMARY KEY COMMENT 'The name of a saved Deck.'
    , PlayerName VARCHAR(256) NOT NULL COMMENT 'The player who created the deck.'
    , PlayerId INT(10) NOT NULL COMMENT 'The Player ID of the player who created the deck.'
	
    , CONSTRAINT fk_DecksPlayerName_PlayersPlayerName
		FOREIGN KEY (PlayerName) REFERENCES Players(PlayerName)
        


) COMMENT 'A list of the Names and DeckIds of the saved decks in the database.'
;

/* ************************************************************
	Create statement for SetList table
*********************************************************** */
DROP TABLE IF EXISTS SetList;
CREATE TABLE SetList(
	SetName VARCHAR(256) PRIMARY KEY COMMENT 'The name of the set.'
    , ReleaseDate DATE NOT NULL COMMENT 'When the set will be released in in the TCG, North America.'
    , SetAbbreviation CHAR(3) NOT NULL COMMENT 'The three character set name abreviation that appears in the cardID for a card.'
    , ExtaInformation VARCHAR(500) NULL COMMENT 'Any extra information about the set.' 
    
) COMMENT 'The information on sets including their release dates, abreviations, and any other information, like fun facts.'
;

/* ************************************************************
	Create statement for the Stall deck
*********************************************************** */
DROP TABLE IF EXISTS Stall;
CREATE TABLE Stall(
	CardName VARCHAR(75) NOT NULL COMMENT 'The name of the Card.'
    , AmountOfThatCard ENUM('1','2','3') NOT NULL COMMENT 'How many of that card are in the deck. Per yugioh rules, can only have up to 3 of the same card.'
        
	, CONSTRAINT fk_StallCardName_CardsCardName
		FOREIGN KEY (CardName)REFERENCES Cards(CardName)
        
) COMMENT 'The table built to give information about what is in the Defense Stall deck.'
;

/* ************************************************************
	Create statement for the Beatdown deck
*********************************************************** */
DROP TABLE IF EXISTS Beatdown;
CREATE TABLE Beatdown(
	CardName VARCHAR(75) NOT NULL COMMENT 'The name of the Card.'
    , AmountOfThatCard ENUM('1','2','3') NOT NULL COMMENT 'How many of that card are in the deck. Per yugioh rules, can only have up to 3 of the same card.'
	    
	, CONSTRAINT fk_BeatdownCardName_CardsCardName
		FOREIGN KEY (CardName)REFERENCES Cards(CardName)
        
) COMMENT 'The table built to give information about what is in the Defense Stall deck.'
;

/* ************************************************************
	Create statement for the Girly deck
*********************************************************** */
DROP TABLE IF EXISTS Girly;
CREATE TABLE Girly(
	CardName VARCHAR(75) NOT NULL COMMENT 'The name of the Card.'
    , AmountOfThatCard ENUM('1','2','3') NOT NULL COMMENT 'How many of that card are in the deck. Per yugioh rules, can only have up to 3 of the same card.'
            
	 -- , CONSTRAINT fk_GirlyCardName_CardsCardName
		-- FOREIGN KEY (CardName)REFERENCES Cards(CardName)
        -- I copy pasted this from the other deck tables, yet it throws 
        -- Error Code: 1452. Cannot add or update a child row: a foreign key constraint fails 
			-- (`ygo_db`.`girly`, CONSTRAINT `fk_GirlyCardName_CardsCardName` FOREIGN KEY (`CardName`) REFERENCES `cards` (`cardname`))

        
) COMMENT 'The table built to give information about what is in the Defense Stall deck.'
;

/* ************************************************************
	 The procedure to get all the cards in the Cards table.
*********************************************************** */
DELIMITER $$
DROP PROCEDURE IF EXISTS sp_get_all_Cards$$
CREATE PROCEDURE sp_get_all_Cards()
COMMENT 'Returns all of the cards in the Cards table.'
BEGIN
	SELECT
	CardID
    , CardName
    , CardCategory
    , CardType
    , MonsterType
    , SubType
    , Attribute
    , LevelRank
    , Attack
    , Defense
    , PendulumScale
    , LinkNumber
    , Banlist
    , CardText
    , SetName
	FROM Cards
	;

END$$
DELIMITER ; 

/* ************************************************************
	 The procedure to get all the monster cards in the Cards table.
*********************************************************** */
DELIMITER $$
DROP PROCEDURE IF EXISTS sp_get_all_Monster_Cards$$
CREATE PROCEDURE sp_get_all_Monster_Cards()
COMMENT 'Returns all of the cards in the Cards table.'
BEGIN
	SELECT
	CardID
    , CardName
    , CardCategory
    , CardType
    , MonsterType
    , SubType
    , Attribute
    , LevelRank
    , Attack
    , Defense
    , PendulumScale
    , LinkNumber
    , Banlist
    , CardText
    , SetName
	FROM Cards
    WHERE CardCategory = 'Monster'
	;

END$$
DELIMITER ; 

/* ************************************************************
	 The procedure to get all the spell cards in the Cards table.
*********************************************************** */
DELIMITER $$
DROP PROCEDURE IF EXISTS sp_get_all_Spell_Cards$$
CREATE PROCEDURE sp_get_all_Spell_Cards()
COMMENT 'Returns all of the cards in the Cards table.'
BEGIN
	SELECT
	CardID
    , CardName
    , CardCategory
    , CardType
    , Banlist
    , CardText
    , SetName
	FROM Cards
    WHERE CardCategory = 'Spell'
	;

END$$
DELIMITER ; 

/* ************************************************************
	 The procedure to get all the trap cards in the Cards table.
*********************************************************** */
DELIMITER $$
DROP PROCEDURE IF EXISTS sp_get_all_Trap_Cards$$
CREATE PROCEDURE sp_get_all_Trap_Cards()
COMMENT 'Returns all of the cards in the Cards table.'
BEGIN
	SELECT
	CardID
    , CardName
    , CardCategory
    , CardType
    , Banlist
    , CardText
    , SetName
	FROM Cards
    WHERE CardCategory = 'Trap'
	;

END$$
DELIMITER ; 

/* ************************************************************
	Create a trigger to record inserts to the Cards table 
*********************************************************** */
DELIMITER $$
DROP TRIGGER IF EXISTS tr_cards_after_insert$$
CREATE TRIGGER tr_cards_after_insert
AFTER INSERT ON Cards
FOR EACH ROW
BEGIN
	INSERT INTO CardsAuditTrail(
		ChangeDescription
        , UserId
        , ChangeDateTime
    ) VALUES(
		'INSERT'
        , current_user()
        , now()
    )
    ;
	
END$$
DELIMITER ;

/* ************************************************************
	 The procedure to create a new card and insert it into the Cards table.
*********************************************************** */
DELIMITER $$
DROP PROCEDURE IF EXISTS sp_create_Card$$
CREATE PROCEDURE sp_create_Card(
	IN p_CardID CHAR(9)
    , IN p_CardName VARCHAR(75)
    , IN p_CardCategory ENUM('Monster', 'Spell', 'Trap')
    , IN p_CardType ENUM('Normal', 'Effect', 'Fusion', 'Synchro', 'Xyz', 'Link', 'Ritual', 'Field' 
		, 'Equip', 'Quick-Effect', 'Continuous', 'Counter')
    , IN p_MonsterType ENUM('Aqua', 'Beast', 'Beast-Warrior', 'Cyberse', 'Dinosaur', 'Divine-Beast'
		, 'Dragon', 'Fairy', 'Fiend', 'Fish', 'Insect', 'Machine', 'Plant', 'Psychic', 'Pyro'
        , 'Reptile', 'Rock', 'Sea Serpent', 'Spellcaster', 'Thunder', 'Warrior', 'Winged-Beast'
        , 'Wyrm', 'Zombie', '')
	, IN p_SubType ENUM ('Flip', 'Gemini', 'Pendulum', 'Spirit', 'Toon', 'Tuner', 'Union', '')
	, IN p_Attribute ENUM ('Dark', 'Divine', 'Earth', 'Fire', 'Light', 'Water', 'Wind', '')
	, IN p_LevelRank ENUM ('1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12')
	, IN p_Attack INT
    , IN p_Defense INT
    , IN p_PendulumScale INT
    , IN p_LinkNumber INT
    , IN p_Banlist ENUM ('Banned', 'Limited', 'Semi-Limited', 'Unlimited')
    , IN p_CardText VARCHAR(1000)
    , IN p_SetName VARCHAR(256)
) COMMENT 'Creates a new card in the Cards table'
BEGIN
	INSERT INTO Cards(
	CardID
    , CardName
    , CardCategory
    , CardType
    , MonsterType
    , SubType
    , Attribute
    , LevelRank
    , Attack
    , Defense
    , PendulumScale
    , LinkNumber
    , Banlist
    , CardText
    , SetName
) VALUES (
	p_CardID
    , p_CardName
    , p_CardCategory
    , p_CardType
    , p_MonsterType
    , p_SubType
    , p_Attribute
    , p_LevelRank
    , p_Attack
    , p_Defense
    , p_PendulumScale
    , p_LinkNumber
    , p_Banlist
    , p_CardText
    , p_SetName
)
	;
END$$
DELIMITER ;

/* ************************************************************
	Create a trigger to record deletes to the Cards table 
*********************************************************** */
DELIMITER $$
DROP TRIGGER IF EXISTS tr_cards_after_delete$$
CREATE TRIGGER tr_cards_after_delete
AFTER DELETE ON Cards
FOR EACH ROW
BEGIN
	INSERT INTO CardsAuditTrail(
		ChangeDescription
        , UserId
        , ChangeDateTime
    ) VALUES(
		'DELETE'
        , current_user()
        , now()
    )
    ;
	
END$$
DELIMITER ;

/* ************************************************************
	 The procedure to delete a record in the ZIP table.
*********************************************************** */
DELIMITER $$
DROP PROCEDURE IF EXISTS sp_delete_card$$
CREATE PROCEDURE sp_delete_card(
	  p_CardName CHAR(5)
) COMMENT 'Deletes a card from Cards based on its name.'
BEGIN
	DELETE FROM Cards
	WHERE
		    CardName = p_Name
	;

END$$
DELIMITER ;

/* ************************************************************
	Create a trigger to record updates to the Cards table 
*********************************************************** */
DELIMITER $$
DROP TRIGGER IF EXISTS tr_cards_after_update$$
CREATE TRIGGER tr_cards_after_update
AFTER UPDATE ON Cards
FOR EACH ROW
BEGIN
	INSERT INTO CardsAuditTrail(
		ChangeDescription
        , UserId
        , ChangeDateTime
    ) VALUES(
		'UPDATE'
        , current_user()
        , now()
    )
    ;
	
END$$
DELIMITER ;

/* ************************************************************
	 The procedure to update a card in the Cards table.
*********************************************************** */

-- Sometimes a card's effect needs to be clarified or nerfed,
--  so Konami might reprint the card with different text.

-- Or Cards will be moved around on the banlist

DELIMITER $$
DROP PROCEDURE IF EXISTS sp_update_Card$$
CREATE PROCEDURE sp_update_Card(
	IN p_ORIG_CardID CHAR(9)
    , IN p_ORIG_CardName VARCHAR(75)
    , IN p_ORIG_CardCategory ENUM('Monster', 'Spell', 'Trap')
    , IN p_ORIG_CardType ENUM('Normal', 'Effect', 'Fusion', 'Synchro', 'Xyz', 'Link', 'Ritual', 'Field' 
		, 'Equip', 'Quick-Effect', 'Continuous', 'Counter')
    , IN p_ORIG_MonsterType ENUM('Aqua', 'Beast', 'Beast-Warrior', 'Cyberse', 'Dinosaur', 'Divine-Beast'
		, 'Dragon', 'Fairy', 'Fiend', 'Fish', 'Insect', 'Machine', 'Plant', 'Psychic', 'Pyro'
        , 'Reptile', 'Rock', 'Sea Serpent', 'Spellcaster', 'Thunder', 'Warrior', 'Winged-Beast'
        , 'Wyrm', 'Zombie', '')
	, IN p_ORIG_SubType ENUM ('Flip', 'Gemini', 'Pendulum', 'Spirit', 'Toon', 'Tuner', 'Union', '')
	, IN p_ORIG_Attribute ENUM ('Dark', 'Divine', 'Earth', 'Fire', 'Light', 'Water', 'Wind', '')
	, IN p_ORIG_LevelRank ENUM ('1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12')
	, IN p_ORIG_Attack INT
    , IN p_ORIG_Defense INT
    , IN p_ORIG_PendulumScale INT
    , IN p_ORIG_LinkNumber INT
    , IN p_ORIG_Banlist ENUM ('Banned', 'Limited', 'Semi-Limited', 'Unlimited')
    , IN p_ORIG_CardText VARCHAR(1000)
    , IN p_ORIG_SetName VARCHAR(256)
    
    , IN p_NEW_CardID CHAR(9)
    , IN p_NEW__CardCategory ENUM('Monster', 'Spell', 'Trap')
    , IN p_NEW__CardType ENUM('Normal', 'Effect', 'Fusion', 'Synchro', 'Xyz', 'Link', 'Ritual', 'Field' 
		, 'Equip', 'Quick-Effect', 'Continuous', 'Counter')
    , IN p_NEW__MonsterType ENUM('Aqua', 'Beast', 'Beast-Warrior', 'Cyberse', 'Dinosaur', 'Divine-Beast'
		, 'Dragon', 'Fairy', 'Fiend', 'Fish', 'Insect', 'Machine', 'Plant', 'Psychic', 'Pyro'
        , 'Reptile', 'Rock', 'Sea Serpent', 'Spellcaster', 'Thunder', 'Warrior', 'Winged-Beast'
        , 'Wyrm', 'Zombie', '')
	, IN p_NEW__SubType ENUM ('Flip', 'Gemini', 'Pendulum', 'Spirit', 'Toon', 'Tuner', 'Union', '')
	, IN p_NEW__Attribute ENUM ('Dark', 'Divine', 'Earth', 'Fire', 'Light', 'Water', 'Wind', '')
	, IN p_NEW__LevelRank ENUM ('1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12')
	, IN p_NEW__Attack INT
    , IN p_NEW__Defense INT
    , IN p_NEW__PendulumScale INT
    , IN p_NEW__LinkNumber INT
    , IN p_NEW__Banlist ENUM ('Banned', 'Limited', 'Semi-Limited', 'Unlimited')
    , IN p_NEW__CardText VARCHAR(1000)
    , IN p_NEW__SetName VARCHAR(256)
) COMMENT 'UPDATES a card in the Cards table if the original can be found.
Otherwise raises an error.'
BEGIN
	DECLARE var_original_count INT;

	SELECT COUNT(*)	INTO var_original_count
	FROM Cards
	WHERE
		CardName = p_ORIG_CardName 
	AND	CardId = p_ORIG_CardID
    AND CardCategory = p_ORIG_CardCategory
    AND Card_type = p_ORIG_CardType
    AND MonsterType = p_ORIG_MonsterType
	AND SubType = p_ORIG_SubType
	AND Attribute = p_ORIG_Attribute
	AND LevelRank = p_ORIG_LevelRank
	AND Attack = p_ORIG_Attack
    AND Defense = p_ORIG_Defense
    AND PendulumScale = p_ORIG_PendulumScale
    AND LinkNumber = p_ORIG_LinkNumber
    AND Banlist = p_ORIG_Banlist
    AND CardText = p_ORIG_CardText
    AND SetName = p_ORIG_SetName
	;

	IF var_original_count <> 1 THEN 
		SIGNAL SQLSTATE '53000'
		SET MESSAGE_TEXT = 'Original record cannot be found.';
	END IF;

	UPDATE Cards
		SET 	
        CardId = p_NEW_CardID
    , CardCategory = p_NEW_CardCategory
    , Card_type = p_NEW_CardType
    , MonsterType = p_NEW_MonsterType
	, SubType = p_NEW_SubType
	, Attribute = p_NEW_Attribute
	, LevelRank = p_NEW_LevelRank
	, Attack = p_NEW_Attack
    , Defense = p_NEW_Defense
    , PendulumScale = p_NEW_PendulumScale
    , LinkNumber = p_NEW_LinkNumber
    , Banlist = p_NEW_Banlist
    , CardText = p_NEW_CardText
    , SetName = p_NEW_SetName
	WHERE 
		CardName = p_ORIG_CardName 
	AND	CardId = p_ORIG_CardID
    AND CardCategory = p_ORIG_CardCategory
    AND Card_type = p_ORIG_CardType
    AND MonsterType = p_ORIG_MonsterType
	AND SubType = p_ORIG_SubType
	AND Attribute = p_ORIG_Attribute
	AND LevelRank = p_ORIG_LevelRank
	AND Attack = p_ORIG_Attack
    AND Defense = p_ORIG_Defense
    AND PendulumScale = p_ORIG_PendulumScale
    AND LinkNumber = p_ORIG_LinkNumber
    AND Banlist = p_ORIG_Banlist
    AND CardText = p_ORIG_CardText
    AND SetName = p_ORIG_SetName
	;

END$$
DELIMITER ;
-- */

/* ************************************************************
	 The procedure to delete a deck from the Decks table.
*********************************************************** */
DELIMITER $$
DROP PROCEDURE IF EXISTS sp_delete_Deck$$
CREATE PROCEDURE sp_delete_Deck(
	  p_DeckName VARCHAR(75)
) COMMENT 'Deletes a deck from Decks based on the primary key field.'
BEGIN
	DROP TABLE IF EXISTS p_DeckName; -- doesn't actually drop the table.

	DELETE FROM Decks
	WHERE
		    DeckName = p_DeckName
	;
    -- DROP TABLE IF EXISTS p_DeckName;

END$$
DELIMITER ;

/* ************************************************************
	Create a trigger to delete the table of the deck being deleted
		(DROP TABLE IF EXISTS p_DeckName; isn't working)
*********************************************************** *
DELIMITER $$
DROP TRIGGER IF EXISTS tr_decks_before_delete$$
CREATE TRIGGER tr_decks_before_delete
BEFORE DELETE ON Decks
FOR EACH ROW
	DROP TABLE IF EXISTS p_DeckName;
	-- Error Code: 1422. Explicit or implicit commit is not allowed in stored function or trigger.

	-- Can't quite get it to delete a deck from both the Decks table and its own table...

END$$
DELIMITER ;
-- */

/* ************************************************************
	 Create a view to show Banlist details
*********************************************************** */
DROP VIEW IF EXISTS vw_Banlist;
CREATE VIEW vw_Banlist
AS
SELECT
	CardName
    , Banlist
FROM cards
ORDER BY Banlist
;

/* ************************************************************
	 Create a view to show details about cards from the Stall deck
*********************************************************** */
DROP VIEW IF EXISTS vw_stall_deck_details;
CREATE VIEW vw_stall_deck_details
AS
SELECT
	Stall.AmountOfThatCard
	, Stall.CardName
    , Cards.attack
    , Cards.defense
    , Cards.cardText
FROM Stall
INNER JOIN Cards
ON Stall.CardName = Cards.CardName
;

/* ************************************************************
	 Create a view to show details for a player
*********************************************************** */
DROP VIEW IF EXISTS vw_all_player_details;
CREATE VIEW vw_all_player_details
AS
SELECT
	Players.playerName
    , Players.PlayerId
    , Decks.DeckName
FROM Players
INNER JOIN Decks
ON Players.PlayerName = Decks.PlayerName
;

/* ************************************************************
	 Insert Card Data
*********************************************************** */
INSERT 
INTO Cards(
	CardID
    , CardName
    , CardCategory
    , CardType
    , MonsterType
    , SubType
    , Attribute
    , LevelRank
    , Attack
    , Defense
    , PendulumScale
    , LinkNumber
    , Banlist
    , CardText
    , SetName
)
	VALUES
    -- spaces left blank to represent cards not yet added to the db 
    -- card information can be found
    -- https://yugioh.fandom.com/wiki/Set_Card_Lists:Legend_of_Blue_Eyes_White_Dragon_(TCG-EN)
    -- That link is for Legend of Blue Eyes, but the site has all the information on the other sets too.
    ('LOB-EN000', 'Tri-Horned Dragon', 'Monster', 'Normal', 'Dragon', '', 'Dark', 8, 2850, 2350
		, NULL, NULL, 'Unlimited', 'An unworthy dragon with three sharp horns sprouting from its head.', 'Legend of Blue-Eyes')
	, ('LOB-EN001', 'Blue-Eyes White Dragon', 'Monster', 'Normal', 'Dragon', '', 'Light', 8, 3000, 2500
		, NULL, NULL, 'Unlimited', 'This legendary dragon is a powerful engine of destruction. 
        Virtually invincible, very few have faced this awesome creature and lived to tell the tale.', 'Legend of Blue-Eyes')
	, ('LOB-EN002', 'Hitotsu-Me Giant', 'Monster', 'Normal', 'Beast-Warrior', '', 'Earth', 4, 1200, 1000
		, NULL, NULL, 'Unlimited', 'A one-eyed behemoth with thick, powerful arms made for delivering punishing blows.', 'Legend of Blue-Eyes')
	, ('LOB-EN003', 'Flame Swordsman', 'Monster', 'Fusion', 'Warrior', '', 'Fire', 5, 1800, 1600
		, NULL, NULL, 'Unlimited', '"Flame Manipulator" + "Masaki the Legendary Swordsman".', 'Legend of Blue-Eyes')
	,('LOB-EN004', 'Skull Servant', 'Monster', 'Normal', 'Zombie', '', 'Dark', 1, 300, 200
		, NULL, NULL, 'Unlimited', 'A skeletal ghost that is not strong but can mean trouble in large numbers.', 'Legend of Blue-Eyes')
	, ('LOB-EN005', 'Dark Magician', 'Monster', 'Normal', 'Spellcaster', '', 'Dark', 7, 2500, 2100
		, NULL, NULL, 'Unlimited', 'The ultimate wizard in terms of attack and defense.', 'Legend of Blue-Eyes')
	, ('LOB-EN006', 'Gaia the Fierce Knight', 'Monster', 'Normal', 'Warrior', '', 'Earth', 7, 2300, 2100
		, NULL, NULL, 'Unlimited', 'A knight whose horse travels faster than the wind. His battle-charge is a force to be reckoned with.', 'Legend of Blue-Eyes')
	, ('LOB-EN007', 'Celtic Guardian', 'Monster', 'Normal', 'Warrior', '', 'Earth', 4, 1400, 1200
		, NULL, NULL, 'Unlimited', 'An elf who learned to wield a sword, he baffles enemies with lightning-swift attacks.', 'Legend of Blue-Eyes')
	, ('LOB-EN008', 'Basic Insect', 'Monster', 'Normal', 'Insect', '', 'Earth', 2, 500, 700
		, NULL, NULL, 'Unlimited', 'Usually found traveling in swarms, this creature"s ideal environment is the forest.', 'Legend of Blue-Eyes')
    , ('LOB-EN009', 'Mammoth Graveyard', 'Monster', 'Normal', 'Dinosaur', '', 'Earth', 3, 1200, 800
		, NULL, NULL, 'Unlimited', 'A mammoth that protects the graves of its pack and is absolutely merciless when facing grave-robbers.', 'Legend of Blue-Eyes')
    , ('LOB-EN010', 'Silver Fang', 'Monster', 'Normal', 'Beast', '', 'Earth', 3, 1200, 800
		, NULL, NULL, 'Unlimited', 'A snow wolf that"s beautiful to the eye, but absolutely vicious in battle.', 'Legend of Blue-Eyes')
    , ('LOB-EN011', 'Dark Gray', 'Monster', 'Normal', 'Beast', '', 'Earth', 3, 800, 900
		, NULL, NULL, 'Unlimited', 'Entirely gray, this beast has rarely been seen by mortal eyes.', 'Legend of Blue-Eyes')
    , ('LOB-EN012', 'Trial of Nightmare', 'Monster', 'Normal', 'Fiend', '', 'Dark', 4, 1300, 900
		, NULL, NULL, 'Unlimited', 'This fiend passes judgment on enemies that are locked in coffins.', 'Legend of Blue-Eyes')
    , ('LOB-EN013', 'Nemuriko', 'Monster', 'Normal', 'Spellcaster', '', 'Dark', 4, 800, 700
		, NULL, NULL, 'Unlimited', 'A child-like creature that controls a sleep fiend to beckon enemies into eternal slumber.', 'Legend of Blue-Eyes')
    , ('LOB-EN014', 'The 13th Grave', 'Monster', 'Normal', 'Zombie', '', 'Dark', 3, 1200, 900
		, NULL, NULL, 'Unlimited', 'A zombie that suddenly appeared from plot #13 - an empty grave.', 'Legend of Blue-Eyes')
    , ('LOB-EN015', 'Charubin the Fire Knight', 'Monster', 'Fusion', 'Pyro', '', 'Fire', 3, 1100, 800
		, NULL, NULL, 'Unlimited', '"Monster Egg" + "Hinotama Soul"', 'Legend of Blue-Eyes')
    , ('LOB-EN016', 'Flame Manipulator', 'Monster', 'Normal', 'Spellcaster', '', 'Fire', 3, 900, 1000
		, NULL, NULL, 'Unlimited', 'This Spellcaster attacks enemies with fire-related spells such as "Sea of Flames" and "Wall of Fire".', 'Legend of Blue-Eyes')
    , ('LOB-EN017', 'Monster Egg', 'Monster', 'Normal', 'Warrior', '', 'Dark', 3, 600, 900
		, NULL, NULL, 'Unlimited', 'A warrior hidden within an egg that attacks enemies by flinging eggshells.', 'Legend of Blue-Eyes')
    , ('LOB-EN018', 'Firegrass', 'Monster', 'Normal', 'Plant', '', 'Earth', 2, 700, 600
		, NULL, NULL, 'Unlimited', 'A fire-breathing plant found growing near volcanoes.', 'Legend of Blue-Eyes')
    , ('LOB-EN019', 'Darkfire Dragon', 'Monster', 'Fusion', 'Dragon', '', 'Fire', 4, 1500, 1250
		, NULL, NULL, 'Unlimited', '"Firegrass" + "Petit Dragon"', 'Legend of Blue-Eyes')
    , ('LOB-EN020', 'Dark King of the Abyss', 'Monster', 'Normal', 'Fiend', '', 'Dark', 3, 1200, 800
		, NULL, NULL, 'Unlimited', 'It is said that this King of the Netherworld once had the power to rule over the dark.', 'Legend of Blue-Eyes')
    , ('LOB-EN021', 'Fiend Reflection #2', 'Monster', 'Normal', 'Winged-Beast', '', 'Light', 4, 1100, 1400
		, NULL, NULL, 'Unlimited', 'A bird-beast that summons reinforcements with a hand mirror.', 'Legend of Blue-Eyes')
    , ('LOB-EN022', 'Fusionist', 'Monster', 'Fusion', 'Beast', '', 'Earth', 3, 900, 700
		, NULL, NULL, 'Unlimited', '"Petit Angel" + "Mystical Sheep #2"', 'Legend of Blue-Eyes')
    , ('LOB-EN023', 'Turtle Tiger', 'Monster', 'Normal', 'Aqua', '', 'Water', 4, 1000, 1500
		, NULL, NULL, 'Unlimited', 'A tiger encased in a protective shell that attacks with razor-sharp fangs.', 'Legend of Blue-Eyes')
    , ('LOB-EN024', 'Petit Dragon', 'Monster', 'Normal', 'Dragon', '', 'Wind', 2, 600, 700
		, NULL, NULL, 'Unlimited', 'A very small dragon known for its vicious attacks.', 'Legend of Blue-Eyes')
    , ('LOB-EN025', 'Petit Angel', 'Monster', 'Normal', 'Fairy', '', 'Light', 3, 600, 900
		, NULL, NULL, 'Unlimited', 'A quick-moving and tiny fairy that is very difficult to hit.', 'Legend of Blue-Eyes')
    , ('LOB-EN026', 'Hinotama Soul', 'Monster', 'Normal', 'Pyro', '', 'Fire', 2, 600, 500
		, NULL, NULL, 'Unlimited', 'An intensely hot flame creature that rams anything standing in its way.', 'Legend of Blue-Eyes')
    , ('LOB-EN027', 'Aqua Madoor', 'Monster', 'Normal', 'Spellcaster', '', 'Water', 4, 1200, 2000
		, NULL, NULL, 'Unlimited', 'A wizard of the waters that conjures a liquid wall to crush any enemies that oppose him.', 'Legend of Blue-Eyes')
	, ('LOB-EN028', 'Kagemusha of the Blue Flame', 'Monster', 'Normal', 'Warrior', '', 'Earth', 2, 800, 400
		, NULL, NULL, 'Unlimited', 'Serving as a double for the Ruler of the Blue Flame, he is a master swordsman that wields a fine blade.', 'Legend of Blue-Eyes')
	, ('LOB-EN029', 'Flame Ghost', 'Monster', 'Fusion', 'Zombie', '', 'Dark', 3, 1000, 800
		, NULL, NULL, 'Unlimited', '"Skull Servant" + "Dissolverock"', 'Legend of Blue-Eyes')
	, ('LOB-EN030', 'Two-Mouth Darkruler', 'Monster', 'Normal', 'Dinosaur', '', 'Earth', 3, 900, 700
		, NULL, NULL, 'Unlimited', 'A dinosaur with two deadly jaws, it stores electricity in its horn and releases high voltage bolts from the mouth on its back.', 'Legend of Blue-Eyes')
	, ('LOB-EN031', 'Dissolverock', 'Monster', 'Normal', 'Rock', '', 'Earth', 3, 900, 1000
		, NULL, NULL, 'Unlimited', 'A monster born in the lava pits, it generates intense heat that can melt away its enemies.', 'Legend of Blue-Eyes')
	, ('LOB-EN032', 'Root Water', 'Monster', 'Normal', 'Fish', '', 'Water', 3, 900, 800
		, NULL, NULL, 'Unlimited', 'An amphibian capable of calling up a massive tidal wave from the dark seas to wipe out enemy monsters.', 'Legend of Blue-Eyes')
	, ('LOB-EN033', 'The Furious Sea King', 'Monster', 'Normal', 'Aqua', '', 'Water', 3, 800, 700
		, NULL, NULL, 'Unlimited', 'Grand King of the Seven Seas, he is able to summon massive tidal waves to drown the enemy.', 'Legend of Blue-Eyes')
	, ('LOB-EN034', 'Green Phantom King', 'Monster', 'Normal', 'Plant', '', 'Earth', 3, 500, 1600
		, NULL, NULL, 'Unlimited', 'This youthful king of the forests lives in a green world, abundant with trees and wildlife.', 'Legend of Blue-Eyes')
	, ('LOB-EN035', 'Ray & Temperature', 'Monster', 'Normal', 'Fairy', '', 'Light', 3, 1000, 1000
		, NULL, NULL, 'Unlimited', 'The Sun and the North Wind join hands to deliver a devastating combination of heat and gale-force winds.', 'Legend of Blue-Eyes')
	, ('LOB-EN036', 'King Fog', 'Monster', 'Normal', 'Fiend', '', 'Dark', 3, 1000, 900
		, NULL, NULL, 'Unlimited', 'A fiend that dwells in a blinding curtain of smoke.', 'Legend of Blue-Eyes')
	, ('LOB-EN037', 'Mystical Sheep #2', 'Monster', 'Normal', 'Beast', '', 'Earth', 3, 800, 900
		, NULL, NULL, 'Unlimited', 'A monstrous sheep with a long tail for hypnotizing enemies.', 'Legend of Blue-Eyes')
	, ('LOB-EN038', 'Masaki the Legendary Swordsman', 'Monster', 'Normal', 'Warrior', '', 'Earth', 4, 1100, 1100
		, NULL, NULL, 'Unlimited', 'Legendary swordmaster Masaki is a veteran of over 100 battles.', 'Legend of Blue-Eyes')
	, ('LOB-EN039', 'Kurama', 'Monster', 'Normal', 'Winged-Beast', '', 'Wind', 3, 800, 800
		, NULL, NULL, 'Unlimited', 'A vicious bird that attacks from the skies with its whip-like tail.', 'Legend of Blue-Eyes')
	, ('LOB-EN040', 'Legendary Sword', 'Spell', 'Equip', '', '', '', NULL, NULL, NULL
		, NULL, NULL, 'Unlimited', 'Equip only to a Warrior monster. It gains 300 ATK/DEF.', 'Legend of Blue-Eyes')
	, ('LOB-EN041', 'Beast Fangs', 'Spell', 'Equip', '', '', '', NULL, NULL, NULL
		, NULL, NULL, 'Unlimited', 'A Beast-Type monster equipped with this card increases its ATK and DEF by 300 points.', 'Legend of Blue-Eyes')
	, ('LOB-EN042', 'Violet Crystal', 'Spell', 'Equip', '', '', '', NULL, NULL, NULL
		, NULL, NULL, 'Unlimited', '(This card is not treated as a "Crystal" card.)Equip only to a Zombie monster. It gains 300 ATK/DEF.', 'Legend of Blue-Eyes')
	, ('LOB-EN043', 'Book of Secret Arts', 'Spell', 'Equip', '', '', '', NULL, NULL, NULL
		, NULL, NULL, 'Unlimited', 'A Spellcaster-Type monster equipped with this card increases its ATK and DEF by 300 points.', 'Legend of Blue-Eyes')
	, ('LOB-EN044', 'Power of Kaishin', 'Spell', 'Equip', '', '', '', NULL, NULL, NULL
		, NULL, NULL, 'Unlimited', 'An Aqua-Type monster equipped with this card increases its ATK and DEF by 300 points.', 'Legend of Blue-Eyes')
    , ('LOB-EN045', 'Dragon Capture Jar', 'Trap', 'Normal', '', '', '', NULL, NULL, NULL
		, NULL, NULL, 'Unlimited', 'Change all face-up Dragon-Type monsters on the field to Defense Position, also they cannot change their battle position.', 'Legend of Blue-Eyes')
	, ('LOB-EN050', 'Umi', 'Spell', 'Field', '', '', '', NULL, NULL, NULL
		, NULL, NULL, 'Unlimited', 'Increase the ATK and DEF of all Fish, Sea Serpent, Thunder, and Aqua-Type monsters by 200 points. 
        Decrease the ATK and DEF of all Machine and Pyro-Type monsters by 200 points.', 'Legend of Blue-Eyes')
    , ('LOB-EN051', 'Yammi', 'Spell', 'Field', '', '', '', NULL, NULL, NULL
		, NULL, NULL, 'Unlimited', 'Increase the ATK and DEF of all Fiend and Spellcaster-Type monsters by 200 points. 
        Decrease the ATK and DEF of all Fairy-Type monsters by 200 points.', 'Legend of Blue-Eyes')
    , ('LOB-EN052', 'Dark Hole', 'Spell', 'Normal', '', '', '', NULL, NULL, NULL
		, NULL, NULL, 'Unlimited', 'Destroy all monsters on the field.', 'Legend of Blue-Eyes')
    , ('LOB-EN053', 'Raigeki', 'Spell', 'Normal', '', '', '', NULL, NULL, NULL
		, NULL, NULL, 'Limited', 'Destroy all monsters your opponent controls.', 'Legend of Blue-Eyes')
    , ('LOB-EN054', 'Red Medicine', 'Spell', 'Normal', '', '', '', NULL, NULL, NULL
		, NULL, NULL, 'Unlimited', 'Increase your Life Points by 500 points.', 'Legend of Blue-Eyes')
    
    , ('LOB-EN056', 'Hinotama', 'Spell', 'Normal', '', '', '', NULL, NULL, NULL
		, NULL, NULL, 'Limited', 'Inflict 500 damage to your opponent.', 'Legend of Blue-Eyes')
    , ('LOB-EN057', 'Fissure', 'Spell', 'Normal', '', '', '', NULL, NULL, NULL
		, NULL, NULL, 'Unlimited', 'Destroy the 1 face-up monster your opponent controls that has the lowest ATK (your choice, if tied).', 'Legend of Blue-Eyes')
    , ('LOB-EN058', 'Trap Hole', 'Trap', 'Normal', '', '', '', NULL, NULL, NULL
		, NULL, NULL, 'Unlimited', 'When your opponent Normal or Flip Summons 1 monster with 1000 or more ATK: Target that monster; destroy that traget.', 'Legend of Blue-Eyes')
    , ('LOB-EN059', 'Polymerization', 'Spell', 'Normal', '', '', '', NULL, NULL, NULL
		, NULL, NULL, 'Unlimited', 'Fusion Summon 1 Fusion Monster from your Extra Deck, using monsters from your hand or field as Fusion Material.', 'Legend of Blue-Eyes')
    
    , ('LOB-EN062', 'Mystical Elf', 'Monster', 'Normal', 'Spellcaster', '', 'Light', 4, 800, 2000
		, NULL, NULL, 'Unlimited', 'A delicate elf that lacks offense, but has a terrific defense backed by mystical power.', 'Legend of Blue-Eyes')
	
    , ('LOB-EN066', 'Curse of Dragon', 'Monster', 'Normal', 'Dragon', '', 'Dark', 5, 2000, 1500
		, NULL, NULL, 'Unlimited', 'A wicked dragon that taps into dark forces to execute a powerful attack.', 'Legend of Blue-Eyes')
	
    , ('LOB-EN068', 'Giant Soldier of Stone', 'Monster', 'Normal', 'Rock', '', 'Earth', 3, 1300, 2000
		, NULL, NULL, 'Unlimited', 'A giant warrior made of stone. A punch from this creature has earth-shaking results.', 'Legend of Blue-Eyes')
	
    , ('LOB-EN071', 'Reaper of the Cards', 'Monster', 'Effect', 'Fiend', 'Flip', 'Dark', 5, 1380, 1930
		, NULL, NULL, 'Unlimited', 'FLIP: Select 1 Trap Card on the field and destroy it. If the selected card is Set, pick up and see the card. If it is a Trap Card, it is destroyed. If it is a Spell Card, return it to its original position.', 'Legend of Blue-Eyes')
	
    , ('LOB-EN078', 'Spirit of the Harp', 'Monster', 'Normal', 'Fairy', '', 'Light', 4, 800, 2000
		, NULL, NULL, 'Unlimited', 'A spirit that soothes the soul with the music of its heavenly harp.', 'Legend of Blue-Eyes')
	
    , ('LOB-EN081', 'Frenzie Panda', 'Monster', 'Normal', 'Beast', '', 'Earth', 4, 1200, 1100
		, NULL, NULL, 'Unlimited', 'A savage beast that carries a big bamboo stick for beating down its enemies.', 'Legend of Blue-Eyes')
	
    , ('LOB-EN084', 'Enchanting Mermaid', 'Monster', 'Normal', 'Fish', '', 'Water', 3, 1200, 900
		, NULL, NULL, 'Unlimited', 'A beautiful mermaid that lures voyagers to a watery grave.', 'Legend of Blue-Eyes')
	
    , ('LOB-EN092', 'Dragon Treasure', 'Spell', 'Equip', '', '', '', NULL, NULL, NULL
		, NULL, NULL, 'Unlimited', 'A Dragon-Type monster equiped with this card increases its ATK and DEF by 200 points.', 'Legend of Blue-Eyes')
	
    , ('LOB-EN101', 'Swords of Revealing Light', 'Spell', 'Normal', '', '', '', NULL, NULL, NULL
		, NULL, NULL, 'Unlimited', 'After this card"s activation, it remains on the field, but you must detroy it during the End Phase of your opponent"s 3rd turn.
        When this card is activated: If your opponent controls a face-down monster, flip all monsters they control face-up. While this card is face-up on the field
        , your opponent"s monsters cannot declare an attack', 'Legend of Blue-Eyes')
	
    , ('LOB-EN108', 'Man-Eater Bug', 'Monster', 'Effect', 'Insect', 'Flip', 'Earth', 2, 450, 600
		, NULL, NULL, 'Unlimited', 'FLIP: Target 1 monster on the field; destroy it.', 'Legend of Blue-Eyes')
	, ('LOB-EN109', 'Hane-Hane', 'Monster', 'Effect', 'Beast', 'Flip', 'Earth', 2, 450, 500
		, NULL, NULL, 'Unlimited', 'FLIP: Select 1 monster on the field and return it to its owner"s hand.', 'Legend of Blue-Eyes')
	
    , ('LOB-EN118', 'Monster Reborn', 'Spell', 'Normal', '', '', '', NULL, NULL, NULL
		, NULL, NULL, 'Limited', 'Target 1 monster in either player"s GY; Special Summon it.', 'Legend of Blue-Eyes')
	, ('LOB-EN119', 'Pot of Greed', 'Spell', 'Normal', '', '', '', NULL, NULL, NULL
		, NULL, NULL, 'Banned', 'Draw 2 cards.', 'Legend of Blue-Eyes')
	, ('LOB-EN120', 'Right Leg of the Forbidden One', 'Monster', 'Normal', 'Spellcaster', '', 'Dark', 1, 200, 300
		, NULL, NULL, 'Limited', 'A forbidden right leg sealed by magic. Whosoever breaks this seal will know infinite power.', 'Legend of Blue-Eyes')
	, ('LOB-EN121', 'Left Leg of the Forbidden One', 'Monster', 'Normal', 'Spellcaster', '', 'Dark', 1, 200, 300
		, NULL, NULL, 'Limited', 'A forbidden left leg sealed by magic. Whosoever breaks this seal will know infinite power.', 'Legend of Blue-Eyes')
	, ('LOB-EN122', 'Right Arm of the Forbidden One', 'Monster', 'Normal', 'Spellcaster', '', 'Dark', 1, 200, 300
		, NULL, NULL, 'Limited', 'A forbidden right arm sealed by magic. Whosoever breaks this seal will know infinite power.', 'Legend of Blue-Eyes')
	, ('LOB-EN123', 'Left Arm of the Forbidden One', 'Monster', 'Normal', 'Spellcaster', '', 'Dark', 1, 200, 300
		, NULL, NULL, 'Limited', 'A forbidden left arm sealed by magic. Whosoever breaks this seal will know infinite power.', 'Legend of Blue-Eyes')
	, ('LOB-EN124', 'Exodia the Forbidden One', 'Monster', 'Effect', 'Spellcaster', '', 'Dark', 3, 1000, 1000
		, NULL, NULL, 'Limited', 'If you have "Right Leg of the Forbidden One", "Left Leg of the Forbidden One"
        , "Right Arm of the Forbidden One", and "Left Arm of the Forbidden One" in addition to this card in your hand, you win the duel.', 'Legend of Blue-Eyes')
	, ('LOB-EN125', 'Gaia the Dragon Champion', 'Monster', 'Fusion', 'Dragon', '', 'Wind', 7, 2600, 2100
		, NULL, NULL, 'Unlimited', '"Gaia The Fierce Knight"+"Curse of Dragon"', 'Legend of Blue-Eyes')
;


/* ************************************************************
	 Insert Player Data
*********************************************************** */
INSERT
INTO Players(
	PlayerName
    , PlayerId
) VALUES
	('Jory', 0100506737)
    , ('Moke', 0100499489)
    , ('Chloe', 0100588987)
;

/* ************************************************************
	Insert Data into Decks
*********************************************************** */
INSERT 
INTO Decks(
	DeckName
    , PlayerName
    , PlayerId
) 
VALUES
	('Stall', 'Jory', 0100506737)
    , ('Beatdown', 'Moke', 0100499489)
    , ('Girly', 'Chloe', 0100588987)
;

/* ************************************************************
	Insert Data into SetList
*********************************************************** */
INSERT 
INTO SetList(
	SetName
    , ReleaseDate
    , SetAbbreviation
    , ExtaInformation
) 
VALUES
	('Legend of Blue-Eyes', '2002-03-08', 'LOB', NULL)
    , ('Metal Raiders', '2002-06-26', 'MRD', NULL)
    , ('Spell Rulers', '2002-09-16', 'MRL', 'Was previously called Magic Rulers, but was changed after the MTG court case.')
    , ('Pharoahs Servant', '2002-10-20', 'PSV', NULL)
;

/* ************************************************************
	Insert Data into the Stall deck
*********************************************************** */
INSERT
INTO Stall(
	CardName
    , AmountOfThatCard
) VALUES 
		-- Monster Cards
	('Mystical Elf', '3')
    , ('Giant Soldier of Stone', '3')
    , ('Man-Eater Bug', '3')
    , ('Hane-Hane', '3')
	, ('Aqua Madoor', '3')
    , ('Curse of Dragon', '2')
    , ('Spirit of the Harp', '2')
	, ('Reaper of the Cards', '2')
		-- Spell Cards
    , ('Dark Hole', '3')
    , ('Raigeki', '1')
    , ('Swords of Revealing Light', '3')
    , ('Monster Reborn', '3')
    , ('Fissure', '3')
		-- Trap Cards
	, ('Trap Hole', '3')
    , ('Dragon Capture Jar', '3')
		-- Extra Deck Cards
;

/* ************************************************************
	Insert Data into the Beatdown deck
*********************************************************** */
INSERT
INTO Beatdown(
	CardName
    , AmountOfThatCard
) VALUES 
		-- Monster Cards
	('Mystical Elf', '3')
    , ('Giant Soldier of Stone', '3')
    , ('Man-Eater Bug', '3')
    , ('Hane-Hane', '3')
	, ('Aqua Madoor', '3')
    , ('Blue-Eyes White Dragon', '3')
    , ('Dark Magician', '2')
		-- Spell Cards
    , ('Dark Hole', '3')
    , ('Raigeki', '1')
    , ('Swords of Revealing Light', '1')
    , ('Monster Reborn', '3')
    , ('Fissure', '3')
    , ('Hinotama', '3')
    , ('Book of Secret Arts', '3')
		-- Trap Cards
	, ('Trap Hole', '3')
		-- Extra Deck Cards
;

/* ************************************************************
	Insert Data into the Girly deck
*********************************************************** */
INSERT
INTO Girly(
	CardName
    , AmountOfThatCard
) VALUES 
		-- Monster Cards
	('Mystical Elf', '3')
    , ('Spirit of the Harp', '3')
    , ('Enchanting Mermaid', '3')
    , ('Frenzied Panda', '3')
	, ('Petit Angel', '3')
    , ('Mystical Sheep #2', '3')
    , ('Numeriko', '2')
    , ('Petit Dragon', '1')
		-- Spell Cards
    , ('Dark Hole', '3')
    , ('Raigeki', '1')
    , ('Swords of Revealing Light', '3')
    , ('Monster Reborn', '3')
    , ('Fissure', '3')
    , ('Red Medicine', '3')
		-- Trap Cards
	, ('Trap Hole', '3')
		-- Extra Deck Cards
	, ('Fusionist', '3')
;

/* ************************************************************
						END OF FILE
*********************************************************** */