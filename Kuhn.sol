
pragma solidity 0.4.21;
pragma experimental ABIEncoderV2;

contract Kuhn {


    address myAddress = this;
    address owner = msg.sender; //set owner as msg.sender
    int32 intID = 1;

    /*
    function chechThisAddress() public constant returns(address) {
        return myAddress;
    }


    function addETH() public payable {

    }

    function seeETHbalance() public constant returns (uint256) {
        return myAddress.balance;
    }

    function getETH() public {
        if(msg.sender == owner) {
            owner.transfer(myAddress.balance);
        }

    }

    */

    function kill() public { //self-destruct function,
        if(msg.sender == owner) {
            selfdestruct(owner);
        }
    }

    struct Game {
        int32 gameID;
        address player1;
        address player2;
        address turn;
        address winner;
        uint256 bet;
        int8[] cards;
        int8 cardP1;
        int8 cardP2;
        bool gameStart;
        bool didP1Check;
        bool didP1Raise;
        bool didP1Fold;
        bool didP2Check;
        bool didP2Raise;
        bool didP2Fold;

        bool canP2Join;

    }


    mapping(int32 => Game) games;
    int32[] IDlist;





    function createGame() public payable returns(int32){

        // game = games[msg.sender];
        //bytes32 gameID = keccak256(msg.sender);
        int32 gameID = intID;

        // Game memory myGame;
        games[gameID].gameID = gameID;
        games[gameID].player1 = msg.sender;
        games[gameID].bet = msg.value;

        games[gameID].cards.push(1);
        games[gameID].cards.push(2);
        games[gameID].cards.push(3);

        games[gameID].gameStart = false;
        games[gameID].didP1Check = false;
        games[gameID].didP1Raise = false;
        games[gameID].didP1Fold = false;
        games[gameID].didP2Check = false;
        games[gameID].didP2Raise = false;
        games[gameID].didP2Fold = false;

        games[gameID].canP2Join = true;

        //setCardsAndTurn(gameID);

        IDlist.push(gameID);
        intID++;



        return (gameID);
    }

    function joinGame(int32 gameID) payable public {
        if(games[gameID].canP2Join == false || msg.sender == games[gameID].player1 || msg.value < games[gameID].bet){
            revert();
        }
        games[gameID].player2 = msg.sender;
        games[gameID].bet = games[gameID].bet + msg.value;
        games[gameID].canP2Join = false;
        games[gameID].gameStart = true;

        setCardsAndTurn(gameID);

        // eliminar el gameID de IDlist

    }



    function getGamesID() public constant returns (int32[]) {
        return IDlist;
    }

    function getGameInfo(int32 gameID) public constant returns(address, address, uint256,  int8, int8) {
        if(msg.sender == games[gameID].player1 || msg.sender == games[gameID].player2 || msg.sender == owner) {
            return (games[gameID].player1,
            games[gameID].player2,
            games[gameID].bet,
            games[gameID].cardP1,
            games[gameID].cardP2);
        }
    }

    function getGameBools(int32 gameID) public constant returns(bool, bool, bool, bool, bool, bool) {
        if(msg.sender == games[gameID].player1 || msg.sender == games[gameID].player2 || msg.sender == owner) {
            return (
            games[gameID].didP1Check,
            games[gameID].didP1Raise,
            games[gameID].didP1Fold,
            games[gameID].didP2Check,
            games[gameID].didP2Raise,
            games[gameID].didP2Fold);
        }
    }


    function setCardsAndTurn(int32 gameID) private {

        uint256 random2 = uint(keccak256(block.timestamp)) % 2;
        uint256 random3 = uint(keccak256(block.timestamp)) % 3;



        if (random2 == 0) {
            games[gameID].turn = games[gameID].player1;
        }

        else {
            games[gameID].turn = games[gameID].player2;
        }


        games[gameID].cardP1 = games[gameID].cards[random3];

        remove(gameID, random3);
        random2 = uint(keccak256(block.timestamp)) % 2;

        games[gameID].cardP2 = games[gameID].cards[random2];

    }

    // Elimina un index de la llista de cartes
    function remove(int32 gameID, uint index) private {
        for (uint i = index; i<games[gameID].cards.length-1; i++){
            games[gameID].cards[i] = games[gameID].cards[i+1];
        }
        delete games[gameID].cards[games[gameID].cards.length-1];
        games[gameID].cards.length--;
    }


    // Diu la carta que te al jugador que crida a la funcio
    function checkMyCard(int32 gameID) public constant returns(int8) {
        if(msg.sender == games[gameID].player1) {
            return games[gameID].cardP1;
        }
        else if(msg.sender == games[gameID].player2) {
            return games[gameID].cardP2;
        }
        else{
            return (99);
        }
    }



    function checkStatus(int32 gameID) private {
        if (games[gameID].didP1Fold == true){
            games[gameID].winner = games[gameID].player2;
            payWinner(gameID);
        }
        if (games[gameID].didP2Fold == true){
            games[gameID].winner = games[gameID].player1;
            payWinner(gameID);
        }

        if (games[gameID].didP1Check && games[gameID].didP2Check) {
            checkWhoWon(gameID);
        }

        if (games[gameID].didP1Raise && games[gameID].didP2Raise) {
            checkWhoWon(gameID);
        }



    }


    // El jugador que la crida fa fold
    function fold(int32 gameID) public {
        if(msg.sender != games[gameID].turn || games[gameID].gameStart == false) {
            revert();
        }

        if(msg.sender == games[gameID].player1){
            games[gameID].didP1Fold = true;
        }
        if(msg.sender == games[gameID].player1){
            games[gameID].didP2Fold = true;
        }

        checkStatus(gameID);

    }


    /*
    Funcio play: aqui es jugara al joc.
        Si es crida a play sense 'value' --> check
        Si es crida a play amb 'value' --> raise/bet
        **Si no es crida a play --> fold (timeout es de xx segons)

    */



    function play(int32 gameID) public payable {
        if(msg.sender != games[gameID].turn || games[gameID].gameStart == false) {
            revert();
        }


        if(msg.sender == games[gameID].player1){
            if(msg.value == 0){
                // No paga res, fa check
                games[gameID].didP1Check = true;
            }

            if(msg.value > 0){
                // Ha pagat, axi que fara un raise
                games[gameID].didP1Raise = true;
                games[gameID].bet = games[gameID].bet + msg.value;
            }

            games[gameID].turn = games[gameID].player2;
        }


        if (msg.sender == games[gameID].player2) {
            if(msg.value == 0){
                // No paga res, fa check
                games[gameID].didP2Check = true;
            }

            if(msg.value > 0){
                // Ha pagat, axi que fara un raise
                games[gameID].didP2Raise = true;
                games[gameID].bet = games[gameID].bet + msg.value;
            }

            games[gameID].turn = games[gameID].player1;
        }
        checkStatus(gameID);
    }


    // Comprova qui ha guanyat
    function checkWhoWon(int32 gameID) private {
        if(games[gameID].cardP1 > games[gameID].cardP2) {
            games[gameID].winner = games[gameID].player1;
        }
        else {
            games[gameID].winner = games[gameID].player2;
        }
        payWinner(gameID);
    }

    // Paga al jugador guanyador
    function payWinner(int32 gameID) private {
        (games[gameID].winner).transfer(games[gameID].bet);
    }


}
