<?php

class CRM_Public_Page_Pledge {

function Json(){
  header('Content-type:application/json;charset=utf-8');    
  header("Access-Control-Allow-Origin: *");
    $result = civicrm_api3('Candidate', 'get', [
      'sequential' => 1,
      'pledge' => 'ILGA',
      'options' => ['public' => 1],
    ]);
    echo json_encode($result);
    CRM_Utils_System::civiExit();
  }
}
