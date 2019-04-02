<?php

class CRM_Public_Page_Pledge {

function Json(){
//  header('Content-type:application/json;charset=utf-8');    
  header("Access-Control-Allow-Origin: *");
  $path = explode("/",parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH));
    $pledge = trim(preg_replace('#^[^a-zA-Z0-9\-_]$#', '', array_pop($path)));
    $result = civicrm_api3('Candidate', 'get', [
      'sequential' => 1,
      'pledge' => $pledge,
      'options' => ['public' => 1],
    ]);
    echo json_encode($result);
    CRM_Utils_System::civiExit();
  }
}
