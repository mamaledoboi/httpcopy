  # vim:set ft= ts=4 sw=4 et:

my @skip;
BEGIN {
    if ($ENV{LD_PRELOAD} =~ /\bmockeagain\.so\b/) {
        @skip = (skip_all => 'too slow in mockeagain mode')
    }
}

use Test::Nginx::Socket @skip;
use Cwd qw(cwd);

repeat_each(1);
#repeat_each(10);

plan tests => repeat_each() * (3 * blocks());

my $pwd = cwd();

our $HttpConfig = qq{
    resolver \$TEST_NGINX_RESOLVER;
    lua_package_path "$pwd/lib/?.lua;;";
    lua_package_cpath "/usr/local/openresty-debug/lualib/?.so;/usr/local/openresty/lualib/?.so;;";
};

$ENV{TEST_NGINX_RESOLVER} = '8.8.8.8';
$ENV{TEST_NGINX_MYSQL_PORT} ||= 3306;
$ENV{TEST_NGINX_MYSQL_HOST} ||= '127.0.0.1';
$ENV{TEST_NGINX_MYSQL_PATH} ||= '/var/run/mysql/mysql.sock';

#log_level 'warn';

#no_long_string();
#no_diff();
no_shuffle();

run_tests();

__DATA__

=== TEST 1: set charset utf8 通过mysql 状态测试
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua '';
    }
--- request
GET /t
--- response_body eval
'connected to mysql.
result: [{"Value":"utf8","Variable_name":"character_set_client"}]' . "\n"
--- no_error_log
[error]



