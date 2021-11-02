<?php

class GoIP{
    public $ip = 'http://127.0.0.1/default/en_US/sms_info.html';
    public $uname = 'admin';
    public $pwd = '2580';

    function sendSMS($num, $msg, $line=1){
        $rand = rand();
        $fields = [
            'line' => urlencode($line),
            'smskey' => urlencode($rand),
            'action' => urlencode('sms'),
            'telnum' => urlencode($num),
            'smscontent' => urlencode($msg),
            'send' => urlencode('send')
        ];

        //url-ify the data for the POST
        $fields_string = "";
        foreach($fields as $key=>$value) { 
            $fields_string .= $key.'='.$value.'&'; 
        }
        rtrim($fields_string, '&');

        $ch = curl_init();

        curl_setopt($ch, CURLOPT_URL, $this->ip);
        curl_setopt($ch, CURLOPT_USERPWD, "{$this->uname}:{$this->pwd}");
        curl_setopt($ch, CURLOPT_HTTPAUTH, CURLAUTH_BASIC);
        curl_setopt($ch, CURLOPT_PORT, 80);
        curl_setopt($ch, CURLOPT_POST, count($fields));
        curl_setopt($ch, CURLOPT_POSTFIELDS, $fields_string);

        curl_exec($ch);
        curl_getinfo($ch);

        curl_close($ch);

    }

    function sendBulkSMS($nums=[], $msg, $line=1){
        foreach($nums as $i=>$num){
            self::sendSMS($num, $msg, $line);
        }
    }
}
