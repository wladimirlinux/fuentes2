DESTINO=87787
CONTENT=festivo
curl "http://192.168.2.8/luci/gsm_send_msg?id=00001&to=$DESTINO&content=$CONTENT"
