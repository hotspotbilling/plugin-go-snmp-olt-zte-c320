<?php

register_menu("OLT ZTE C320 Go", true, "go_zte_c320", 'AFTER_SETTINGS', 'glyphicon glyphicon-modal-window', '', '', ['Admin', 'SuperAdmin']);

function go_zte_c320()
{
    global $ui, $config, $admin;
    _admin();

    if (empty($config['go_zte_c320_urls'])) {
        r2(getUrl('plugin/go_zte_c320_config'), 'e', 'Please configure first');
    }
    $servers = [];
    $urls = explode("\n", str_replace("\r","",$config['go_zte_c320_urls']));
    foreach ($urls as $url) {
        // get domain from url
        $servers[] = parse_url($url, PHP_URL_HOST);
    }
    $server = _get('server', 0);
    $ui->assign('server', $server);
    $ui->assign('servers', $servers);
    $ui->assign('serverscount', count($servers));
    $ui->assign('_title', 'OLT ZTE C320 Go');
    $ui->assign('_title', 'OLT ZTE C320 Go');
    $ui->assign('_system_menu', 'plugin/go_zte_c320');
    $admin = Admin::_info();
    $ui->assign('_admin', $admin);
    $ui->display('go_zte_c320.tpl');
}

function go_zte_c320_config()
{
    global $ui;
    _admin();

    if (!empty(_post('go_zte_c320_urls')) || !empty(_post('go_zte_c320_urls'))) {
        $d = ORM::for_table('tbl_appconfig')->where('setting', 'go_zte_c320_urls')->find_one();
        if ($d) {
            $d->value = _post('go_zte_c320_urls');
            $d->save();
        } else {
            $d = ORM::for_table('tbl_appconfig')->create();
            $d->setting = 'go_zte_c320_urls';
            $d->value = _post('go_zte_c320_urls');
            $d->save();
        }
        r2(getUrl('plugin/go_zte_c320_config'), 's', 'Configuration saved');
    }
    $ui->assign('_title', 'Server OLT ZTE C320 Go');
    $ui->assign('_system_menu', 'plugin/go_zte_c320');
    $admin = Admin::_info();
    $ui->assign('_admin', $admin);
    $ui->assign('menu', 'config');
    $ui->display('go_zte_c320.tpl');
}

function go_zte_c320_api()
{
    global $ui, $config, $req, $routes;
    $server = $routes[3];
    $uri = implode("/", array_slice($routes, 4));
    $urls = explode("\n", str_replace("\r","",$config['go_zte_c320_urls']));
    $apiServer = $urls[$server];
    header('Content-Type: application/json');
    $result = Http::getData("$apiServer/$uri");
    die($result);
}