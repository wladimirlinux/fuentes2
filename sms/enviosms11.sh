DESTINO=899300
CONTENT=domingo
curl "http://192.168.2.8/luci/gsm_send_msg?id=00001&to=$DESTINO&content=$CONTENT"
