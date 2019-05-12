<?php

class CRM_Public_Page_Candidate {

function Email(){
  header('Content-type:application/json;charset=utf-8');    
  header("Access-Control-Allow-Origin: *");
  $cid= 0 + $_REQUEST['id'];
  if (!$cid) 
    http_response_code(400);
  $sql = "SELECT email from civicrm_email m join civicrm_contact c where c.id=m.contact_id and m.is_primary=1 and c.is_deleted=0 and c.contact_sub_type like '%Candidate%' and c.id=%1";
    $dao = CRM_Core_DAO::executeQuery($sql, array (
      1=>array ($cid,"Integer")
    ));
  $dao->fetch();
  $email = $dao->toArray();
  if (empty($email))
	  http_response_code(400);
  echo json_encode(array("email"=>$email["email"]));
  CRM_Utils_System::civiExit();
}

function Json(){
  header('Content-type:application/json;charset=utf-8');    
  header("Access-Control-Allow-Origin: *");
  $path = explode("/",parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH));
  $country = trim(preg_replace('#^[^a-zA-Z0-9\-_]$#', '', array_pop($path)));
  if ($country =="candidate" || $country == ""){
    $country = civicrm_api3('Country', 'get', ['sequential' => 1,'iso_code' => ip2country_get_country(ip_address())])["id"];
  }
    $result = civicrm_api3('Candidate', 'get', [
      'sequential' => 1,
      'country' => $country,
      'options' => ['public' => 1],
    ]);
    echo json_encode($result);
    CRM_Utils_System::civiExit();
  }
}
