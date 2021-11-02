HOY=`date +%a`
echo "la fecha de hoy es: $HOY"

curl "http://192.168.2.8/luci/gsm_send_msg?id=00001&to=899300&content=$DATE"
