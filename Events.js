
var browser_ballot_sol_gameContract  = web3.eth.contract([{"constant":false,"inputs":[{"name":"parkhaus","type":"uint256"}],"name":"checkOut","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[],"name":"kill","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"parkhaus","type":"uint256"},{"name":"parkplatz","type":"uint256"}],"name":"parkIn","outputs":[{"name":"s","type":"string"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"parkhaus","type":"uint256"}],"name":"checkCarPark","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"car_searched","type":"address"}],"name":"showCar","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"parkhaus","type":"uint256"}],"name":"parkOut","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"parkhaus","type":"uint256"}],"name":"checkIn","outputs":[{"name":"s","type":"string"}],"payable":true,"stateMutability":"payable","type":"function"},{"anonymous":false,"inputs":[{"indexed":false,"name":"car","type":"address"},{"indexed":false,"name":"parkhaus","type":"uint256"}],"name":"join_success_In","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"car","type":"address"},{"indexed":false,"name":"parkhaus","type":"uint256"}],"name":"join_success_Out","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"parkhaus","type":"uint256"},{"indexed":false,"name":"frei","type":"uint256"}],"name":"free_spots","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"car","type":"address"},{"indexed":false,"name":"parkhaus","type":"uint256"},{"indexed":false,"name":"parkingTime","type":"uint256"},{"indexed":false,"name":"value_now","type":"uint256"},{"indexed":false,"name":"parkplatz","type":"uint256"}],"name":"show_car","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"car","type":"address"},{"indexed":false,"name":"parkhaus","type":"uint256"},{"indexed":false,"name":"parkplatz","type":"uint256"}],"name":"park_success_In","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"car","type":"address"},{"indexed":false,"name":"parkhaus","type":"uint256"},{"indexed":false,"name":"parkplatz","type":"uint256"}],"name":"park_success_Out","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"car","type":"address"}],"name":"free_parking","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"car","type":"address"},{"indexed":false,"name":"value","type":"uint256"},{"indexed":false,"name":"parkingTime","type":"uint256"}],"name":"pay_fee","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"car","type":"address"},{"indexed":false,"name":"value","type":"uint256"},{"indexed":false,"name":"parkingTime","type":"uint256"}],"name":"pay_max","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"car","type":"address"}],"name":"car_not_found","type":"event"}]);


//Addresse von dem Contract eintragen
var car_park = browser_ballot_sol_gameContract.at('0x2523ce437ce0c990e80f896126201ee237f1ffb9');  

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
      
      console.log('Aufenthaltsdauer: ' + h + ' h :' + m + ' m :' + s + ' s. Parkgebühr: ' + result.args.value / 1000000000000000000 + ' (Adresse des Autos: ' + result.args.car + ')' );
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
      
      console.log('Aufenthaltsdauer: ' + h + ' h :' + m + ' m :' + s + ' s. Parkgebühr = Tageshöchstsatz: ' + result.args.value / 1000000000000000000 + ' (Adresse des Autos: ' + result.args.car + ')' );
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
      
      console.log('Das Auto '+ result.args.car + ' steht im Parkhaus ' + result.args.parkhaus + ' auf Parkplatz ' + result.args.parkplatz + ' seit: ' + h + ' h :' + m + ' m :' + s + ' s. Die aktuelle Gebuehr betraegt: ' +  result.args.value_now / 1000000000000000000);
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
      console.log('Erfolgreicher Halt auf Parkplatz ' + result.args.parkplatz + ' im Parkhaus: ' + result.args.parkhaus  + ' (Adresse des Autos: ' + result.args.car + ')' );
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
      console.log('Erfolgreiches Wegfahren von Parkplatz ' + result.args.parkplatz + ' in Parkhaus: ' + result.args.parkhaus  + ' (Adresse des Autos: ' + result.args.car + ')' );
  }
  else
  {
      console.log('Fehler');
  }

});

var event_car_not_found = car_park.car_not_found ();
event_car_not_found.watch(function(error, result)
{
  if(!error)
  {
      console.log('Das Auto wurde nicht gefunden: ' + result.args.car );
  }
  else
  {
      console.log('Fehler');
  }

});
