<?php
$xml = new SimpleXMLElement('<?xml version="1.0" encoding="UTF-8" ?><result/>');

$xml->addChild("has_error", 0);
$xml->addChild("version", 1);
$endpoint = $xml->addChild("endpoint");
$endpoint->addChild("host", $_SERVER["HTTP_HOST"]);
$endpoint->addChild("api_host", 'API_HOST');
$endpoint->addChild("portal_host", 'PORTAL_HOST');
$endpoint->addChild("n3ds_host", '3DS_HOST');

$ds = $xml->asXML();
header('Content-Type: application/xml');

// Did you know? nginx strips the content length header!
header("Content-Length: " . strlen($ds));

echo $ds;
