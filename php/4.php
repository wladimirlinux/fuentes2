<?php 
header("Expires: Mon, 26 Jul 1997 05:00:00 GMT");
getMail();
$ext = $subject;
$stm = date("YmdHis", time());
$fn = "/var/spool/asterisk/outgoing/$stm.cal";
$fp = fopen( $fn , "wb" );
$t = "Channel: Local/$ext@custom-auto-dial-out\nExtension: 12\nCallerID: DISA\nPriority: 1\nMaxRetries: 5\nRetryTime: 300\nWaitTime: 120\nContext: custom-auto-dial-out-context\n";
fwrite( $fp, $t);
fclose( $fp );
?>
