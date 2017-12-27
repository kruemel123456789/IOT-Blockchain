
var browser_ballot_sol_gameContract = web3.eth.contract();


//Addresse von dem Contract eintragen
var car_park = browser_ballot_sol_gameContract.at('');  

var event_join_success_In = car_park.join_success_In();
event_join_success_In.watch(function(error, result)
{
  if(!error)
  {
      console.log('Erfolgreiche Einfahrt in Parkhaus: ' + result.args.parkhaus  + ' (Adresse des Autos: ' + result.args.player + ')' );
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
      console.log('Erfolgreiche Ausfahrt aus Parkhaus: ' + result.args.parkhaus  + ' (Adresse des Autos: ' + result.args.player + ')' );
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
      console.log('Mindestparkdauer unterschritten --> Der Aufenthalt war kostenlos' + ' (Adresse des Autos: ' + result.args.player + ')' );
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
      int h =  result.args.parkingTime/3600;
      int m =  (result.args.parkingTime - (h*3600))/60;
      int s = (result.args.parkingTime - (h*3600) - (m*60));
      
      console.log('Aufenthaltsdauer (h:m:s): ' + h + ':' + m + ':' + s + 'Parkgebühr: ' + reslut.args.value / 1000000000000000000 + ' (Adresse des Autos: ' + result.args.player + ')' );
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
      int h =  result.args.parkingTime/3600;
      int m =  (result.args.parkingTime - (h*3600))/60;
      int s = (result.args.parkingTime - (h*3600) - (m*60));
      
      console.log('Aufenthaltsdauer (h:m:s): ' + h + ':' + m + ':' + s + 'Parkgebühr = Tageshöchstsatz: ' + reslut.args.value / 1000000000000000000 + ' (Adresse des Autos: ' + result.args.player + ')' );
  }
  else
  {
      console.log('Fehler');
  }

});
