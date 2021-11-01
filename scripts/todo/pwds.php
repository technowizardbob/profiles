<?php
const home_dir = 0;
const install_dir = 1;
const use_default = home_dir;
$pwds_dir = "/.todo";

function is_cli(): bool {
    if (defined('STDIN')) {
        return true;
    }

    if (php_sapi_name() === 'cli') {
        return true;
    }

    if (array_key_exists('SHELL', $_ENV)) {
        return true;
    }

    if (empty($_SERVER['REMOTE_ADDR']) and ! isset($_SERVER['HTTP_USER_AGENT']) and count($_SERVER['argv']) > 0) {
        return true;
    }

    if (!array_key_exists('REQUEST_METHOD', $_SERVER)) {
        return true;
    }

    return false;
}

if (is_cli() === false) {
    echo('Unable to Start');
    exit(1);
}

function key_file(): string {
    for($i = 1; $i < $GLOBALS['argc']; $i++) {
        $opt = strtolower($GLOBALS['argv'][$i]);
        if ($opt === "-keyfile" || $opt === "-k") {
            $key_file = (isset($GLOBALS['argv'][$i+1])) ? $GLOBALS['argv'][$i+1] : "";
            if (!empty($key_file)) {
                return $key_file;
            }
        }
    }
    return "";
}

function db_file(): string {
    for($i = 1; $i < $GLOBALS['argc']; $i++) {
        $opt = strtolower($GLOBALS['argv'][$i]);
        if ($opt === "-dbfile" || $opt === "-d") {
            $db_file = (isset($GLOBALS['argv'][$i+1])) ? $GLOBALS['argv'][$i+1] : "";
            if (!empty($db_file)) {
                return $db_file;
            }
        }
    }
    return "";
}

function db_name(): string {
    $generic = true;
    for($i = 1; $i < $GLOBALS['argc']; $i++) {
        $opt = strtolower($GLOBALS['argv'][$i]);
        if ($opt === "-usernamed" || $opt === "-u") {
            $generic = false;
        }
        if ($opt === "-who") {
            $whoami = (isset($GLOBALS['argv'][$i+1])) ? $GLOBALS['argv'][$i+1] : "";
        }
    }
    if (empty($whoami)) {
        return "pwds.db";
    }
    return ($generic) ? "pwds.db" : "{$whoami}_pwds.db";
}
$pwds_file = db_name();

function home_dir(): string {
    $use_home = use_default;    
    for($i = 1; $i < $GLOBALS['argc']; $i++) {
        $opt = strtolower($GLOBALS['argv'][$i]);
        if ($opt === "-installpath" || $opt === "-i") {
            $use_home = install_dir;
            break;
        }
        if ($opt === "-home") {
            $use_home = home_dir;
            break;
        }
        if ($opt === "-dir") {
            $dir = (isset($GLOBALS['argv'][$i+1])) ? $GLOBALS['argv'][$i+1] : "";
            if (!empty($dir)) {
                return $dir;
            }
        }
    }
    if ($use_home === install_dir) {
        return __DIR__; // Use install DIR
    }
    if (isset($_SERVER['HOME'])) {
        $result = $_SERVER['HOME'];
    } else {
        $result = getenv("HOME");
    }

    if (empty($result) && !empty($_SERVER['HOMEDRIVE']) && !empty($_SERVER['HOMEPATH'])) {
        $result = $_SERVER['HOMEDRIVE'] . $_SERVER['HOMEPATH'];
    }

    if (empty($result) && function_exists('exec')) {
        if(strncasecmp(PHP_OS, 'WIN', 3) === 0) {
            $result = exec("echo %userprofile%");
        } else {
            $result = exec("echo ~");
        }
    }
    $result = str_replace('..', '', $result);
    $result = rtrim($result, '/');
    $result = rtrim($result, '\\');
    return $result;
}

$open_db = db_file();
if (empty($open_db)) {
    $home_dir = home_dir() . $pwds_dir;

    if (! is_dir($home_dir)) {
        $s = mkdir($home_dir);
        if ($s === false) {
            echo "Unable to create folder: {$home_dir}" . PHP_EOL;
            exit(1);
        }
    }
    $open_db = "{$home_dir}/{$pwds_file}";
}

try {
    $pdo = new PDO("sqlite:{$open_db}");
} catch (PDOException $e) {
    echo $e->getMessage() . PHP_EOL;
    exit(1);
}

try {
    $sql = "CREATE TABLE IF NOT EXISTS systems_pwd (
            id   INTEGER PRIMARY KEY AUTOINCREMENT,
            item  TEXT    NOT NULL,
            pwd   TEXT    NOT NULL,
            nonce TEXT    NULL,
            host_name  TEXT  NULL,
            user       TEXT NULL,
            date_stamp TEXT NULL,
            enabled INTEGER
      );";
    $pdo->query($sql);
} catch (\PDOException $e) {
    echo $e->getMessage() . PHP_EOL;
    exit(1);
}

try {
    $sql = "CREATE TABLE IF NOT EXISTS password (
            id   INTEGER PRIMARY KEY AUTOINCREMENT,
            mykey  TEXT    NOT NULL,
            myhash TEXT    NOT NULL
      );";
    $pdo->query($sql);
} catch (\PDOException $e) {
    echo $e->getMessage() . PHP_EOL;
    exit(1);
}

$command = $argv[1] ?? "ls";
$A = $argv[2] ?? "";
$B = $argv[3] ?? "";
$C = $argv[4] ?? "";

function get_status(string $status): string {
    switch(strtolower($status)) {
        case "enabled": case "enable": $status = "1"; break;
        default: $status = "0"; break;
    }
    return $status;
}

function get_id($id) {
    $success = settype($id, "integer");
    if ($success === false) {
        exit(1);
    }
    return $id;
}

switch(strtolower($command)) {
   case "help": case "?": case "-?": case "--help": case "-help": $action = "help"; break; 
   case "show":
       $action = "show";
       $id = get_id($A);
       break;
   case "add": case "new":
       $action = "add";
       $item = $A;
       $cc_pwd = $B;
       break;
   case "remove": case "rm": case "del": case "delete":
       $action = "rm";
       $id = get_id($A);
       break;
   case "update-name":
   case "update-item":
       $action = "update-item";
       $id = get_id($A);
       $item = $B;
       break;
   case "update-pwd":
   case "update-password":
       $action = "update-password";
       $id = get_id($A);
       $item = $B;
       break;
   case "enabled": case "enable":
       $action = "enable";
       $id = get_id($A);
       break;
   case "disabled": case "disable":
       $action = "disable";
       $id = get_id($A);
       break;
   default: $action = "ls"; break;
}

if ($action === "help") {
    echo "To list: ls" . PHP_EOL;
    echo "To get password: show Item#" . PHP_EOL;
    echo "To add: add \"System-NAME\" \"Password\"" . PHP_EOL;
    echo "To remove: rm Item#" . PHP_EOL;
    echo "To update item: update-item Item# \"Updated system-name\"" . PHP_EOL;
    echo "To update pwd: update-password Item# \"New Password\"" . PHP_EOL;
    echo "To mark as enabled: enable Item#" . PHP_EOL;
    echo "To mark as disabled: disable Item#" . PHP_EOL;
    echo "List Order: -desc or -latest" . PHP_EOL;
    echo "List WHERE: -done or -not-done" . PHP_EOL;
    echo "List Pagination: -page # -limit #" . PHP_EOL;
    echo "Use Password: -p mypassword" . PHP_EOL;
    echo "Use alt folder: -dir full_path" . PHP_EOL;
    echo "Use this db file: -dbfile or -d" . PHP_EOL;
    echo "Use this key file: -keyfile or -k" . PHP_EOL;
    exit(0);
}

function get_pwd(string $prompt = "Enter password: ") {
    for($i = 1; $i < $GLOBALS['argc']; $i++) {
        $opt = strtolower($GLOBALS['argv'][$i]);
        if ($opt === "-p" || $opt === "-pass" || $opt === "-password" || $opt === "-pwd") {
           return (isset($GLOBALS['argv'][$i+1])) ? $GLOBALS['argv'][$i+1] : "";
        }
    }
    echo $prompt;
    if(strncasecmp(PHP_OS, 'WIN', 3) === 0) {
       $ret =  stream_get_line(STDIN, 1024, PHP_EOL);
    } else {
       $ret = rtrim( shell_exec("/bin/bash -c 'read -s PW; echo \$PW'") );
    }
    echo PHP_EOL;
    return $ret;
}

try {
    require 'crypto.php';
    $c = new \todo\encryption\crypto();

    $sql = "SELECT COUNT(id) AS c FROM password";
    $pdostmt = $pdo->prepare($sql);
    $pdostmt->execute();
    $count = $pdostmt->fetch(PDO::FETCH_COLUMN);
    $key_file = key_file();
    if (intval($count) == 0) {
       $pwd = get_pwd("Create a password: ");
       if (empty($pwd)) {
           echo "Empty pwd not allowed!";
           exit(1);
       } else {
         $sql = "INSERT INTO password (myhash, mykey) VALUES (:hash, :key)";
         $pdostmt = $pdo->prepare($sql);
         if (! $pdostmt === false) {
            $myhash = password_hash($pwd, PASSWORD_BCRYPT);
            $key = $c->getKey();
            $ekey = openssl_encrypt($key, "AES-128-ECB", $pwd);
            if (!empty($key_file)) {
                if (file_exists($key_file)) {
                    echo "Key already exists..." . PHP_EOL;
                    $pdostmt->execute(["hash"=>$myhash, "key"=>""]);
                    exit(2);
                }
                touch($key_file);
                chmod($key_file, 0660);
            }
            if (empty($key_file) || !is_writable($key_file)) {
                $pdostmt->execute(["hash"=>$myhash, "key"=>$ekey]);
            } else {
                file_put_contents($key_file, $ekey);
                $pdostmt->execute(["hash"=>$myhash, "key"=>""]);                
            }
         }
         $do_encode = true;
       }
    } else {
        $sql = "SELECT myhash, mykey FROM password WHERE id=1 LIMIT 1";
        $pdostmt = $pdo->prepare($sql);
        $pdostmt->execute();
        $row = $pdostmt->fetch(\PDO::FETCH_ASSOC);
        $myhash = $row['myhash'];
        if ($myhash === "none") {
            echo "Error, no password was set!";
            exit(1);
        }
        $do_encode = true;
        $pwd = get_pwd();
        if (! password_verify($pwd, $myhash)) {
            echo "Invalid Password!" . PHP_EOL;
            exit(1);
        }
        if (empty($key_file)) {
            $key = openssl_decrypt($row['mykey'], "AES-128-ECB", $pwd);
        } else {
            if (is_link($key_file) || is_readable($key_file) ) {
                $tmp_key = file_get_contents($key_file);
                if ($tmp_key === false) {
                    echo "Unable to read from key file, so using db instead!" . PHP_EOL;
                    $key = openssl_decrypt($row['mykey'], "AES-128-ECB", $pwd);
                } else {
                    $key = openssl_decrypt($tmp_key, "AES-128-ECB", $pwd);
                    if ($key === false) {
                        $key = openssl_decrypt($row['mykey'], "AES-128-ECB", $pwd);
                    }
                }
            } else {
                echo "Unable to read from key file, so using db instead!" . PHP_EOL;
                echo "Maybe blocked by open_basedir in /opt/profiles/scripts/todo/php_todo.ini" . PHP_EOL;
                $key = openssl_decrypt($row['mykey'], "AES-128-ECB", $pwd);
            }
        }
        if ($key === false) {
            echo "Invalid Key or maybe password!" . PHP_EOL;
        }
    }
} catch (\Exception $ex) {
    echo $ex->getMessage();
    exit(1);
} catch (\PDOException $e) {
    echo $e->getMessage();
    exit(1);
}

function get_dt(string $date_stamp): string {
   $full = false;
   $military_time = false;
   for($i = 1; $i < $GLOBALS['argc']; $i++) {
       $xv = $GLOBALS['argv'][$i];
        $opt = strtolower($xv);
        if ($opt === "-time") {
            $full = true;
        }
        if ($opt == "-24hours") {
            $military_time = true;
        }
   }    
   if ($military_time) {
       $hours = "H:i";
   } else {
       $hours = "h:i A";
   }
   for($i = 1; $i < $GLOBALS['argc']; $i++) {
       $xv = $GLOBALS['argv'][$i];
        $opt = strtolower($xv);
        if ($opt === "-dmy") {
            // Creating timestamp from given date
            $timestamp = strtotime($date_stamp);
            // Creating new date format from that timestamp
            $new_date = date("d-m-Y {$hours}", $timestamp);
            $ymd = explode(" ", $new_date);
            return ($full) ? $new_date : $ymd[0];
        } else if ($opt === "-mdy") {
            $timestamp = strtotime($date_stamp);
            $new_date = date("m/d/Y {$hours}", $timestamp);
            $ymd = explode(" ", $new_date);
            return ($full) ? $new_date : $ymd[0];
        } else if ($opt === "-fancy") {
            $timestamp = strtotime($date_stamp);
            return date("l jS \of F Y h:i:s A", $timestamp);
        }
   }
   $ymd = explode(" ", $date_stamp);
   return ($full) ? $date_stamp : $ymd[0];
}

if ($action === "show") {
    try {
        $sql = "SELECT `item`,`pwd`,`nonce`,`enabled`,`date_stamp` FROM systems_pwd WHERE id=:id LIMIT 1";
        $pdostmt = $pdo->prepare($sql);
        if (! $pdostmt === false) {
            $pdostmt->execute(["id"=>$id]);
        } else {
            echo "INVALID Schema!";
            exit(1);
        }
        $row = $pdostmt->fetch(PDO::FETCH_ASSOC);
        $c->setNonce($row['nonce']);
        $ditem = $c->decode($key, $row['item']);
        $dpwd = $c->decode($key, $row['pwd']);
        $status = ($row['enabled'] == "1") ? "*Active*" : "*Expired*";
        echo "System[{$ditem}]{$status}({$dpwd})\n";
        $time = get_dt($row['date_stamp']);
        echo "Date modified: {$time}\n";
    } catch (\PDOException $e) {
        echo $e->getMessage();
        exit(1);
    }
    exit(0);
}

if ($action === "ls") {
    $limit_no = 8;
    $page = 1;
    $where = "";
    $orderby = " ORDER BY id ASC";
    $limiter = false;
    $limit = "";
    $select = "";
    $full = false;
    $user = false;
    $host = false;
    for($i = 1; $i < $argc; $i++) {
        $opt = strtolower($argv[$i]);
        if ($opt === "-user") {
            $user = true;
            $select .= ", user";
        }
        if ($opt === "-host") {
            $host = true;
            $select .= ", host_name";
        }
        if ($opt === "-enable" || $opt === "-enabled") {
            $where = " WHERE enabled='1' ";
        }
        if ($opt === "-disabled" || $opt === "-disable") {
            $where = " WHERE enabled='0' ";
        }
        if ($opt === "-latest" || $opt === "-desc") {
            $orderby = " ORDER BY id DESC";
        }
        if ($opt === "-page") {
            $limiter = true;
            $page = (isset($argv[$i+1])) ? $argv[$i+1] : 1;
        }
        if ($opt === "-limit") {
            $limiter = true;
            $limit_no = (isset($argv[$i+1])) ? $argv[$i+1] : 8;
        }
    }
    if ($limiter === true) {
        $p = settype($page, "integer");
        $l = settype($limit_no, "integer");
        if ($p === false || $l === false) {
            echo "Invalid page# or limit#";
            exit(1);
        }
        $limit = " LIMIT " . ( ( $page - 1 ) * $limit_no ) . ", $limit_no";
    }
    try {
        $sql = "SELECT id, item, nonce, enabled, date_stamp{$select} FROM systems_pwd {$where}{$orderby}{$limit}";
        $pdostmt = $pdo->prepare($sql);
        if ($pdostmt === false) {
           echo "INVALID Schema!";
           exit(1);
        }
        $pdostmt->execute();
        $rows = $pdostmt->fetchAll(PDO::FETCH_ASSOC);
        foreach($rows as $row) {
            $done = ($row['enabled'] == 1) ? "Enabled" : "Disabled";
            if ($do_encode) {
                $c->setNonce($row['nonce']);
                $item = $c->decode($key, $row['item']);
            } else {
                $item = $row['item'];
            }
            $row_user = ($user) ? $row['user'] . "->" : "";
            $row_host = ($host) ? "@" . $row['host_name'] . "->" : "";
            $time = get_dt($row['date_stamp']);
            echo "[{$row['id']}]{$time}({$done})-{$row_user}{$row_host}{$item}" . PHP_EOL;
        }
    } catch (\PDOException $e) {
        echo $e->getMessage();
        exit(1);
    }
    exit(0);
}

if ($action === "add") {
    try {
        $sql = "INSERT INTO systems_pwd (item, pwd, nonce, host_name, user, date_stamp, enabled) VALUES (:item, :pwd, :nonce, :host, :user, :ds, :enabled)";
        $pdostmt = $pdo->prepare($sql);
        if (! $pdostmt === false) {
            if ($do_encode) {
                $nonce = $c->getNonce();
                $enc_item = $c->encode($key, $item);
                $enc_pwd = $c->encode($key, $cc_pwd);
            }
            $host = gethostname();
            if (function_exists('exec')) {
                $user = exec("whoami");
            } else {
                $user = "unknown";
            }
            $ds = date("Y/m/d H:i");
            $pdostmt->execute(["item"=>$enc_item, "pwd"=>$enc_pwd, "nonce"=>$nonce, "host"=>$host, "user"=>$user, "ds"=>$ds, "enabled"=>"1"]);
        }
    } catch (\Exception $ex) {
        echo $ex->getMessage();
        exit(1);
    } catch (\PDOException $e) {
        echo $e->getMessage();
        exit(1);
    }
    if ($C == "-show") {
       echo $cc_pwd . "\n";
    }
    exit(0);
}

if ($action === "rm") {
    try {
        $sql = "DELETE FROM systems_pwd WHERE id=:id LIMIT 1";
        $pdostmt = $pdo->prepare($sql);
        if (! $pdostmt === false) {
            $pdostmt->execute(["id"=>$id]);
        }
    } catch (\PDOException $e) {
        echo $e->getMessage();
	exit(1);
    }
    exit(0);
}


if ($action === "update-item") {
    try {
        $sql = "UPDATE systems_pwd SET item=:item, nonce=:nonce, user=:user, date_stamp=:ds WHERE id=:id LIMIT 1";
        $pdostmt = $pdo->prepare($sql);
        if (! $pdostmt === false) {
            if ($do_encode) {
                $nonce = $c->getNonce();
                $enc_item = $c->encode($key, $item);
            }
            if (function_exists('exec')) {
                $user = exec("whoami");
            } else {
                $user = "unknown";
            }
            $ds = date("Y/m/d H:i");
            $pdostmt->execute(["item"=>$enc_item, "nonce"=>$nonce, "user"=>$user, "ds"=>$ds, "id"=>$id]);
        }
    } catch (\PDOException $e) {
        echo $e->getMessage();
        exit(1);
    }
    exit(0);
}

if ($action === "update-password") {
    try {
        $sql = "UPDATE systems_pwd SET pwd=:pwd, nonce=:nonce, user=:user, date_stamp=:ds WHERE id=:id LIMIT 1";
        $pdostmt = $pdo->prepare($sql);
        if (! $pdostmt === false) {
            if ($do_encode) {
                $nonce = $c->getNonce();
                $enc_item = $c->encode($key, $item);
            }
            if (function_exists('exec')) {
                $user = exec("whoami");
            } else {
                $user = "unknown";
            }
            $ds = date("Y/m/d H:i");
            $pdostmt->execute(["pwd"=>$enc_item, "nonce"=>$nonce, "user"=>$user, "ds"=>$ds, "id"=>$id]);
        }
    } catch (\PDOException $e) {
        echo $e->getMessage();
        exit(1);
    }
    exit(0);
}

if ($action === "enable") {
    try {
        $sql = "UPDATE systems_pwd SET enabled='1', user=:user, date_stamp=:ds WHERE id=:id LIMIT 1";
        $pdostmt = $pdo->prepare($sql);
        if (! $pdostmt === false) {
            if (function_exists('exec')) {
                $user = exec("whoami");
            } else {
                $user = "unknown";
            }
            $ds = date("Y/m/d H:i");
            $pdostmt->execute(["user"=>$user, "ds"=>$ds, "id"=>$id]);
        }
    } catch (\PDOException $e) {
        echo $e->getMessage();
        exit(1);
    }
    exit(0);
}

if ($action === "disable") {
    try {
        $sql = "UPDATE systems_pwd SET enabled='0', user=:user, date_stamp=:ds WHERE id=:id LIMIT 1";
        $pdostmt = $pdo->prepare($sql);
        if (! $pdostmt === false) {
            if (function_exists('exec')) {
                $user = exec("whoami");
            } else {
                $user = "unknown";
            }
            $ds = date("Y/m/d H:i");
            $pdostmt->execute(["user"=>$user, "ds"=>$ds, "id"=>$id]);
        }
    } catch (\PDOException $e) {
        echo $e->getMessage();
        exit(1);
    }
    exit(0);
}

