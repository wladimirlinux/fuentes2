<?
 //parámetros de envío
 $usuario="wladimirlinux@gmail.com";
 $clave="13benedilce";
 $telefonos="584244967288";
 $texto="prueba";
//los parámetros a usar por el webservices:
 $parametros="usuario=$usuario&clave=$clave&texto=$texto&telefonos=$telefonos";

//URL para capturar los datos de envio con webservices
 //envio de parametros con metodo post a traves de CURL
 $url = "http://www.sistema.massivamovil.com/webservices/SendSms";
 $handler = curl_init();
 curl_setopt($handler, CURLOPT_URL, $url);
 curl_setopt($handler, CURLOPT_POST,true);
 curl_setopt($handler, CURLOPT_POSTFIELDS, $parametros);
 $response = curl_exec ($handler);
 curl_close($handler);


?>



