pragma solidity ^0.4.18;

library parkingLot
{
    //Zeit zwischen Schranke und Parkplatz
    uint256 constant out_time = 2 minutes;
    
	//Kostenlose Parkdauer
    uint256 constant free_time = 2 minutes;
    
	event free_parking(address car);
	
	event pay_fee(address car, uint256 value, uint256 parkingTime);
	
	event pay_max(address car, uint256 value, uint256 parkingTime);
    
    
    function payNow(uint256 carnum, uint256 parkhaus, uint256[6][10][2]  car, uint256 maxPayDeposit, uint256[2] tariff) public
    {
        uint256 time;
        address player_adress;
        uint256 to_pay;
        
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
        
        player_adress = address(car[parkhaus][carnum][0]);
            
        if (time < free_time)
        {
            player_adress.transfer(maxPayDeposit);
            //EVENT Kostenloser Aufenthalt / Kurzparken
            free_parking(player_adress);
        }
        else
        {
            to_pay = time * tariff[parkhaus];
            if (to_pay < maxPayDeposit)
            {
                player_adress.transfer(maxPayDeposit-to_pay);
                //EVENT Betrag
                pay_fee(player_adress, to_pay, time);
            }
            else
            {
                //EVENT Tageshöchstsatz
                pay_fee(player_adress, maxPayDeposit, time);
            }
        }
    }
}
