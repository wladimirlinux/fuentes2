<?php 
$url = 'http://192.168.2.8/luci/;stok=87de453d96f2f5b365e700d6a63cbec7/admin/callcontrol/sms';
$context  = stream_context_create($options);
$result = json_decode((file_get_contents($url, false, $context)), true);

if ($result["resultado"]===0) {print 'Se ha enviado el SMS exitosamente';} else {print 'ha ocurrido un error!!';}

print '<pre>';
print_r ($result);

?>
