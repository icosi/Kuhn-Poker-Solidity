# Kuhn Poker Solidity


Instrccions:

  · Obrir https://remix.ethereum.org/
  
  · 'Enviroment' --> JavaScript VM
  
  Hi haura 5 carteres amb Ether
  
  · A 'value' cambiar 'wei' per 'ether'. El 'wei' es una fracció de Ether
  
  El quadre 'value' es la quantitat d'Ether que enviarem tant a l'hora de crear l'SmartContract (no fa falta enviar res per crear-lo) com la que enviarem a les funcions que cridem.
  
  · Seleccionar qualsevol cartera i cliquem a 'Create'. Això crearà l'SmartContract i l'owner es la cartera creadora.
  
  Ara ja esta l'SmartContract creat i abaix a la dreta hi hauran les funcions a la que es pot cridar
  
  
  
  Pasos per a jugar una partida:
  
  (A continuació enviarem sempre 5 Ether, per enviar 5 Ether al cridar una funció nomes fa falta posar 5 a la pestanya 'value' i marcar 'ether')
  
    1- Create game. Cridem a la funció amb 5 Ether. Aixo ens retornara el ID de la partida. Si cridem a 'getGamesID' ens mostrara tots els ID's de les partides creades.
    
    2- Join game. Aqui em de posar com a parametre el ID de la partida a la que ens volem unir. Tambe l'hem de cridar amb 5 Ether. 
    Ara es repartiran les cartes i es decidirà qui es el player1 i qui el player2
    
    3- És el torn del player1. Aquest ha de cridar a play, posant el ID de la partida i enviara Ether, si vol fer RAISE; o no, si vol fer CHECK.
    
    4- Torn del player2. El mateix.
    
    ------ (Nomes hi ha els casos CHECK-CHECK, RAISE-RAISE o que algu faci FOLD) -------
    
    5- Es comprova el guanyador i s'envia tot el que s'ha apostat al guanyador.    
    
