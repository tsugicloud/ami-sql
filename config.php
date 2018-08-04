<?php

// allow programmatic access to upgrade scripts
$path = '/var/www/html';
$fullpath = get_include_path() . PATH_SEPARATOR . $path;
ini_set('include_path', $fullpath);

// Grab the config-dist to clean up this file and only show the stuff we've changed
require_once("config-dist.php");
$CFG->apphome   = false;
if ( isset($_SERVER['HTTP_HOST']) ) {
    $CFG->wwwroot   = "http://" . $_SERVER['HTTP_HOST'] . '/tsugi';
}

if ( strlen(getenv('TSUGI_WWWROOT')) > 0 ) {
    $CFG->wwwroot = getenv('TSUGI_WWWROOT');
}

if ( strlen(getenv('TSUGI_APPHOME')) > 0 ) {
    $CFG->apphome = getenv('TSUGI_APPHOME');
}

if ( strlen(getenv('TSUGI_PDO')) > 0 ) {
  $CFG->pdo = getenv('TSUGI_PDO');
}
if ( strlen(getenv('TSUGI_USER')) > 0 ) {
    $CFG->dbuser    = getenv('TSUGI_USER');
}
if ( strlen(getenv('TSUGI_PASSWORD')) > 0 ) {
    $CFG->dbpass    = getenv('TSUGI_PASSWORD');
}

// tsugi is the admin pw
$CFG->adminpw = 'sha256:9c0ccb0d53dd71b896cde69c78cf977acbcb36546c96bedec1619406145b5e9e';
if ( strlen(getenv('TSUGI_ADMINPW')) > 0 ) {
    $CFG->adminpw   = getenv('TSUGI_ADMINPW');
}

// Have to do this after apphome is set
if ( isset($CFG->apphome) ) {
    $CFG->tool_folders = array("admin", "../tools", "../mod");
    $CFG->install_folder = $CFG->dirroot.'/../mod';
}

$CFG->servicename = 'TSUGI';
if ( strlen(getenv('TSUGI_SERVICENAME')) > 0 ) {
    $CFG->servicename = getenv('TSUGI_SERVICENAME');
}

$CFG->servicedesc = getenv('TSUGI_SERVICEDESC');

// $CFG->websocket_port = 2021;
// $CFG->websocket_secret = 'changeme';
// $CFG->websocket_url = 'ws://localhost:2021';

if ( strlen(getenv('TSUGI_WEBSOCKET_PORT')) > 0 ) {
    $CFG->websocket_port = getenv('TSUGI_WEBSOCKET_PORT');
}

if ( strlen(getenv('TSUGI_WEBSOCKET_SECRET')) > 0 ) {
    $CFG->websocket_secret = getenv('TSUGI_WEBSOCKET_SECRET');
}

if ( strlen(getenv('TSUGI_WEBSOCKET_URL')) > 0 ) {
    $CFG->websocket_url = getenv('TSUGI_WEBSOCKET_URL');
}

// Record local analytics but don't send anywhere.
$CFG->launchactivity = true;
$CFG->eventcheck = false;

// Set to true to redirect to the upgrading.php script
// Also copy upgrading-dist.php to upgrading.php and add your message
$CFG->upgrading = false;

// Fun colors...
$CFG->bootswatch = 'cerulean';
$CFG->bootswatch_color = rand(0,52);

$CFG->google_client_id = false;
$CFG->google_client_secret = false;
if ( strlen(getenv('TSUGI_GOOGLE_CLIENT_ID')) > 0 ) {
    $CFG->google_client_id = getenv('TSUGI_GOOGLE_CLIENT_ID');
    $CFG->google_client_secret = getenv('TSUGI_GOOGLE_CLIENT_SECRET');
}

$CFG->google_map_api_key = false;
if ( strlen(getenv('TSUGI_MAP_API_KEY')) > 0 ) {
    $CFG->google_map_api_key = getenv('TSUGI_MAP_API_KEY'); // 'Ve8eH490843cIA9IGl8';
}

$CFG->dataroot = '/efs/blobs';

$CFG->git_command = '/usr/local/bin/gitx';

$CFG->DEVELOPER = false;

$PADDING_SECURE = substr(getenv('TSUGI_USER'),0,3);
$CFG->cookiesecret = md5('jTusRPnUsHKP4G968H8r3xkzpMsk'.$PADDING_SECURE);
$CFG->cookiename = 'TSUGIAUTO';
$CFG->cookiepad = md5('B77trww5PQ'.$PADDING_SECURE);

$CFG->maildomain = getenv('TSUGI_MAILDOMAIN');
$CFG->mailsecret = md5('XaWPZvESnNV84FvHpqQ69yhHAkyrNEVjkcF7'.$PADDING_SECURE);
$CFG->maileol = "\n";

$CFG->sessionsalt = md5("fpmqZWBcp993Ca8RNWtVJfeM82Xf2fwK8uwD".$PADDING_SECURE);

$CFG->timezone = 'America/New_York';

// Store sessions in a database -  Keep this false until the DB upgrade
// has run once or you won't be able to get into the admin. The
// connection used should should be a different database or at
// least a different connection since the Symfony PdoSessionHandler
// messes with how the connection handles transactions for its own purposes.
$CFG->sessions_in_db = getenv('SESSIONS_IN_DB') == 'true';
if ( $CFG->sessions_in_db ) {
    $session_save_pdo = new PDO($CFG->pdo, $CFG->dbuser, $CFG->dbpass);
    $session_save_pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    session_set_save_handler(
        new \Symfony\Component\HttpFoundation\Session\Storage\Handler\PdoSessionHandler(
            $session_save_pdo,
            array('db_table' => $CFG->dbprefix . "sessions")
        )
    );
}

// http://docs.aws.amazon.com/aws-sdk-php/v2/guide/feature-dynamodb-session-handler.html
$CFG->dynamo_key = getenv('DYNAMODB_KEY'); // 'AKIISDIUSDOUISDHFBUQ';
$CFG->dynamo_secret = getenv('DYNAMODB_SECRET'); // 'zFKsdkjhkjskhjSAKJHsakjhSAKJHakjhdsasYaZ';
$CFG->dynamo_region = getenv('DYNAMODB_REGION'); // 'us-east-2'
if ( strlen($CFG->dynamo_key) > 0 && strlen($CFG->dynamo_secret) > 0 && strlen($CFG->dynamo_region) > 0 ) {
    $CFG->sessions_in_dynamodb = true;
    if ( $CFG->sessions_in_dynamodb ) {
        $dynamoDb = \Aws\DynamoDb\DynamoDbClient::factory(
            array('region' => $CFG->dynamo_region,
            'credentials' => array(
                'key'    => $CFG->dynamo_key,
                'secret' => $CFG->dynamo_secret
            ),
            'version' => 'latest'));
        $sessionHandler = $dynamoDb->registerSessionHandler(array(
            'table_name'               => 'sessions',
            'hash_key'                 => 'id',
            'session_lifetime'         => 3600,
            'consistent_read'          => true,
            'locking_strategy'         => null,
            'automatic_gc'             => 0,
            'gc_batch_size'            => 50,
            'max_lock_wait_time'       => 15,
            'min_lock_retry_microtime' => 5000,
            'max_lock_retry_microtime' => 50000,
        ));
    }
}

