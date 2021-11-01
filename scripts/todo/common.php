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

ini_set('display_startup_errors',1);
ini_set('display_errors',1);
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

function db_name(string $base_name): string {
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
        return "${base_name}";
    }
    return ($generic) ? "${base_name}" : "{$whoami}_${base_name}";
}

$todo_file = db_name($run_name);

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

function get_pwd(string $prompt = "Enter password: "): ?string {
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
            $full = true;
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

$open_db = db_file();
if (empty($open_db)) {
    $home_dir = home_dir() . $todo_dir;
    if (! is_dir($home_dir)) {
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