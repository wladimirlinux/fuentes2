<?php
$rand = rand();
$url = 'http://190.145.50.27/default/en_US/sms_info.html';
$line = '1'; // sim card to use in my case #1
$telnum = '899300'; // phone number to send sms
$smscontent = 'this is a test sms'; //your message
$username = "admin"; //goip username
$password = "admin"; //goip password

$fields = array(
'line' => urlencode($line),
'smskey' => urlencode($rand),
'action' => urlencode('sms'),
'telnum' => urlencode($telnum),
'smscontent' => urlencode($smscontent),
'send' => urlencode('send')
);

//url-ify the data for the POST
foreach($fields as $key=>$value) { $fields_string .= $key.'='.$value.'&'; }
rtrim($fields_string, '&');

//open connection
$ch = curl_init();

//set the url, number of POST vars, POST data
curl_setopt($ch,CURLOPT_URL, $url);

curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_USERPWD, "$username:$password");
curl_setopt($ch, CURLOPT_HTTPAUTH, CURLAUTH_BASIC);
curl_setopt($ch, CURLOPT_PORT, 9005);
curl_setopt($ch,CURLOPT_POST, count($fields));
curl_setopt($ch,CURLOPT_POSTFIELDS, $fields_string);

//execute post
echo curl_exec($ch);
echo curl_getinfo($ch);

//close connection
curl_close($ch);
?>
