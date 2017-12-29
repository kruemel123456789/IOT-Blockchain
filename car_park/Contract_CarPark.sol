/*
Um die Events nutzen zu können, sollte "Events.js" in einer eigenen Console geladen werden
*/

pragma solidity ^0.4.18;

import {mortal} from "github.com/kruemel123456789/IOT-Blockchain/car_park/Contract_Mortal.sol";


//Contract für das Parkhaus, erbt von mortal
contract CarPark is mortal
{
	//#region Variablen und Konstanten Deklaration

	// Zum Debuggen (An -> 1 / Aus -> 0)
	uint256 constant debug = 0;

	//Pfandbetrag(Tageshöchstsatz o.a.) (Ether to Wei)
	uint256 constant maxPayDeposit = 1 * 1000000000000000000;

	//array3[] --> parkhaus[Anzahl der Parkhäuser]
	//array2[] --> autonummer(counter)
	//array1[5] --> ID:checkInTime:parkInTime:parkOutTime:checkOutTime:parkplatz
	uint256[6][10][2]  car;

	//Anzahl der Parkhäuser
	uint256 parks = 2;

	//Parklimit der einzelnen Parkhäuser [Anzahl der Parkhäuser]
	uint256[2] parkLim  = [10,10];

	//Zählerstand der Autos in den einzelnen Parkhäusern [Anzahl der Parkhäuser]
	uint256[2] carCount;
	
    //Tarif der einzelnen Parkhäuser [Anzahl der Parkhäuser] Preis pro Sekunde
	uint256[2] tariff = [4629629 * 10000000,4629629 * 10000000];
	//1 Ether = max nach 6h
	//1/6 Ether pro Stunde
	//1/360 Ether pro minute
	//1/(60*360) Ether pro Sekunde = 0.00004629629
	//Ether to Wei: 0.00004629629 * 1000000000000000000 = 4629629 * 10000000
	
	//Erwarte Maximalzeit zur Parkplatzsuche bzw. zur Ausfahrt
    uint256 constant out_time = 2 minutes;
    
	//Kostenlose Parkdauer
    uint256 constant free_time = 2 minutes;
	
	//#endregion

	
	//#region Events

	//'Erfolgreiche Einfahrt in Parkhaus: ' + result.args.parkhaus  + ' (Adresse des Autos: ' + result.args.car + ')'
	event join_success_In(address car, uint256 parkhaus);
	
	//'Erfolgreiche Ausfahrt aus Parkhaus: ' + result.args.parkhaus  + ' (Adresse des Autos: ' + result.args.car + ')'
	event join_success_Out(address car, uint256 parkhaus);
	
	//'Im Parkhaus ' + result.args.parkhaus+ ' sind ' + result.args.frei + ' Parkplätze frei.'
	event free_spots(uint256 parkhaus, uint256 frei);
	
	//'Das Auto '+ result.args.car + ' steht im Parkhaus ' + result.args.parkhaus + ' auf Parkplatz ' + result.args.parkplatz + ' seit: ' + h + ' h :' + m + ' m :' + s + ' s. Die aktuelle Gebuehr betraegt: ' +  result.args.value_now / 1000000000000000000
	event show_car(address car,uint256 parkhaus, uint256 parkingTime, uint256 value_now, uint256 parkplatz);
	
	//'Erfolgreicher Halt auf Parkplatz ' + result.args.parkplatz + ' im Parkhaus: ' + result.args.parkhaus  + ' (Adresse des Autos: ' + result.args.car + ')'
	event park_success_In(address car, uint256 parkhaus, uint256 parkplatz);
	
	//'Erfolgreiches Wegfahren von Parkplatz ' + result.args.parkplatz + ' in Parkhaus: ' + result.args.parkhaus  + ' (Adresse des Autos: ' + result.args.car + ')'
	event park_success_Out(address car, uint256 parkhaus, uint256 parkplatz);
	
	//'Mindestparkdauer unterschritten --> Der Aufenthalt war kostenlos' + ' (Adresse des Autos: ' + result.args.car + ')'
	event free_parking(address car);
	
	//'Aufenthaltsdauer: ' + h + ' h :' + m + ' m :' + s + ' s. Parkgebühr: ' + result.args.value / 1000000000000000000 + ' (Adresse des Autos: ' + result.args.car + ')'
	event pay_fee(address car, uint256 value, uint256 parkingTime);
	
	//'Aufenthaltsdauer: ' + h + ' h :' + m + ' m :' + s + ' s. Parkgebühr = Tageshöchstsatz: ' + result.args.value / 1000000000000000000 + ' (Adresse des Autos: ' + result.args.car + ')'
	event pay_max(address car, uint256 value, uint256 parkingTime);
	
	//'Das Auto wurde nicht gefunden: ' + result.args.car
	event car_not_found(address car);
	
	//#endregion

	
	//#region lokale Funktionen
	
	//Rückgabe der freien Parkplätze im Parkhaus
	function freeSpots(uint256 parkhaus) internal returns (uint256)
	{
		uint256 frei = parkLim[parkhaus] - carCount[parkhaus];
		return frei;
	}
	
	//Funktion, um bei Ausfahrt aus dem Parkhaus die Rückzahlung entsprechend der Parkdauer zu berechnen
	function payNow(uint256 carnum, uint256 parkhaus) internal
	{
		uint256 time;
		address car_adress;
		uint256 to_pay;

		//Auswahl der Zeiten für unterschiedliche Situationen (falls kein Parkplatz erreicht oder verlassen wird oder der zeitliche Abstand zu groß ist)
		//Weder parkIn noch parkOut eingetragen
		if (car[parkhaus][carnum][2] == 0 && car[parkhaus][carnum][3] == 0)
		{
			time = car[parkhaus][carnum][4] - car[parkhaus][carnum][1];
		}
		
		//Wenn parkOut nicht eingetragen aber parkIn eingetragen
		else if (car[parkhaus][carnum][3] == 0)
		{
			if (car[parkhaus][carnum][2] - car[parkhaus][carnum][1] > out_time)
			{
				time = car[parkhaus][carnum][4] - car[parkhaus][carnum][1];
			}
			else
			{
				time = car[parkhaus][carnum][4] - car[parkhaus][carnum][2];
			}
		}
		
		//Wenn parkIn nicht eingetragen, aber parkOut
		else if(car[parkhaus][carnum][2] == 0)
		{
			if (car[parkhaus][carnum][4] - car[parkhaus][carnum][3] > out_time)
			{
				time = car[parkhaus][carnum][4] - car[parkhaus][carnum][1];
			}
			else
			{
				time = car[parkhaus][carnum][3] - car[parkhaus][carnum][1];
			}
		}
		
		//Wenn beides eingetragen
		else
		{
			if (car[parkhaus][carnum][4] - car[parkhaus][carnum][3] > out_time)
			{
				if (car[parkhaus][carnum][2] - car[parkhaus][carnum][1] > out_time)
				{
					time = car[parkhaus][carnum][4] - car[parkhaus][carnum][1];
				}
				else
				{
					time = car[parkhaus][carnum][4] - car[parkhaus][carnum][2];
				}
			}
			else
			{
				if (car[parkhaus][carnum][2] - car[parkhaus][carnum][1] > out_time)
				{
					time = car[parkhaus][carnum][3] - car[parkhaus][carnum][1];
				}
				else
				{
					time = car[parkhaus][carnum][3] - car[parkhaus][carnum][2];
				}
			}
		}

		//Adresse des Autos zwischenspeichern
		car_adress = address(car[parkhaus][carnum][0]);

		//Wenn unter Mindestparkdauer, dann alles zurück zahlen
		if (time < free_time)
		{
			car_adress.transfer(maxPayDeposit);
			free_parking(car_adress);
		}
		
		//Sonst entweder nichts zurück zahlen oder nur einen Teil, entsprechend der Zeit
		else
		{
			to_pay = time * tariff[parkhaus];
			
			if (to_pay < maxPayDeposit)
			{
				car_adress.transfer(maxPayDeposit-to_pay);
				pay_fee(car_adress, to_pay, time);
			}
			else
			{
				pay_max(car_adress, maxPayDeposit, time);
			}
		}
	}

	//#endregion

	//#region globale Funktionen

    //Einfahrt in das Parkhaus an der Schranke
	function checkIn(uint256 parkhaus) payable public returns (string s)
	{
		//Maximalbetrag speichern
		uint256 value = msg.value;

		//prüfen, ob das Parkhaus existiert
		if (parkhaus >= parks)
		{
			if(debug == 0){ revert(); }
			if(debug == 1){ return ("Parkhaus nicht vorhanden!" );}
		}

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
		//Zu viele Autos und zu wenig Gebühr
		if ( parkLim[parkhaus] < freeSpots(parkhaus) && value < maxPayDeposit)
		{
			if(debug == 1){  return ("Zu viele Autos und zu wenig Gebühr");}
			if(debug == 0){ revert(); }
		}
		
		//Zu wenig Gebühr gezahlt
		else if(value < maxPayDeposit )
		{
			if(debug == 1){ return("Zu wenig Gebühr gezahlt");}
			if(debug == 0){ revert(); }
		}
		
		//Zu viele Autos im Parkhaus
		else if(parkLim[parkhaus] < freeSpots(parkhaus))
		{
			if(debug == 1){ return("Zu viele Autos in diesem Parkhaus");}
			if(debug == 0){ revert();}
		}

		//Adresse des Spielers speichern
		car[parkhaus][carCount[parkhaus]][0] = uint256(msg.sender);

		//checkInTime des Autos speichern
		car[parkhaus][carCount[parkhaus]][1] = now;

		//Autozahl erhöhen
		carCount[parkhaus] += 1;

		//Event auslösen, da die Einfahrt erfolgreich war
		join_success_In(msg.sender, parkhaus);
	}
	
	//Ausfahrt aus dem Parkhaus an der Schranke
	function checkOut(uint256 parkhaus) public returns (uint256)
	{
		uint id_car = uint(msg.sender);

		for (uint256 i=0; i < parkLim[parkhaus];i++)
		{
			if (car[parkhaus][i][0] == id_car)
			{
				//Ausfahrtzeit des Autos speichern
				car[parkhaus][i][4] = now;
				
				//Speicherstelle des Autos zum löschen speichern
				uint256 clean_num = i;

				//Bezahl/Rückzahlfunktion aufrufen
				payNow(clean_num,parkhaus);
				
				//Löschen des Autos aus dem Speicher-Array
				for (uint256 k=clean_num;k < parkLim[parkhaus] - 1;k++)
				{
					for (uint256 j=0;j < 6 ;j++)
					{
						car[parkhaus][k][j] = car[parkhaus][k+1][j];
					}
				}
				
				//füllen der letzen Stelle mit "0"
				for (j=0;j < 6;j++)
				{
					car[parkhaus][parkLim[parkhaus]-1][j] = 0;
				}

				//Autozahl reduzieren
				carCount[parkhaus] -= 1;

				//Event auslösen, da die Ausfahrt erfolgreich war
				join_success_Out(msg.sender, parkhaus);

				return 0;
			}
		}
	}
    
	//Abfragen der freien Parkplätze (z.B. durch Anzeigetafel oder Nutzer vor Anfahrt)
    function checkCarPark(uint256 parkhaus)public
    {
		//freie Parkplätze berechnen
        uint256 frei = parkLim[parkhaus] - carCount[parkhaus];
		
		//Event auslösen, um die freien Parkplätze mitzuteilen
        free_spots(parkhaus, frei);
    }
    
	//Position des Autos, Parkdauer und aktuelle Gebühr anzeigen
    function showCar(address car_searched) public returns (uint256)
    {
        uint256 parking_time;
        
		//Alle Parkhäuser durchsuchen
        for (uint256 p = 0 ; p < parks; p++)
        {
			//Alle Parkplätze durchsuchen
            for (uint256 k=0;k < parkLim[p] ;k++)
            {
				//Wenn das Auto gefunden wurde
                if (car[p][k][0] == uint256(car_searched))
                {
					//Dann die richtige Startzeit auswählen
                    if (car[p][k][2] == 0)
                    {
                        parking_time = now - car[p][k][1];
                    }
                    else
                    {
                        parking_time = now - car[p][k][2];
                    }
					
					//aktuelle Gebühr berechnen
					uint256 value_now = parking_time * tariff[p];
					
					//Parkplatz auslesen
					uint256 parkplatz = car[p][k][5];
					
					//Event auslösen um alle Daten anzuzeigen
					show_car(car_searched, p, parking_time, value_now, parkplatz);
					
					//For-Schleife verlassen
					return 0;
                }
            }
        }
		
		//Events auslösen, da das Auto nicht gefunden wurde
        car_not_found(car_searched);
    }
    
	//Einfahrt in einen Parkplatz speichern, nach Einfahrt durch Schranke
	function parkIn(uint256 parkhaus, uint256 parkplatz) public returns (string s)
	{
		for (uint256 i=0; i < parkLim[parkhaus];i++)
		{
			uint id_car = uint(msg.sender);
			
			if (car[parkhaus][i][0] == id_car && car[parkhaus][i][2] == 0)
			{
				//Haltezeit des Autos speichern
				car[parkhaus][i][2] = now;

				//Parkplatz speichern
				car[parkhaus][i][5] = parkplatz;

				//Event auslösen, da das Parken erfolgreich war
				park_success_In(msg.sender, parkhaus, parkplatz);
				return ("");
			}
		}
		
		//Falls diese Stelle erreicht wird, ist das Auto nicht an der Schranke registriert worden
		if(debug == 1){ return("Auto nicht vorhanden");}
		if(debug == 0){ revert(); }
	}
    
	//Ausfahrt aus einem Parkplatz speichern, vor Ausfahrt durch Schranke
	function parkOut(uint256 parkhaus) public returns (uint256)
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

				//Parkplatz löschen
				car[parkhaus][i][5] = 0;

				return 0;
			}
		}
	}
	
	//#endregion
}
