<?php
/**
 * Author of modified works: Robert Strutts
 * Copyright: 2021
 * Site: https://TryingToScale.com
 * GitHub: https://github.com/tryingtoscale/profiles
 * License: MIT
 * todo Version: 1.0
 * 
 * Lib-Sodium Examples here in this file are based from the works of: https://www.zimuel.it/slides/zendcon2018/sodium#/21
 * Original Author: Enrico Zimuel
 * I just wrapped them into nice helper functions...
 */

namespace todo\encryption;

/*
 * Wipe from memory as soon as we're done using it.
 * sodium_memzero($password);
 */

class crypto2 {
 
    /*
     *  ARGON2I Store PWDS safely!!!
     */
    public static function store_pwd_into_hash(string & $password): string {
        $hash = sodium_crypto_pwhash_str(
            $password,
            SODIUM_CRYPTO_PWHASH_OPSLIMIT_INTERACTIVE,
            SODIUM_CRYPTO_PWHASH_MEMLIMIT_INTERACTIVE
        ); // 97 bytes
        sodium_memzero($password);
        return $hash;
    }

    public static function compair_hashed_pwd(string $hash, string & $password): bool {
        $valid = sodium_crypto_pwhash_str_verify($hash, $password);
        sodium_memzero($password);
        return $valid;
    }

    /* 
     * Needed for make_key_from_pwd -- see below:
     */
    public static function make_some_salt() {
        return random_bytes(SODIUM_CRYPTO_PWHASH_SALTBYTES);
    }
    
    /*
     * DERIVE A KEY from a password USING ARGON2I
     * Example: generating a binary key of 32 bytes
    */
    public static function make_key_from_pwd(string & $password, & $salt) {
        $key = sodium_crypto_pwhash(
            32,
            $password,
            $salt,
            SODIUM_CRYPTO_PWHASH_OPSLIMIT_INTERACTIVE,
            SODIUM_CRYPTO_PWHASH_MEMLIMIT_INTERACTIVE
        );
        sodium_memzero($password);
        sodium_memzero($salt);
        // Note: you need to store also the salt to generate the same key from password 
        return $key;
    }
    
    /*
     * Generate key for enc/dec
     */
    public static function make_new_key() {
        return random_bytes(SODIUM_CRYPTO_SECRETBOX_KEYBYTES); // 256 bit
    }

    /*
     *  Generating an encryption nonce for use with make_cipher_text -- see below:
     */
    public static function make_nonce() {
        return random_bytes(SODIUM_CRYPTO_SECRETBOX_NONCEBYTES); // 24 bytes
    }
    
    /* 
     * SYMMETRIC ENCRYPTION
     */
    public static function make_cipher_text(string & $msg, $nonce, & $key) {
        /*
         *  Encrypt
         *  Note: the encryption is always authenticated, you need to store also nonce + ciphertext
         */
        $cipher = sodium_crypto_secretbox($msg, $nonce, $key);
        sodium_memzero($msg);
        sodium_memzero($key);
        return $cipher;
    }

    /* 
     * SYMMETRIC Decrypt
     */
    public static function decode_cipher_text(string $cipher_text, $nonce, & $key) {
        $text = sodium_crypto_secretbox_open($cipher_text, $nonce, $key);
        sodium_memzero($key);
        return $text;
    }

    // -------------------------------------
   
    /* 
     * make_key for make_MAC & verify_mac used below:
     */
    public static function make_key_for_auth() {
        return random_bytes(SODIUM_CRYPTO_SECRETBOX_KEYBYTES); // 256 bit    
    }
    /* 
     * SYMMETRIC AUTHENTICATION
     */
    public static function make_MAC($msg, & $key) {
        /*
         *  Generate the Message Authentication Code
         */
        $MAC = sodium_crypto_auth($msg, $key);
        sodium_memzero($key);
        return $MAC;
    }
    
    /*
     *  Altering $mac or $msg, verification will fail
     */
    public static function verify_mac($mac, & $msg, & $key): bool {
        $valid = sodium_crypto_auth_verify($mac, $msg, $key);
        sodium_memzero($msg);
        sodium_memzero($key);
        return $valid;
    }

    // -------------------------------------
    
    /* 
     * Prevent timing attacks
     */
    public static function is_same(& $a, & $b): bool {
        $same = sodium_compare($a, $b);
        sodium_memzero($a);
        sodium_memzero($b);
        return $same;
    }
    
}

/*
PUBLIC-KEY ENCRYPTION
$aliceKeypair = sodium_crypto_box_keypair();
$alicePublicKey = sodium_crypto_box_publickey($aliceKeypair);
$aliceSecretKey = sodium_crypto_box_secretkey($aliceKeypair);

$bobKeypair = sodium_crypto_box_keypair();
$bobPublicKey = sodium_crypto_box_publickey($bobKeypair); // 32 bytes
$bobSecretKey = sodium_crypto_box_secretkey($bobKeypair); // 32 bytes

$msg = 'Hi Bob, this is Alice!';
$nonce = random_bytes(SODIUM_CRYPTO_BOX_NONCEBYTES); // 24 bytes

$keyEncrypt = $aliceSecretKey . $bobPublicKey;
$ciphertext = sodium_crypto_box($msg, $nonce, $keyEncrypt);

$keyDecrypt = $bobSecretKey . $alicePublicKey;
$plaintext = sodium_crypto_box_open($ciphertext, $nonce, $keyDecrypt);
echo $plaintext === $msg ? 'Success' : 'Error';
 * 
 */

/*
DIGITAL SIGNATURE
$keypair = sodium_crypto_sign_keypair();
$publicKey = sodium_crypto_sign_publickey($keypair); // 32 bytes
$secretKey = sodium_crypto_sign_secretkey($keypair); // 64 bytes

$msg = 'This message is from Alice';
// Sign a message
$signedMsg = sodium_crypto_sign($msg, $secretKey);
// Or generate only the signature (detached mode)
$signature = sodium_crypto_sign_detached($msg, $secretKey); // 64 bytes

// Verify the signed message
$original = sodium_crypto_sign_open($signedMsg, $publicKey);
echo $original === $msg ? 'Signed msg ok' : 'Error signed msg';
// Verify the signature
echo sodium_crypto_sign_verify_detached($signature, $msg, $publicKey) ?
     'Signature ok' : 'Error signature';
 */