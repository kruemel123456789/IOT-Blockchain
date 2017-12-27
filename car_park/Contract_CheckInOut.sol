pragma solidity ^0.4.18;
import "browser/Contract_ParkingLot.sol"; //import {parkingLot} from "github.com/kruemel123456789/IOT-Blockchain/car_park/Contract_ParkingLot.sol";
import "browser/Contract_Mortal.sol"; //import {mortal} from "github.com/kruemel123456789/IOT-Blockchain/car_park/Contract_Mortal.sol";
/*
Um die Events nutzen zu können, sollte "Events.js" in einer eigenen Console geladen werden
*/


//Contract für das eigentlich Spiel, erbt von mortal
contract checkInOut is mortal
{
	//#region Variablen und Konstanten Deklaration

	// Zum Debuggen (An -> 1 / Aus -> 0)
	uint256 constant debug = 1;

	//Pfandbetrag(Tageshöchstsatz o.a.) (Wei to Ether)
	uint256 constant maxPayDeposit = 1 * 1000000000000000000;

	//Zeitpunkt, zu dem genung Mitspieler vorhanden sind
	uint256 startTime;

	//array3[] --> parkhaus
	//array2[] --> autonummer(counter)
	//array1[5] --> ID:checkInTime:parkInTime:parkOutTime:checkOutTime
	uint256[5][10][1]  car;

	//Anzahl der Parkhäuser
	uint256 parks = 1;

	//Parkhaus
	uint256 parkhaus = 0;

	//Parklimit der Parkhäuser[Anzahl der Parkhäuser]
	uint256[1] parkLim  = [10];

	//Zählerstand der Autos[Anzahl der Parkhäuser]
	uint256[1] carCount;
	
	//Tarif[Anzahl der Parkhäuser] Preis pro Sekunde
	uint256[1] tariff = [0.00004629629 * 1000000000000000000];
	//1 Ether = max nach 6h
	//1/6 Ether pro Stunde
	//1/360 Ether pro minute
	//1/(60*360) Ether pro Sekunde = 0.00004629629
	
	//Kostenlose Parkdauer
    uint256 free_time = 2 minutes;


	//#endregion

	//#region Events

	/*
	Event bei erfolgreicher Teilnahme am Spiel
	@param player - Es wird die Adresse von Spieler ausgegeben
	*/
	event join_success_In(address player);
	
	event join_success_Out(address player);


	//#endregion

	//#region lokale Funktionen


	//#endregion

	//#region globale Funktionen

    /*Beitritt zum Spiel


	Beispielhafter Aufruf:
	spiel.join_game.sendTransaction("0x123hashwer456",{from:'0x123adresse456', value: web3.toWei(1.0,"ether"), gas:1000000})

    @param hash  - Hashwert aus der Funktion greateHash()
    @returns s - Es wird der Text zu debug-Zwecken zurückgegeben
	*/
	function checkIn(uint256 parkhaus) payable public returns (string s)
	{
		//Maximalbetrag speichern
		uint256 value = msg.value;

		//prüfen, ob das Parkhaus existiert

		//prüfen, ob das Auto schon im Parkhaus ist
		for (uint256 i=0; i < parkLim[parkhaus];i++)
		{
		    uint id_car = uint(msg.sender);
			if (car[parkhaus][i][0] == id_car)
			{
				if(debug == 0){ revert(); }
				if(debug == 1){ return ("Auto schon vorhanden!" );}
			}
		}

		//prüfen, ob noch Plätze im Parkaus frei sind und ob genug Gebühr bezahlt wurde
		if ( parkLim[parkhaus] < parkingLot.freeSpots(parkhaus) && value < maxPayDeposit)	//Zu viele Autos und zu wenig Gebühr
		{
			if(debug == 1){  return ("Zu viele Autos und zu wenig Gebühr");}
			if(debug == 0){ revert(); }
		}
		else if(value < maxPayDeposit )						//Zu wenig Gebühr gezahlt
		{
			if(debug == 1){ return("Zu wenig Gebühr gezahlt");}
			if(debug == 0){ revert(); }

		}
		else if(parkLim[parkhaus] < parkingLot.freeSpots(parkhaus))				//Zu viele Autos
		{
			if(debug == 1){ return("Zu viele Autos in diesem Parkhaus");}
			if(debug == 0){ revert();}
		}

		//Adresse des Spielers speichern
		car[parkhaus][carCount[parkhaus]][0] = uint256(msg.sender);

		//checkInTime des Autos speichern
		car[parkhaus][carCount[parkhaus]][1] = now;

		//Autozahl erhöhen
		carCount[parkhaus] +=1;

		//Event auslösen, da die Einfahrt erfolgreich war
		join_success_In(msg.sender);

	}
	
	function checkOut(uint256 parkhaus)  payable public returns (string s)
	{
	    uint id_car = uint(msg.sender);
			
	    for (uint256 i=0; i < parkLim[parkhaus];i++)
		{
		    
			if (car[parkhaus][i][0] == id_car)
			{
			    //checkOutTime des Autos speichern
	        	car[parkhaus][i][4] = now;
	        	uint256 clean_num = i;
	        	
	        	//Autozahl reduzieren
		        carCount[parkhaus] -=1;
		
                //Event auslösen, da die Ausfahrt erfolgreich war
		        join_success_Out(msg.sender);
		        
		        payNow(clean_num,parkhaus);
		        
		        for (uint256 k=clean_num;k < parkLim[parkhaus]-1;k++)
		        {
		            for (uint256 j=0;j<5;j++)
		            {
		                car[parkhaus][k][j] = car[parkhaus][k+1][j];
		            }
		        }
		        for (j=0;j<5;j++)
	            {
	                car[parkhaus][99][j] = 0;
                }
			}
		}
	}
	
	    function payNow(uint256 carnum, uint256 parkhaus) private
        {
            if (car[parkhaus][carnum][2] == 0 && car[parkhaus][carnum][3] == 0)
            {
                uint256 time = car[parkhaus][carnum][4] - car[parkhaus][carnum][1];
                address player_adress = address(car[parkhaus][carnum][0]);
                
                if (time < free_time)
                {
                    player_adress.transfer(maxPayDeposit);
                    //EVENT Kostenloser Aufenthalt / Kurzparken
                }
                else
                {
                    uint256 to_pay = time * tariff[parkhaus];
                    if (to_pay < maxPayDeposit)
                    {
                        player_adress.transfer(maxPayDeposit-to_pay);
                        //EVENT Betrag
                    }
                    else
                    {
                        //EVENT Tageshöchstsatz
                    }
                }
            }
            else
            {
                //ToDO parkIn, parkOut
            }
        }

	//#endregion
}
