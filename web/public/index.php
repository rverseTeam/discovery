<?php
require_once realpath(__DIR__ . '/../vendor/autoload.php');

$routes = [
	['GET', '/miiverse/xml', 'api-miiverse'],
];

$router = new AltoRouter();
$router->addRoutes($routes);
$match = $router->match();

if ($match) {
	$page = realpath(__DIR__ . '/../pages/' . $match['target'] . '.php');
	if (file_exists($page))
		require_once $page;
	else exit;
} else exit;
