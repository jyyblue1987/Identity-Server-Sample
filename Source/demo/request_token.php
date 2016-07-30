<?php

    $code = $_POST['code'];

    $username = 'jkh';
    $password = 'jkh12345';
    $client_id = 'normalclient';
    $client_secret = 'normal';

    $request_token_url = sprintf("%s%s",
        "https://localhost:44300/core",
        "/connect/token");

    $ch = curl_init();

    curl_setopt($ch, CURLOPT_URL, $request_token_url);

    $request_headers = array();
    $request_headers[] = 'Authorization:Basic ' . base64_encode($client_id . ':' . $client_secret);
    $request_headers[] = 'Content-Type: application/x-www-form-urlencoded';

    curl_setopt_array($ch, array(
        CURLOPT_SSL_VERIFYPEER => false,
    ));

    curl_setopt($ch, CURLOPT_HTTPHEADER, $request_headers);

    // Option to Return the Result, rather than just true/false
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

    curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'post');

    $params = array(
        'grant_type' => 'authorization_code',
        'scope' => 'openid email profile roles',
        'redirect_uri' => 'http://192.168.1.253:8895/request_token.php',
        'code' => $code,
        'username' => $username,
        'password' => $password,
        'client_id' => $client_id,
        'client_secret' => $client_secret
    );

    $postdata = http_build_query($params);

    curl_setopt($ch, CURLOPT_POSTFIELDS, $postdata);

    $output=curl_exec($ch);

    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);

    $ret = array();

    $ret['code'] = $httpCode;
    $ret['result'] = $output;

    echo $output;



