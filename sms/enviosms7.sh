MENSAJE='HolaMundo'
echo $MENSAJE
curl "http://192.168.2.8/luci/gsm_send_msg?id=00001&to=899300&content=$MENSAJE"
