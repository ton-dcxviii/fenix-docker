<?php
/**
 * Configuration overrides for WP_ENV === 'production'
 */

use Roots\WPConfig\Config;

Config::define('WP_DEBUG', false);
Config::define('WP_DEBUG_DISPLAY', false);
Config::define('SCRIPT_DEBUG', false);

ini_set('display_errors', '0');

// Enable plugin and theme updates and installation from the admin
Config::define('DISALLOW_FILE_EDIT', false);
Config::define('DISALLOW_FILE_MODS', false);
Config::define('FS_METHOD','direct');