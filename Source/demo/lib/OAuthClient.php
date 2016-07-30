<?php

function GUID()
{
    if (function_exists('com_create_guid') === true)
    {
        return trim(com_create_guid(), '{}');
    }

    return sprintf('%04X%04X-%04X-%04X-%04X-%04X%04X%04X', mt_rand(0, 65535), mt_rand(0, 65535), mt_rand(0, 65535), mt_rand(16384, 20479), mt_rand(32768, 49151), mt_rand(0, 65535), mt_rand(0, 65535), mt_rand(0, 65535));
}

class OAuthClient
{
    public static $config;

    public static function initModule($config)
    {
        self::$config = $config;
    }

    public static function isAuthorized()
    {
        if(!isset($_SESSION['access_token']))
            return false;

        $access_token = $_SESSION['access_token'];
        if( empty($access_token) )
            return false;


        $ch = curl_init();

        $oauth_config = self::$config['oauth_api'];

        $valid_token_url = sprintf("%s%s?token=%s",
            $oauth_config['oauth_server_url'],
            $oauth_config['valid_token_url'],
            $access_token);

//        echo $valid_token_url;

        curl_setopt($ch, CURLOPT_URL, $valid_token_url);

        curl_setopt_array($ch, array(
            CURLOPT_SSL_VERIFYPEER => false,
        ));

        // Option to Return the Result, rather than just true/false
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

        curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'get');
//        $postdata = json_encode(array('token'=>$access_token));
//        echo $postdata;
//        curl_setopt($ch, CURLOPT_POSTFIELDS, $postdata);

        $output=curl_exec($ch);

        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);

//        echo $output;
        if( $httpCode == 200 ) {
            return true;
        }

        return false;
    }

    public static function getProfile($access_token)
    {
        $ch = curl_init();

        $oauth_config = self::$config['oauth_api'];
        $profile_url = sprintf("%s%s",
            $oauth_config['oauth_server_url'],
            $oauth_config['profile_url']
            );

        curl_setopt($ch, CURLOPT_URL, $profile_url);

        $request_headers = array();
        $request_headers[] = 'Authorization:Bearer ' . $access_token;

        curl_setopt_array($ch, array(
            CURLOPT_SSL_VERIFYPEER => false,
        ));

        curl_setopt($ch, CURLOPT_HTTPHEADER, $request_headers);

        // Option to Return the Result, rather than just true/false
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

        curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'get');

//        $postdata = json_encode($params);
//        curl_setopt($ch, CURLOPT_POSTFIELDS, $postdata);

        $output=curl_exec($ch);

        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);

        $ret = array();

        $ret['code'] = $httpCode;
        $ret['result'] = $output;


        if( $httpCode == 200 ) {
            $profile = json_decode($output, true);;
            $_SESSION['profile'] = $profile;
        }

        return $profile;
    }
    public static function getAuthorizeURL()
    {
        $oauth_config = self::$config['oauth_api'];

        $state = GUID();
        $nonce = GUID();
        $authorizationUrl = sprintf("%s%s?client_id=%s&scope=%s&response_type=%s&redirect_uri=%s&response_mode=%s&state=%s&nonce=%s",
            $oauth_config['oauth_server_url'],
            $oauth_config['authorize_url'],
            $oauth_config['clientId'],
            "openid email profile roles",
            "id_token token",
            $oauth_config['redirectUri'],
            "form_post",
            $state,
            $nonce
        );

        return $authorizationUrl;
    }

    public static function getLogoutURL()
    {
        $oauth_config = self::$config['oauth_api'];
        $logoutUrl = sprintf("%s%s?id_token_hint=%s&post_logout_redirect_uri=%s",
            $oauth_config['oauth_server_url'],
            $oauth_config['logout_url'],
            $_SESSION['id_token'],
            $oauth_config['logout_redirect_url']
        );

//        $logoutUrl = "https://localhost:44300/core/logout";
        return $logoutUrl;
    }

    public static function logout()
    {
        $ch = curl_init();

        $oauth_config = self::$config['oauth_api'];
        $logoutUrl = sprintf("%s%s?id_token_hint=%s&post_logout_redirect_uri=%s",
            $oauth_config['oauth_server_url'],
            $oauth_config['logout_url'],
            $_SESSION['id_token'],
            $oauth_config['logout_redirect_url']
        );

        curl_setopt($ch, CURLOPT_URL, $logoutUrl);

        curl_setopt_array($ch, array(
            CURLOPT_SSL_VERIFYPEER => false,
        ));

        // Option to Return the Result, rather than just true/false
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

        curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'get');

        $output=curl_exec($ch);
    }

}