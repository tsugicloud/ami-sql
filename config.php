<?php

// allow programmatic access to upgrade scripts
$path = '/var/www/html';
$fullpath = get_include_path() . PATH_SEPARATOR . $path;
ini_set('include_path', $fullpath);

// Grab the config-dist to clean up this file and only show the stuff we've changed
require_once("config-dist.php");

// Some defaults

$CFG->apphome   = false;
if ( isset($_SERVER['HTTP_HOST']) ) {
    $CFG->wwwroot   = "http://" . $_SERVER['HTTP_HOST'] . '/tsugi';
}
$CFG->adminpw = 'sha256:9c0ccb0d53dd71b896cde69c78cf977acbcb36546c96bedec1619406145b5e9e';

// Record local analytics but don't send anywhere.
$CFG->launchactivity = true;
$CFG->eventcheck = false;

$CFG->google_client_id = false;
$CFG->google_client_secret = false;
$CFG->google_map_api_key = false;

// Fun colors...
$CFG->bootswatch = 'cerulean';
$CFG->bootswatch_color = rand(0,52);

$CFG->dataroot = '/efs/blobs';

$CFG->git_command = '/usr/local/bin/gitx';

$CFG->DEVELOPER = false;

if ( strlen(getenv('TSUGI_DBUSER')) > 0 ) {
    $PADDING_SECURE = substr(getenv('TSUGI_DBUSER'),0,3);
} else {
    $PADDING_SECURE = substr(getenv('TSUGI_USER'),0,3);
}
$CFG->cookiesecret = md5('jTusRPnUsHKP4G968H8r3xkzpMsk'.$PADDING_SECURE);
$CFG->cookiename = 'TSUGIAUTO';
$CFG->cookiepad = md5('B77trww5PQ'.$PADDING_SECURE);

$CFG->maildomain = getenv('TSUGI_MAILDOMAIN');
$CFG->mailsecret = md5('XaWPZvESnNV84FvHpqQ69yhHAkyrNEVjkcF7'.$PADDING_SECURE);
$CFG->maileol = "\n";

$CFG->sessionsalt = md5("fpmqZWBcp993Ca8RNWtVJfeM82Xf2fwK8uwD".$PADDING_SECURE);

$CFG->timezone = 'America/New_York';

// Set to true to redirect to the upgrading.php script
// Also copy upgrading-dist.php to upgrading.php and add your message
$CFG->upgrading = false;

$CFG->dynamodb_key = false; // 'AKIISDIUSDOUISDHFBUQ';
$CFG->dynamodb_secret = false; // 'zFKsdkjhkjskhjSAKJHsakjhSAKJHakjhdsasYaZ';
$CFG->dynamodb_region = false; // 'us-east-2'

$CFG->lessons = false;
$CFG->logo_url = false;

// Overrides from env vars will be inserted here - do not change the line below

// ---OVERRIDES---

// These do not come through in the overrides
if ( strlen(getenv('TSUGI_LESSONS')) > 0 ) {
    $CFG->lessons = getenv('TSUGI_LESSONS');
}

if ( strlen(getenv('TSUGI_LOGO_URL')) > 0 ) {
    $CFG->logo_url = getenv('TSUGI_LOGO_URL');
}

if ( strlen(getenv('TSUGI_CONTEXT_TITLE')) > 0 ) {
    $CFG->logo_url = getenv('TSUGI_CONTEXT_TITLE');
}

if ( strlen(getenv('TSUGI_BADGE_PATH')) > 0 ) {
    $CFG->badge_path = getenv('TSUGI_BADGE_PATH');
}

// Have to do this after apphome is set
if ( isset($CFG->apphome) ) {
    $CFG->tool_folders = array("admin", "../tools", "../mod");
    $CFG->install_folder = $CFG->dirroot.'/../mod';
}

// http://docs.aws.amazon.com/aws-sdk-php/v2/guide/feature-dynamodb-session-handler.html
if ( strlen($CFG->dynamodb_key) > 0 && strlen($CFG->dynamodb_secret) > 0 && strlen($CFG->dynamodb_region) > 0 ) {
    $CFG->sessions_in_dynamodb = true;
    if ( $CFG->sessions_in_dynamodb ) {
        $dynamoDb = \Aws\DynamoDb\DynamoDbClient::factory(
            array('region' => $CFG->dynamodb_region,
            'credentials' => array(
                'key'    => $CFG->dynamodb_key,
                'secret' => $CFG->dynamodb_secret
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

