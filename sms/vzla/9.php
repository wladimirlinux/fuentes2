<?
//$usuario="wladimirlinux@gmail.com";
//$clave="13benedilce";
//$telefonos="584244967288";
//$texto="prueba de envío ";
//$url="http://127.0.0.1/;
//$handler=curl_init();
//curl_setopt($handler,CURLOPT_URL,$url);
//curl_setopt($handler,CURLOPT_POST,true);
//curl_setopt($handler,CURLOPT_POSTFIELDS,$parametros);
//$response=curl_exec($handler);
//curl_close($handler);
$headers = array('Content-Type: application/json');
//     $ch = curl_init('https://api.gateway360.com/api/3.0/sms/send');
      $ch = curl_init('http://127.0.0.1/');
      curl_setopt($ch, CURLOPT_POST, 1);
      curl_setopt($ch, CURLOPT_RETURNTRANSFER,true);
      curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
//      curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($request));
      $result = curl_exec($ch);
      if (curl_errno($ch) != 0 ){
      die("curl error: ".curl_errno($ch));
  }


?>

