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

$run_name = "todo.db";
require 'common.php';

try {
    $sql = "CREATE TABLE IF NOT EXISTS items (
            id   INTEGER PRIMARY KEY AUTOINCREMENT,
            item  TEXT    NOT NULL,
            nonce TEXT    NULL,
            host_name  TEXT  NULL,
            user       TEXT NULL,
            date_stamp TEXT NULL,
            completed INTEGER
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
$B = escapeshellarg($argv[3]) ?? "";

function get_status(string $status): string {
    switch(strtolower($status)) {
        case "done": case "complete": $status = "1"; break;
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
       $status = get_status($B);
       break;
   case "remove": case "rm": case "del": case "delete":
       $action = "rm";
       $id = get_id($A);
       break;
   case "update": 
       $action = "update";
       $id = get_id($A);
       $item = $B;
       break;
   case "complete": case "done": 
       $action = "complete"; 
       $id = get_id($A);
       break;
   case "incomplete": case "not-done": 
       $action = "incomplete"; 
       $id = get_id($A);
       break;
   default: $action = "ls"; break;
}

if ($action === "help") {
    echo "To list: ls" . PHP_EOL;
    echo "To add: add \"Item Info\" incomplete" . PHP_EOL;
    echo "To remove: rm Item#" . PHP_EOL;
    echo "To update: update Item# \"Updated item info\"" . PHP_EOL;
    echo "To mark as complete: complete Item#" . PHP_EOL;
    echo "To mark as incomplete: incomplete Item#" . PHP_EOL;
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
         $sql = "INSERT INTO password (myhash, mykey) VALUES ('none', '')";
         $pdostmt = $pdo->prepare($sql);
         if (! $pdostmt === false) {
            $pdostmt->execute();
         }
         $do_encode = false;
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
        if ($row['myhash'] === "none") {
            $do_encode = false;
        } else {
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
        $sql = "SELECT `item`, `nonce`, `completed`, `date_stamp` FROM items WHERE id=:id LIMIT 1";
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
        $done = ($row['completed'] == 1) ? "Complete" : "Incomplete";
        if ($do_encode) {
            $cipher_text = base64_decode($row['item']);
            $nonce = base64_decode($row['nonce']);
            $item = c::decode_cipher_text($cipher_text, $nonce, $new_key);
        } else {
            $item = $row['item'];
        }
        $time = get_dt($row['date_stamp']);
        echo "[{$id}]{$time}({$done})->" . PHP_EOL;
        echo "{$item}" . PHP_EOL;
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
        if ($opt === "-done" || $opt === "-complete") {
            $where = " WHERE completed='1' ";
        }
        if ($opt === "-not-done" || $opt === "-incomplete" || $opt === "-in-complete") {
            $where = " WHERE completed='0' ";
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
        $sql = "SELECT id, item, nonce, completed, date_stamp{$select} FROM items {$where}{$orderby}{$limit}";
        $pdostmt = $pdo->prepare($sql);
        if ($pdostmt === false) {
           echo "INVALID Schema!";
           exit(1);
        }
        $pdostmt->execute();
        $rows = $pdostmt->fetchAll(PDO::FETCH_ASSOC);
        foreach($rows as $row) {
            $bk = $new_key;
            $done = ($row['completed'] == 1) ? "Complete" : "Incomplete";
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
        $sql = "INSERT INTO items (item, nonce, host_name, user, date_stamp, completed) VALUES (:item, :nonce, :host, :user, :ds, :completed)";
        $pdostmt = $pdo->prepare($sql);
        if (! $pdostmt === false) {
            if ($do_encode) {
                $nonce = c::make_nonce();
                $b_nonce = base64_encode($nonce);
                $enc_item = base64_encode(c::make_cipher_text($item, $nonce, $new_key));
            } else {
                $b_nonce = "";
                $enc_item = $item;
            }
            $host = gethostname();
            if (function_exists('exec')) {
                $user = exec("whoami");
            } else {
                $user = "unknown";
            }
            $ds = date("Y/m/d H:i");
            $pdostmt->execute(["item"=>$enc_item, "nonce"=>$b_nonce, "host"=>$host, "user"=>$user, "ds"=>$ds, "completed"=>$status]);
        }
    } catch (\Exception $ex) {
        echo $ex->getMessage();
        exit(1);
    } catch (\PDOException $e) {
        echo $e->getMessage();
        exit(1);
    }
    exit(0);    
}

if ($action === "rm") {
    try {
        $sql = "DELETE FROM items WHERE id=:id LIMIT 1";
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


if ($action === "update") {
    try {
        $sql = "UPDATE items SET item=:item, nonce=:nonce, user=:user, date_stamp=:ds WHERE id=:id LIMIT 1";
        $pdostmt = $pdo->prepare($sql);
        if (! $pdostmt === false) {
            if ($do_encode) {
                $nonce = c::make_nonce();
                $b_nonce = base64_encode($nonce);
                $enc_item = base64_encode(c::make_cipher_text($item, $nonce, $new_key));
            } else {
                $b_nonce = "";
                $enc_item = $item;
            }
            if (function_exists('exec')) {
                $user = exec("whoami");
            } else {
                $user = "unknown";
            }
            $ds = date("Y/m/d H:i");
            $pdostmt->execute(["item"=>$enc_item, "nonce"=>$b_nonce, "user"=>$user, "ds"=>$ds, "id"=>$id]);
        }
    } catch (\PDOException $e) {
        echo $e->getMessage();
        exit(1);
    }
    exit(0);    
}

if ($action === "complete") {
    try {
        $sql = "UPDATE items SET completed='1', user=:user, date_stamp=:ds WHERE id=:id LIMIT 1";
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

if ($action === "incomplete") {
    try {
        $sql = "UPDATE items SET completed='0', user=:user, date_stamp=:ds WHERE id=:id LIMIT 1";
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
