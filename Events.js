
var browser_ballot_sol_gameContract = web3.eth.contract([{"constant":false,"inputs":[{"name":"parkhaus","type":"uint256"}],"name":"checkOut","outputs":[{"name":"s","type":"string"}],"payable":true,"stateMutability":"payable","type":"function"},{"constant":false,"inputs":[],"name":"kill","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"parkhaus","type":"uint256"}],"name":"checkIn","outputs":[{"name":"s","type":"string"}],"payable":true,"stateMutability":"payable","type":"function"},{"anonymous":false,"inputs":[{"indexed":false,"name":"player","type":"address"},{"indexed":false,"name":"parkhaus","type":"uint256"}],"name":"join_success_In","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"player","type":"address"},{"indexed":false,"name":"parkhaus","type":"uint256"}],"name":"join_success_Out","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"player","type":"address"}],"name":"free_parking","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"player","type":"address"},{"indexed":false,"name":"value","type":"uint256"},{"indexed":false,"name":"parkingTime","type":"uint256"}],"name":"pay_fee","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"player","type":"address"},{"indexed":false,"name":"value","type":"uint256"},{"indexed":false,"name":"parkingTime","type":"uint256"}],"name":"pay_max","type":"event"}]);


//Addresse von dem Contract eintragen
var car_park = browser_ballot_sol_gameContract.at('0x6d04098761d608aa52260491d79f71cb411b61e5');  

var event_join_success_In = car_park.join_success_In();
event_join_success_In.watch(function(error, result)
{
  if(!error)
  {
      console.log('Erfolgreiche Einfahrt in Parkhaus: ' + result.args.parkhaus  + ' (Adresse des Autos: ' + result.args.car + ')' );
  }
  else
  {
      console.log('Fehler');
  }

});

var event_join_success_Out = car_park.join_success_Out();
event_join_success_Out.watch(function(error, result)
{
  if(!error)
  {
      console.log('Erfolgreiche Ausfahrt aus Parkhaus: ' + result.args.parkhaus  + ' (Adresse des Autos: ' + result.args.car + ')' );
  }
  else
  {
      console.log('Fehler');
  }

});

var event_free_parking = car_park.free_parking();
event_free_parking.watch(function(error, result)
{
  if(!error)
  {
      console.log('Mindestparkdauer unterschritten --> Der Aufenthalt war kostenlos' + ' (Adresse des Autos: ' + result.args.car + ')' );
  }
  else
  {
      console.log('Fehler');
  }

});

var event_pay_fee = car_park.pay_fee();
event_pay_fee.watch(function(error, result)
{
  if(!error)
  {
      var h =  Math.floor(result.args.parkingTime/3600);
      var m =  Math.floor((result.args.parkingTime - (h*3600))/60);
      var s =  Math.floor((result.args.parkingTime - (h*3600) - (m*60)));
      
      console.log('Aufenthaltsdauer (h:m:s): ' + h + ':' + m + ':' + s + 'Parkgebühr: ' + result.args.value / 1000000000000000000 + ' (Adresse des Autos: ' + result.args.car + ')' );
  }
  else
  {
      console.log('Fehler');
  }

});

var event_pay_max = car_park.pay_max();
event_pay_max.watch(function(error, result)
{
  if(!error)
  {
      var h =  Math.floor(result.args.parkingTime/3600);
      var m =  Math.floor((result.args.parkingTime - (h*3600))/60);
      var s =  Math.floor((result.args.parkingTime - (h*3600) - (m*60)));
      
      console.log('Aufenthaltsdauer (h:m:s): ' + h + ':' + m + ':' + s + 'Parkgebühr = Tageshöchstsatz: ' + result.args.value / 1000000000000000000 + ' (Adresse des Autos: ' + result.args.car + ')' );
  }
  else
  {
      console.log('Fehler');
  }

});

var event_free_spots = car_park.free_spots();
event_free_spots.watch(function(error, result)
{
  if(!error)
  {
      
      console.log('Im Parkhaus ' + result.args.parkhaus+ ' sind ' + result.args.frei + ' Parkplätze frei.' );
  }
  else
  {
      console.log('Fehler');
  }

});

var event_show_car = car_park.show_car();
event_show_car.watch(function(error, result)
{
  if(!error)
  {
      var h =  Math.floor(result.args.parkingTime/3600);
      var m =  Math.floor((result.args.parkingTime - (h*3600))/60);
      var s =  Math.floor((result.args.parkingTime - (h*3600) - (m*60)));
      
      console.log('Das Auto '+ result.args.car ' steht im Parkhaus ' + result.args.parkhaus + ' auf Parkplatz ' + result.args.parkplatz + ' seit (h:m:s): ' + h + ':' + m + ':' + s + '. Die aktuelle Gebuehr beträgt: ' +  result.args.value_now / 1000000000000000000);
  }
  else
  {
      console.log('Fehler');
  }

});

var event_park_success_In = car_park.park_success_In();
event_park_success_In.watch(function(error, result)
{
  if(!error)
  {
      console.log('Erfolgreicher Halt auf Parkplatz ' + result.args.parkplatz + 'im Parkhaus: ' + result.args.parkhaus  + ' (Adresse des Autos: ' + result.args.car + ')' );
  }
  else
  {
      console.log('Fehler');
  }

});

var event_park_success_Out = car_park.park_success_Out();
event_park_success_Out.watch(function(error, result)
{
  if(!error)
  {
      console.log('Erfolgreiches Wegfahren von Parkplatz ' + result.args.parkplatz + 'in Parkhaus: ' + result.args.parkhaus  + ' (Adresse des Autos: ' + result.args.car + ')' );
  }
  else
  {
      console.log('Fehler');
  }

});
