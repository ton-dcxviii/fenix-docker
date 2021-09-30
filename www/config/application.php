<?php
/**
 * Your base production configuration goes in this file. Environment-specific
 * overrides go in their respective config/environments/{{WP_ENV}}.php file.
 *
 * A good default policy is to deviate from the production config as little as
 * possible. Try to define as much of your configuration in this file as you
 * can.
 */

use Roots\WPConfig\Config;
use function Env\env;

/**
 * Directory containing all of the site's files
 *
 * @var string
 */
$root_dir = dirname(__DIR__);

/**
 * Document Root
 *
 * @var string
 */
$webroot_dir = $root_dir . '/web';

/**
 * Use Dotenv to set required environment variables and load .env file in root
 */
$dotenv = Dotenv\Dotenv::createImmutable($root_dir);
if (file_exists($root_dir . '/.env')) {
    $dotenv->load();
    $dotenv->required(['WP_HOME', 'WP_SITEURL']);
    if (!env('DATABASE_URL')) {
        $dotenv->required(['DB_NAME', 'DB_USER', 'DB_PASSWORD']);
    }
}

/**
 * Set up our global environment constant and load its config first
 * Default: production
 */
define('WP_ENV', env('WP_ENV') ?: 'production');

/**
 * URLs
 */
Config::define('WP_HOME', env('WP_HOME'));
Config::define('WP_SITEURL', env('WP_SITEURL'));

/**
 * Custom Content Directory
 */
Config::define('CONTENT_DIR', '/assets');
Config::define('WP_CONTENT_DIR', $webroot_dir . Config::get('CONTENT_DIR'));
Config::define('WP_CONTENT_URL', Config::get('WP_HOME') . Config::get('CONTENT_DIR'));

/**
 * DB settings
 */
Config::define('DB_NAME', env('DB_NAME'));
Config::define('DB_USER', env('DB_USER'));
Config::define('DB_PASSWORD', env('DB_PASSWORD'));
Config::define('DB_HOST', env('DB_HOST') ?: 'localhost');
Config::define('DB_CHARSET', 'utf8mb4');
Config::define('DB_COLLATE', '');
$table_prefix = env('DB_PREFIX') ?: 'wp_';

if (env('DATABASE_URL')) {
    $dsn = (object) parse_url(env('DATABASE_URL'));

    Config::define('DB_NAME', substr($dsn->path, 1));
    Config::define('DB_USER', $dsn->user);
    Config::define('DB_PASSWORD', isset($dsn->pass) ? $dsn->pass : null);
    Config::define('DB_HOST', isset($dsn->port) ? "{$dsn->host}:{$dsn->port}" : $dsn->host);
}

/**
 * Authentication Unique Keys and Salts
 */
Config::define('AUTH_KEY', env('AUTH_KEY'));
Config::define('SECURE_AUTH_KEY', env('SECURE_AUTH_KEY'));
Config::define('LOGGED_IN_KEY', env('LOGGED_IN_KEY'));
Config::define('NONCE_KEY', env('NONCE_KEY'));
Config::define('AUTH_SALT', env('AUTH_SALT'));
Config::define('SECURE_AUTH_SALT', env('SECURE_AUTH_SALT'));
Config::define('LOGGED_IN_SALT', env('LOGGED_IN_SALT'));
Config::define('NONCE_SALT', env('NONCE_SALT'));

/**
 * WP-Config: File + Upload + API Permissions Settings 
 */

 /** default file permissions */
Config::define('FS_METHOD','direct');
Config::define('FS_CHMOD_DIR', (0775 & ~ umask())); 
Config::define('FS_CHMOD_FILE', (0664 & ~ umask())); 

/** restrict external HTTP (API) requests */
Config::define('WP_HTTP_BLOCK_EXTERNAL', false); 
Config::define('WP_ACCESSIBLE_HOSTS', 'api.wordpress.org');

/** restrict backend file modification */
Config::define('DISALLOW_FILE_EDIT', false);
Config::define('DISALLOW_FILE_MODS', false);

/** restrict file (media) uploads */
Config::define('ALLOW_UNFILTERED_UPLOADS', true);

/**
 * WP-Config: Various Performance Settings
 */

/** optimize WordPress memory */
Config::define('WP_MEMORY_LIMIT', '256M'); 
Config::define('WP_MAX_MEMORY_LIMIT', '512M'); 

/** limit post revisions and drafts */
Config::define('WP_POST_REVISIONS', 3); 
Config::define('AUTOSAVE_INTERVAL', 60); 

/** WP-Cron management */
Config::define('DISABLE_WP_CRON', false); 
Config::define('ALTERNATE_WP_CRON', false); 
Config::define('WP_CRON_LOCK_TIMEOUT', 300); 

/** trash management */
define('MEDIA_TRASH', true); 
define('EMPTY_TRASH_DAYS', 99999999999999999999); 

/**
 * WP-Config: HTML + PHP Optimization Settings
 */

/** keep in mind that Nginx performs Gzip compression on the server-level */
/** using PHP to compress code uses more CPU and slows down parsing speeds (bad) */

/** HTML Settings */
Config::define('DISALLOW_UNFILTERED_HTML', true); 

/** PHP Optimization */
Config::define('ENFORCE_GZIP', false); 
Config::define('COMPRESS_CSS', false); 
Config::define('COMPRESS_SCRIPTS', false); 

/**
 * WordPress Core + Environment Settings
 */

/** Disable Nag Notices */
Config::define('DISABLE_NAG_NOTICES', true);

/**
 * Clear Caches (MU Plugin) Settings
 */

Config::define('CLEAR_CACHES', true); 
Config::define('CLEAR_CACHES_NGINX', true); 
Config::define('CLEAR_CACHES_NGINX_PATH', '/var/www/cache/nginx'); 
Config::define('CLEAR_CACHES_OBJECT', true); 
Config::define('CLEAR_CACHES_OPCACHE', true); 

/**
 * Dashboard Cleanup (MU Plugin) Settings
 */

Config::define('DASHBOARD_CLEANUP', true); 
Config::define('DASHBOARD_CLEANUP_ADD_PLUGIN_TABS', true); 
Config::define('DASHBOARD_CLEANUP_ADD_THEME_TABS', true); 
Config::define('DASHBOARD_CLEANUP_CSS_ADMIN_NOTICE', true); 
Config::define('DASHBOARD_CLEANUP_DISABLE_SEARCH', true); 
Config::define('DASHBOARD_CLEANUP_EVENTS_AND_NEWS', true); 
Config::define('DASHBOARD_CLEANUP_IMPORT_EXPORT_MENU', true); 
Config::define('DASHBOARD_CLEANUP_LINK_MANAGER_MENU', true); 
Config::define('DASHBOARD_CLEANUP_QUICK_DRAFT', true); 
Config::define('DASHBOARD_CLEANUP_THANKS_FOOTER', true); 
Config::define('DASHBOARD_CLEANUP_WELCOME_TO_WORDPRESS', true); 
Config::define('DASHBOARD_CLEANUP_WOOCOMMERCE_CONNECT_STORE', true); 
Config::define('DASHBOARD_CLEANUP_WOOCOMMERCE_FOOTER_TEXT', true); 
Config::define('DASHBOARD_CLEANUP_WOOCOMMERCE_MARKETPLACE_SUGGESTIONS', true); 
Config::define('DASHBOARD_CLEANUP_WOOCOMMERCE_PRODUCTS_BLOCK', true); 
Config::define('DASHBOARD_CLEANUP_WOOCOMMERCE_TRACKER', true); 
Config::define('DASHBOARD_CLEANUP_WP_ORG_SHORTCUT_LINKS', true);  

/**
 * Delete Expired Transients (MU Plugin) Settings
 */

define('DELETE_EXPIRED_TRANSIENTS', true); // ss = true


/**
 * Custom Settings
 */
Config::define('CUSTOM_FUNCTIONS', true);
Config::define('AUTOMATIC_UPDATER_DISABLED', true);
Config::define('DISABLE_WP_CRON', env('DISABLE_WP_CRON') ?: false);





/**
 * Debugging Settings
 */
Config::define('WP_DEBUG_DISPLAY', false);
Config::define('WP_DEBUG_LOG', env('WP_DEBUG_LOG') ?? false);
Config::define('SCRIPT_DEBUG', false);
ini_set('display_errors', '0');

/**
 * Allow WordPress to detect HTTPS when used behind a reverse proxy or a load balancer
 * See https://codex.wordpress.org/Function_Reference/is_ssl#Notes
 */
if (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {
    $_SERVER['HTTPS'] = 'on';
}

$env_config = __DIR__ . '/environments/' . WP_ENV . '.php';

if (file_exists($env_config)) {
    require_once $env_config;
}

Config::apply();

/**
 * Bootstrap WordPress
 */
if (!defined('ABSPATH')) {
    define('ABSPATH', $webroot_dir . '/wp/');
}
