<?php
// Sending simple message using PHP
// http://jasminsms.com

$baseurl='http://192.168.2.8/luci/gsm_send_msg'
$params='?id=00001'
$params='&to='.urlencode('899300')
$params='&content='.urlencode('Hello world !')
$response=file_get_contents($baseurl.$params);
?>
