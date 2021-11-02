echo "limpiando recibido"
curl http://192.168.2.8/luci/gsm_empty_recv_msg
echo "limpiando enviados"
curl http://192.168.2.8/luci/gsm_empty_send_msg
