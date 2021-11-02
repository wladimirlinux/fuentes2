DESTINO=899970
SALIDA=$(cat /etc/armbianmonitor/datasources/soctemp 2>&1)
DATOS='Temperatura es: '"$SALIDA"
wget   "http://192.168.2.8/luci/gsm_send_msg?id=00001&to=$DESTINO&content=$DATOS"  -v -O  bajar; rm -rf  bajar



