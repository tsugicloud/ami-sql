<?php

// php fixconfig.php < config.php

require_once('/var/www/html/tsugi/config-dist.php');

// From the old to new environment variables
$mapping = array(
  "user" => "dbuser",
  "password" => "dbpass",
  "map_api_key" => "google_map_api_key",
);

// These are the keys not in config.dist
$good_keys = array(
    'lessons', 'logo_url', 'context_title', 'badge_path',
    'google_classroom_secret', 'privacy_url', 'sla_url'
);

$overrides = '';
foreach($_SERVER as $k => $v ) {
    if (strpos($k, 'TSUGI_') === false ) continue;
    $p = strtolower(substr($k,6));
    if ( isset($mapping[$p]) ) $p = $mapping[$p];
    $newv = '"'.$v.'"'; // assume string;
    if ( is_numeric($v) ) $newv = $v;
    if ( $v == 'false' ) $newv = $v;
    if ( $v == 'true' ) $newv = $v;
    if ( isset($CFG->{$p}) || in_array($p, $good_keys) ) {
        $overrides .= '$'."CFG->$p = $newv;\n";
    }
}

$old = file_get_contents("php://stdin");

$new = preg_replace_callback(
    '|getenv\(\'([^\']*)\'\)|',
    function ($matches) {
        // return __(htmlent_utf8(trim($matches[1])));
        $key = trim($matches[1]);
        $value = getenv($key);
        return "'".$value."'";
    },
    $old
);

$new = str_replace('// ---OVERRIDES---',$overrides, $new);

echo($new);
