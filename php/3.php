<?php
$salida = shell_exec('/usr/bin/ansible conexcol -a "systemctl status httpd" --become');
echo "<pre>$salida</pre>";
?>
