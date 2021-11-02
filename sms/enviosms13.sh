#uname -ar
#cat /etc/armbianmonitor/datasources/soctemp
DESTINO=899300
CONTENT=domingo
#salida=$(uname -ar 2>&1)
echo "$salida"
w3m "http://192.168.2.8/luci/gsm_send_msg?id=00001&to=$DESTINO&content=$salida"
