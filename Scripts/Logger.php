<?php

// Stub for log4php
class Logger {
    function info($msg) {echo "[I] $msg\n";}
    function error($msg) {echo "[E] $msg\n";}
    
    public static function getLogger($name) {
        return new Logger();
    }
}

?>