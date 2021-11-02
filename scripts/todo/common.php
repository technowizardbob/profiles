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

ini_set('display_startup_errors', 1);
ini_set('display_errors', 1);
error_reporting(-1);

const home_dir = 0;
const install_dir = 1;
const use_default = home_dir;
$todo_dir = "/.todo";

require 'crypto2.php';

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

    if (empty($_SERVER['REMOTE_ADDR']) and!isset($_SERVER['HTTP_USER_AGENT']) and count($_SERVER['argv']) > 0) {
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
    for ($i = 1; $i < $GLOBALS['argc']; $i++) {
        $opt = strtolower($GLOBALS['argv'][$i]);
        if ($opt === "-keyfile" || $opt === "-k") {
            $key_file = (isset($GLOBALS['argv'][$i + 1])) ? $GLOBALS['argv'][$i + 1] : "";
            if (!empty($key_file)) {
                return $key_file;
            }
        }
    }
    return "";
}

function db_file(): string {
    for ($i = 1; $i < $GLOBALS['argc']; $i++) {
        $opt = strtolower($GLOBALS['argv'][$i]);
        if ($opt === "-dbfile" || $opt === "-d") {
            $db_file = (isset($GLOBALS['argv'][$i + 1])) ? $GLOBALS['argv'][$i + 1] : "";
            if (!empty($db_file)) {
                return $db_file;
            }
        }
    }
    return "";
}

function db_name(string $base_name): string {
    $generic = true;
    for ($i = 1; $i < $GLOBALS['argc']; $i++) {
        $opt = strtolower($GLOBALS['argv'][$i]);
        if ($opt === "-usernamed" || $opt === "-u") {
            $generic = false;
        }
        if ($opt === "-who") {
            $whoami = (isset($GLOBALS['argv'][$i + 1])) ? $GLOBALS['argv'][$i + 1] : "";
        }
    }
    if (empty($whoami)) {
        return "${base_name}";
    }
    return ($generic) ? "${base_name}" : "{$whoami}_${base_name}";
}

$todo_file = db_name($run_name);

function home_dir(): string {
    $use_home = use_default;
    for ($i = 1; $i < $GLOBALS['argc']; $i++) {
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
            $dir = (isset($GLOBALS['argv'][$i + 1])) ? $GLOBALS['argv'][$i + 1] : "";
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
        if (strncasecmp(PHP_OS, 'WIN', 3) === 0) {
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

function get_pwd(string $prompt = "Enter password: "): ?string {
    for ($i = 1; $i < $GLOBALS['argc']; $i++) {
        $opt = strtolower($GLOBALS['argv'][$i]);
        if ($opt === "-p" || $opt === "-pass" || $opt === "-password" || $opt === "-pwd") {
            return (isset($GLOBALS['argv'][$i + 1])) ? $GLOBALS['argv'][$i + 1] : "";
        }
    }
    echo $prompt;
    if (strncasecmp(PHP_OS, 'WIN', 3) === 0) {
        $ret = stream_get_line(STDIN, 1024, PHP_EOL);
    } else {
        $ret = rtrim(shell_exec("/bin/bash -c 'read -s PW; echo \$PW'"));
    }
    echo PHP_EOL;
    return $ret;
}

function get_dt(string $date_stamp): string {
    $full = false;
    $military_time = false;
    for ($i = 1; $i < $GLOBALS['argc']; $i++) {
        $xv = $GLOBALS['argv'][$i];
        $opt = strtolower($xv);
        if ($opt === "-time") {
            $full = true;
        }
        if ($opt == "-24hours") {
            $full = true;
            $military_time = true;
        }
    }
    if ($military_time) {
        $hours = "H:i";
    } else {
        $hours = "h:i A";
    }
    for ($i = 1; $i < $GLOBALS['argc']; $i++) {
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

function update_db(bool $require_password) {
    try {
        $sql = "SELECT COUNT(id) AS c FROM password";
        $pdostmt = $GLOBALS['pdo']->prepare($sql);
        $pdostmt->execute();
        $count = $pdostmt->fetch(\PDO::FETCH_COLUMN);
        if (intval($count) == 0) {
            $pwd = get_pwd("Create a password: ");
            if (empty($pwd)) {
                if ($require_password) {
                    echo "Empty pwd not allowed!";
                    exit(1);
                }
                $sql = "INSERT INTO password (myhash, mykey) VALUES ('none', '')";
                $pdostmt = $GLOBALS['pdo']->prepare($sql);
                if (!$pdostmt === false) {
                    $pdostmt->execute();
                }
            } else {
                save_keys($pwd);
            }
            echo "Init db done...successfully";
            exit(0);
        }
    } catch (\Exception $ex) {
        echo $ex->getMessage();
        exit(1);
    } catch (\PDOException $e) {
        echo $e->getMessage();
        exit(1);
    }
}

function save_keys(string & $pwd) {
    try {
        $cp = $pwd;
        $key_file = key_file();
        $sql = "INSERT INTO password (myhash, mykey) VALUES (:hash, :key)";
        $pdostmt = $GLOBALS['pdo']->prepare($sql);
        if (!$pdostmt === false) {
            $myhash = base64_encode(c::store_pwd_into_hash($pwd));
            $salt = c::make_some_salt();
            $bsalt = base64_encode($salt);
            $new_key = base64_encode(c::make_key_from_pwd($cp, $salt));
            $a_keys = ['newkey' => $new_key, 'salt' => $bsalt];
            $key = base64_encode(json_encode($a_keys));
            if (!empty($key_file)) {
                if (file_exists($key_file)) {
                    echo "Key already exists..." . PHP_EOL;
                    $pdostmt->execute(["hash" => $myhash, "key" => ""]);
                    exit(2);
                }
                touch($key_file);
                chmod($key_file, 0660);
            }
            if (empty($key_file) || !is_writable($key_file)) {
                $pdostmt->execute(["hash" => $myhash, "key" => $key]);
            } else {
                file_put_contents($key_file, $key);
                $pdostmt->execute(["hash" => $myhash, "key" => ""]);
            }
        }
    } catch (\Exception $ex) {
        echo $ex->getMessage();
        exit(1);
    } catch (\PDOException $e) {
        echo $e->getMessage();
        exit(1);
    }
}

function fetch_keys(bool $require_password) {
    try {
        $key_file = key_file();
        $sql = "SELECT myhash, mykey FROM password WHERE id=1 LIMIT 1";
        $pdostmt = $GLOBALS['pdo']->prepare($sql);
        $pdostmt->execute();
        $row = $pdostmt->fetch(\PDO::FETCH_ASSOC);
        if ($row === false || $row['myhash'] === "none") {
            echo "Error, no password was set!";
            exit(1);
        }
        $myhash = base64_decode($row['myhash']);
        $pwd = get_pwd();
        $copy_of_pwd = $pwd;
        if (!empty($pwd)) {
            if (!c::compair_hashed_pwd($myhash, $pwd)) {
                echo "Invalid Password!" . PHP_EOL;
                exit(1);
            }
        } else {
            if ($require_password) {
                echo "Empty pwd not allowed!";
                exit(1);
            }
        }

        $new_key = false;
        if (!empty($key_file) && (is_readable($key_file) || is_link($key_file) )) {
            $mykey = json_decode(base64_decode(file_get_contents($key_file)), true);
            if ($mykey === false) {
                echo "Unable to fetch key from file given!";
                exit(1);
            } else {
                $b = $mykey['salt'] ?? false;
                $c = $mykey['newkey'] ?? false;
                if ($b === false || $c === false) {
                    echo "Unable to find key/salt!";
                    exit(1);
                }
                $salt = base64_decode($b);
                $new_key = base64_decode($c);
            }
        } else {
            $mykey = json_decode(base64_decode($row['mykey']), true);
            $b = $mykey['salt'] ?? false;
            $c = $mykey['newkey'] ?? false;
            if ($b === false || $c === false) {
                echo "Unable to fetch key/salt from db!";
                exit(1);
            }
            $salt = base64_decode($b);
            $new_key = base64_decode($c);
        }
        if ($new_key === false || empty($new_key) || $salt === false || empty($salt)) {
            echo "Invalid Key/Salt or maybe password!" . PHP_EOL;
            exit(1);
        }
        return ['salt' => $salt, 'new_key' => $new_key, 'pwd' => $copy_of_pwd];
    } catch (\Exception $ex) {
        echo $ex->getMessage();
        exit(1);
    } catch (\PDOException $e) {
        echo $e->getMessage();
        exit(1);
    }
}

$open_db = db_file();
if (empty($open_db)) {
    $home_dir = home_dir() . $todo_dir;
    if (!is_dir($home_dir)) {
        $s = mkdir($home_dir);
        if ($s === false) {
            echo "Unable to create folder: {$home_dir}" . PHP_EOL;
            exit(1);
        }
    }
    $open_db = "{$home_dir}/{$todo_file}";
}

try {
    $pdo = new PDO("sqlite:{$open_db}");
} catch (PDOException $e) {
    echo $e->getMessage() . PHP_EOL;
    exit(1);
}