DESTINO=899300
CONTENT=prueba
curl "http://192.168.2.8/luci/gsm_send_msg?id=00001&to=$DESTINO&content=$CONTENT"
