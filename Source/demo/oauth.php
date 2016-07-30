<?php

    $authorizationUrl = sprintf("%s%s?client_id=%s&scope=%s&response_type=%s&redirect_uri=%s&response_mode=%s&state=%s&nonce=%s",
                            "https://localhost:44300/core",
                            "/connect/authorize",
                            "meiclient",
                            "openid email profile roles",
                            "id_token token",
                            "http://192.168.1.253:8895/callback",
                            "form_post",
                            "abc",
                            "xyz"
                            );

    $request_code_url = sprintf("%s%s?response_type=%s&client_id=%s&redirect_uri=%s&scope=%s&response_mode=%s&state=%s&nonce=%s",
        "https://localhost:44300/core",
        "/connect/authorize",
        "code",
        "normalclient",
        "http://192.168.1.253:8895/request_token.php",
        "openid email profile roles",
        "form_post",
        "abc",
        "xyz"
    );

//    echo $authorizationUrl;
//return;

    // Redirect the user to the authorization URL.
    header('Location: ' . $request_code_url);
    exit;
