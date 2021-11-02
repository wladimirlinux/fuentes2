<?
//Realizamos El Envío En Este Caso Mediante El Método Post
//parámetros de envío
//email del usuario
$usuario="wladimirlinux@gmail.com";
//clave del usuario
$clave="13benedilce";
$telefonos="584244967288";
$texto="rico lo hace";
$parametros="usuario=$usuario&clave=$clave&texto=$texto&telefonos=$telefonos";
$url = "http://www.sistema.massivamovil.com/webservices/SendSms";
//inicio de curl para envío
$handler = curl_init();
//se coloca la url de envio de sms
curl_setopt($handler, CURLOPT_URL, $url);
//se identifica que el envio es por el metodo POST
curl_setopt($handler, CURLOPT_POST,true);
//indica que el envio tiene respuesta y no true o false
curl_setopt($handler, CURLOPT_RETURNTRANSFER, true);
//envio de parametros con metodo post a traves de CURL
curl_setopt($handler, CURLOPT_POSTFIELDS, $parametros);
//en la variable respuesta se obtiene el documento xml que genero el envio
$respuesta = curl_exec ($handler);
//se cierra el hilo de curl
curl_close($handler);

?>

