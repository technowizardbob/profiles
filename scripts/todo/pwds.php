<?php
/**
 * Author: Robert Strutts
 * Copyright: 2021
 * Site: https://TryingToScale.com
 * GitHub: https://github.com/tryingtoscale/profiles
 * License: MIT
 * Packages: todo/pwds
 * Version: 1.0
 */
use \todo\encryption\crypto2 as c;

$run_name = 'pwds.db';
require 'common.php';

try {
    $sql = "CREATE TABLE IF NOT EXISTS systems_pwd (
            id   INTEGER PRIMARY KEY AUTOINCREMENT,
            item  TEXT    NOT NULL,
            pwd   TEXT    NOT NULL,
            nonce TEXT    NULL,
            host_name  TEXT  NULL,
            user       TEXT NULL,
            date_stamp TEXT NULL,
            expires_on TEXT NULL,
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
       $item = escapeshellarg($A);
       $cc_pwd = escapeshellarg($B);
       break;
   case "remove": case "rm": case "del": case "delete":
       $action = "rm";
       $id = get_id($A);
       break;
   case "update-name":
   case "update-item":
       $action = "update-item";
       $id = get_id($A);
       $item = escapeshellarg($B);
       break;
   case "update-pwd":
   case "update-password":
       $action = "update-password";
       $id = get_id($A);
       $item = escapeshellarg($B);
       break;
   case "enabled": case "enable":
       $action = "enable";
       $id = get_id($A);
       break;
   case "disabled": case "disable":
       $action = "disable";
       $id = get_id($A);
       break;
   case "expires": case "expires-on":
       $action = "expires";
       $id = get_id($A);
       $expires = escapeshellarg($B);
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
    echo "To set expires on date: expires Item# \"Expires on Date\"" . PHP_EOL;
    echo "List Order: -desc or -latest" . PHP_EOL;
    echo "List WHERE: -done or -not-done" . PHP_EOL;
    echo "List Pagination: -page # -limit #" . PHP_EOL;
    echo "Use Password: -p mypassword" . PHP_EOL;
    echo "Use alt folder: -dir full_path" . PHP_EOL;
    echo "Use this db file: -dbfile or -d" . PHP_EOL;
    echo "Use this key file: -keyfile or -k" . PHP_EOL;
    exit(0);
}

try {
    $sql = "SELECT COUNT(id) AS c FROM password";
    $pdostmt = $pdo->prepare($sql);
    $pdostmt->execute();
    $count = $pdostmt->fetch(PDO::FETCH_COLUMN);
    $key_file = key_file();
    if (intval($count) == 0) {
       $pwd = get_pwd("Create a password: ");
       $cp = $pwd;
       if (empty($pwd)) {
           echo "Empty pwd not allowed!";
           exit(1);
       } else {
         $sql = "INSERT INTO password (myhash, mykey) VALUES (:hash, :key)";
         $pdostmt = $pdo->prepare($sql);
         if (! $pdostmt === false) {
            $myhash = base64_encode(c::store_pwd_into_hash($pwd));
            $salt = c::make_some_salt();
            $new_key = base64_encode(c::make_key_from_pwd($cp, $salt));
            $a_keys = ['newkey'=>$new_key,'salt'=>$salt];
            $key = base64_encode(json_encode($a_keys));
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
                $pdostmt->execute(["hash"=>$myhash, "key"=>$key]);
            } else {
                file_put_contents($key_file, $key);
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
        $myhash = base64_decode($row['myhash']);
        $pwd = get_pwd();
        $copy_of_pwd = $pwd;
        if (! c::compair_hashed_pwd($myhash, $pwd)) {
            echo "Invalid Password!" . PHP_EOL;
            exit(1);
        }
            if (empty($key_file) || !is_readable($key_file)) {
                $mykey = json_decode(base64_decode($row['mykey']), true);
                $salt = base64_decode($mykey['salt']);
                $new_key = base64_decode($mykey['newkey']);
        } else {
            if (is_link($key_file) || is_readable($key_file) ) {
                    $mykey = json_decode(base64_decode(file_get_contents($key_file)), true);
                    if ($mykey === false) {
                        echo "Unable to read from key file, so using db instead!" . PHP_EOL;
                        $mykey = json_decode(base64_decode($row['mykey']), true);
                        $salt = base64_decode($mykey['salt']);
                        $new_key = base64_decode($mykey['newkey']);
                } else {
                        $salt = base64_decode($mykey['salt']);
                        $new_key = base64_decode($mykey['newkey']);
                    }
            } else {
                $mykey = json_decode(base64_decode($row['mykey']), true);
                $salt = base64_decode($mykey['salt']);
                $new_key = base64_decode($mykey['newkey']);
                echo "Unable to read from key file, so using db instead!" . PHP_EOL;
                echo "Maybe blocked by open_basedir in /opt/profiles/scripts/todo/php_todo.ini" . PHP_EOL;
            }
        }
        if ($new_key === false) {
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

if ($action === "show") {
    try {
        $sql = "SELECT `item`,`pwd`,`nonce`,`enabled`,`date_stamp`,`expires_on` FROM systems_pwd WHERE id=:id LIMIT 1";
        $pdostmt = $pdo->prepare($sql);
        if (! $pdostmt === false) {
            $pdostmt->execute(["id"=>$id]);
        } else {
            echo "INVALID Schema!";
            exit(1);
        }
        $row = $pdostmt->fetch(PDO::FETCH_ASSOC);
        if ($row === false) {
            echo "Does not Exist!";
            exit(1);
        }
        $item = base64_decode($row['item']);
        $pwd = base64_decode($row['pwd']);
        $nonce = base64_decode($row['nonce']);
        $nnonce = $nonce;
        $kkey = $new_key;
        $ditem = c::decode_cipher_text($item, $nonce, $new_key);
        $dpwd = c::decode_cipher_text($pwd, $nnonce, $kkey);
        $status = ($row['enabled'] == "1") ? "*Active*" : "*Expired*";
        echo "System[{$ditem}]{$status}({$dpwd})\n";
        $time = get_dt($row['date_stamp']);
        echo "Date modified: {$time}\n";
        echo "Expires on: {$row['expires_on']}\n";
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
            $bk = $new_key;
            $done = ($row['enabled'] == 1) ? "Enabled" : "Disabled";
            if ($do_encode) {
                $cipher_text = base64_decode($row['item']);
                $nonce = base64_decode($row['nonce']);
                $item = c::decode_cipher_text($cipher_text, $nonce, $bk);
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
                $nonce = c::make_nonce();
                $b_nonce = base64_encode($nonce);
                $ckey = $new_key;
                $enc_item = base64_encode(c::make_cipher_text($item, $nonce, $new_key));
                $enc_pwd = base64_encode(c::make_cipher_text($cc_pwd, $nonce, $ckey));
            }
            $host = gethostname();
            if (function_exists('exec')) {
                $user = exec("whoami");
            } else {
                $user = "unknown";
            }
            $ds = date("Y/m/d H:i");
            $pdostmt->execute(["item"=>$enc_item, "pwd"=>$enc_pwd, "nonce"=>$b_nonce, "host"=>$host, "user"=>$user, "ds"=>$ds, "enabled"=>"1"]);
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
                $nonce = c::make_nonce();
                $enc_item = base64_encode(c::make_cipher_text($item, $nonce, $new_key));
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
                $nonce = c::make_nonce();
                $enc_item = base64_encode(c::make_cipher_text($item, $nonce, $new_key));
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

if ($action === "expires") {
    try {
        $sql = "UPDATE systems_pwd SET expires_on=:expires WHERE id=:id LIMIT 1";
        $pdostmt = $pdo->prepare($sql);
        if (! $pdostmt === false) {
            $pdostmt->execute(["expires"=>$expires, "id"=>$id]);
        }
    } catch (\PDOException $e) {
        echo $e->getMessage();
        exit(1);
    }
    exit(0);
}
