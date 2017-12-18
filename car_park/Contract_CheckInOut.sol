pragma solidity ^0.4.18;
import {parkingLot} from "github.com/kruemel123456789/IOT-Blockchain/car_park/Contract_ParkingLot.sol";

/*
Um die Events nutzen zu können, sollte "Events.js" in einer eigenen Console geladen werden
*/


//Contract für das eigentlich Spiel, erbt von mortal
contract checkInOut
{
	//#region Variablen und Konstanten Deklaration
	
	// Zum Debuggen (An -> 1 / Aus -> 0)
	uint256 constant debug = 1;

	//Pfandbetrag(Tageshöchstsatz o.a.) (Wei to Ether)
	uint256 constant maxPayDeposit = 1 * 1000000000000000000;

	//Zeitpunkt, zu dem genung Mitspieler vorhanden sind
	uint256 startTime;
	
	//array1[] --> parkhaus
	//array2[] --> autonummer(counter)
	//array3[5] --> ID:checkInTime:parkInTime:parkOutTime:checkOutTime
	uint256[][][5]  car;
	
	//Anzahl der Parkhäuser
	uint256 parks = 1;
	
	//Parkhaus
	uint256 parkhaus = 1;
	
	//Parklimit der Parkhäuser[Anzahl der Parkhäuser]
	uint256[1] parkLim = 100;
	
	//Zählerstand der Autos[Anzahl der Parkhäuser]
	uint256[1] carCount;
	

	//#endregion

	//#region Events

	/*
	Event bei erfolgreicher Teilnahme am Spiel
	@param player - Es wird die Adresse von Spieler ausgegeben
	*/
	event join_success(address player);


	//#endregion

	//#region lokale Funktionen



	//#endregion

	//#region globale Funktionen

    /*Beitritt zum Spiel

    Der Spieler tritt durch Aufruf der Funktion dem Spiel bei.
	Es muss der zuvor berechnete Hash übergeben werden.

	Die Funktion überprüft, ob der Spieler bereits beigetreten ist.
	Die Funktion überprüft, ob der Spieler genug Einsatz bezahlt hat.
	Die Funktion überprüft, ob nach Plätze frei sind.
	War dies erfolgreich werden Adresse und Hash des Spielers gespeichert.
	Außerdem wird der Einsatz zum Jackpot addiert und ein Event ausgelöst,
	da der Beitritt erfolgreich war.
	Ist die gewünschte Spielerzahl erreicht, so wird durch ein Event zum Entschlüsseln
	aufgefordert und die Zeit gespeichert
	Im letzen Schritt der Funktion wird die Spielerzahl erhöht

	Beispielhafter Aufruf:
	spiel.join_game.sendTransaction("0x123hashwer456",{from:'0x123adresse456', value: web3.toWei(1.0,"ether"), gas:1000000})

    @param hash  - Hashwert aus der Funktion greateHash()
    @returns s - Es wird der Text zu debug-Zwecken zurückgegeben
	*/
	function checkIn(uint256 parkhaus) payable public
	{
		//Maximalbetrag speichern
		uint256 value = msg.value;

		//prüfen, ob das Auto schon im Parkhaus ist
		for (uint256 i=0; i <= parkLim[parkhaus];i++)
		{
			if (car[i][1] == msg.sender)
			{
				if(debug == 0){ revert(); }
				if(debug == 1){ return ("Auto schon vorhanden!" );}
			}
		}

		//prüfen, ob noch Plätze im Parkaus frei sind und ob genug Gebühr bezahlt wurde
		if ( parkLim < parkingLot.freeSpots(parkhaus) && value < maxPayDeposit)	//Zu viele Autos und zu wenig Gebühr
		{
			if(debug == 1){  return ("Zu viele Autos und zu wenig Gebühr");}
			if(debug == 0){ revert(); }
		}
		else if(value < maxPayDeposit )						//Zu wenig Gebühr gezahlt
		{
			if(debug == 1){ return("Zu wenig Gebühr gezahlt");}
			if(debug == 0){ revert(); }

		}
		else if(parkLim < parkingLot.freeSpots(parkhaus))				//Zu viele Autos
		{
			if(debug == 1){ return("Zu viele Autos in diesem Parkhaus");}
			if(debug == 0){ revert();}
		}

		//Adresse des Spielers speichern
		car[parkhaus][carCount[parkhaus]][1] = msg.sender;

		//checkInTime des Autos speichern
		car[parkhaus][carCount[parkhaus]][1] = now;
		
		//Autozahl erhöhen
		carCount[parkhaus} +=1;

		//Event auslösen, da die Einfahrt erfolgreich war
		join_success(msg.sender);

	}

	//#endregion
}
