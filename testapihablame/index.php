<?php 
$url = 'https://api.hablame.co/sms/envio/';
$data = array(
	'cliente' => 10013824, //Numero de cliente
	'api' => 'gBmqOKgVjmQMHTpYJDtTAxeU8a9i9j', //Clave API suministrada
	'numero' => '573118082011', //numero o numeros telefonicos a enviar el SMS (separados por una coma ,)
	'sms' => 'SMS API de prueba Hablame Colombia eseta OK ', //Mensaje de texto a enviar
	'fecha' => '', //(campo opcional) Fecha de envio, si se envia vacio se envia inmediatamente (Ejemplo: 2017-12-31 23:59:59)
	'referencia' => 'Referenca Envio Hablame', //(campo opcional) Numero de referencio ó nombre de campaña
);

$options = array(
    'http' => array(
        'header'  => "Content-type: application/x-www-form-urlencoded\r\n",
        'method'  => 'POST',
        'content' => http_build_query($data)
    )
);
$context  = stream_context_create($options);
$result = json_decode((file_get_contents($url, false, $context)), true);

if ($result["resultado"]===0) {print 'Se ha enviado el SMS exitosamente';} else {print 'ha ocurrido un error!!';}

print '<pre>';
print_r ($result);

?>
