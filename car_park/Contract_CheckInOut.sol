pragma solidity ^0.4.18;
import "browser/ParkingLot.sol"; //import {parkingLot} from "github.com/kruemel123456789/IOT-Blockchain/car_park/Contract_ParkingLot.sol";
import "browser/Mortal.sol"; //import {mortal} from "github.com/kruemel123456789/IOT-Blockchain/car_park/Contract_Mortal.sol";
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

	//array3[] --> parkhaus[Anzahl der Parkhäuser]
	//array2[] --> autonummer(counter)
	//array1[5] --> ID:checkInTime:parkInTime:parkOutTime:checkOutTime:parkplatz
	uint256[6][10][2]  car;

	//Anzahl der Parkhäuser
	uint256 parks = 2;

	//Parkhaus
	uint256 parkhaus = 0;

	//Parklimit der Parkhäuser[Anzahl der Parkhäuser]
	uint256[2] parkLim  = [10,10];

	//Zählerstand der Autos[Anzahl der Parkhäuser]
	uint256[2] carCount;
	
    //Tarif[Anzahl der Parkhäuser] Preis pro Sekunde
	uint256[2] tariff = [0.00004629629 * 1000000000000000000,0.00004629629 * 1000000000000000000];
	//1 Ether = max nach 6h
	//1/6 Ether pro Stunde
	//1/360 Ether pro minute
	//1/(60*360) Ether pro Sekunde = 0.00004629629
	
	//#endregion

	//#region Events

	/*
	Event bei erfolgreicher Teilnahme am Spiel
	@param player - Es wird die Adresse von Spieler ausgegeben
	*/
	event join_success_In(address car, uint256 parkhaus);
	
	event join_success_Out(address car, uint256 parkhaus);
	
	event free_spots(uint256 parkhaus, uint256 frei);
	
	event show_car(address car,uint256 parkhaus, uint256 parkingTime, uint256 value_now, uint256 parkplatz);
	
	event park_success_In(address car, uint256 parkhaus, uint256 parkplatz);
	
	event park_success_Out(address car, uint256 parkhaus, uint256 parkplatz);

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
		if ( parkLim[parkhaus] < freeSpots(parkhaus) && value < maxPayDeposit)	//Zu viele Autos und zu wenig Gebühr
		{
			if(debug == 1){  return ("Zu viele Autos und zu wenig Gebühr");}
			if(debug == 0){ revert(); }
		}
		else if(value < maxPayDeposit )						//Zu wenig Gebühr gezahlt
		{
			if(debug == 1){ return("Zu wenig Gebühr gezahlt");}
			if(debug == 0){ revert(); }

		}
		else if(parkLim[parkhaus] < freeSpots(parkhaus))				//Zu viele Autos
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
		join_success_In(msg.sender, parkhaus);

	}
	
	function checkOut(uint256 parkhaus)  payable public
	{
	    uint id_car = uint(msg.sender);
			
	    for (uint256 i=0; i < parkLim[parkhaus];i++)
		{
		    
			if (car[parkhaus][i][0] == id_car)
			{
			    //checkOutTime des Autos speichern
	        	car[parkhaus][i][4] = now;
	        	uint256 clean_num = i;
	        	
		        parkingLot.payNow(clean_num,parkhaus,car,maxPayDeposit,tariff);
		        
		        for (uint256 k=clean_num;k < parkLim[parkhaus]-1;k++)
		        {
		            for (uint256 j=0;j<6;j++)
		            {
		                car[parkhaus][k][j] = car[parkhaus][k+1][j];
		            }
		        }
		        for (j=0;j<6;j++)
	            {
	                car[parkhaus][parkLim[parkhaus]-1][j] = 0;
                }
                
                //Autozahl reduzieren
		        carCount[parkhaus] -=1;
		
                //Event auslösen, da die Ausfahrt erfolgreich war
		        join_success_Out(msg.sender, parkhaus);
		        
		        break;
			}
		}
	}


    function freeSpots(uint256 parkhaus)private returns (uint256 frei)
    {
        frei = parkLim[parkhaus]-carCount[parkhaus];
        return frei;
    }
    
    function checkCarPark(uint256 parkhaus)public
    {
        uint256 frei = parkLim[parkhaus]-carCount[parkhaus];
        free_spots(parkhaus, frei);
    }
    
    function showCar(address car_searched)
    {
        uint256 parking_time;
        address player_adress;
        uint256 value_now;
        uint256 parkplatz;
        
        for (uint256 p = 0 ; p < parks ; p++)
        {
            for (uint256 k=0;k<parkLim[p];k++)
            {
                if (car[p][k][0] == uint256(car_searched))
                {
                    if (car[p][k][2] == 0)
                    {
                        parking_time = now - car[p][k][1];
                        player_adress = address(car[p][k][0]);
                        value_now = parking_time * tariff[p];
                        parkplatz = car[p][k][5];
                        
                        show_car(car_searched, p, parking_time, value_now, parkplatz);
                        break;
                    }
                    else
                    {
                        parking_time = now - car[p][k][2];
                        player_adress = address(car[p][k][0]);
                        value_now = parking_time * tariff[p];
                        parkplatz = car[p][k][5];
                        
                        show_car(car_searched, p, parking_time, value_now, parkplatz);
                        break;
                    }
                }
            }
        }
    }
    
    function parkIn(uint256 parkhaus, uint256 parkplatz) public returns (string s)
    {
        for (uint256 i=0; i < parkLim[parkhaus];i++)
		{
		    uint id_car = uint(msg.sender);
			if (car[parkhaus][i][0] == id_car && car[parkhaus][i][2]==0)
			{
        		//checkInTime des Autos speichern
        		car[parkhaus][i][2] = now;
        
        		//Parkplatz speichern
        		car[parkhaus][i][5] = parkplatz;
        		
        		//Event auslösen, da das Parken erfolgreich war
        		park_success_In(msg.sender, parkhaus, parkplatz);
        		return ("");
			}
		}
		if(debug == 1){ return("Auto nicht vorhanden");}
		if(debug == 0){ revert(); }
    }
    
    function parkOut(uint256 parkhaus) public
    {
        uint id_car = uint(msg.sender);
			
	    for (uint256 i=0; i < parkLim[parkhaus];i++)
		{
		    
			if (car[parkhaus][i][0] == id_car && car[parkhaus][i][3] == 0)
			{
			    //parkOutTime des Autos speichern
	        	car[parkhaus][i][3] = now;
		
                //Event auslösen, da die Ausfahrt erfolgreich war
		        park_success_Out(msg.sender, parkhaus,car[parkhaus][i][5]);
		        
		        break;
			}
		}
    }
	//#endregion
}
