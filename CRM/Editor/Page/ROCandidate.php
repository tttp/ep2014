<?php

require_once 'CRM/Core/Page.php';

class CRM_Editor_Page_ROCandidate extends CRM_Core_Page {
  function run() {
     CRM_Core_Resources::singleton()
      ->addScriptFile('org.ep2019.editor', 'TableTools/js/dataTables.tableTools.min.js', 110, 'html-header', FALSE);

    $datediff = strtotime("2014-05-22") - time();
    $days= floor($datediff/(60*60*24));
    $q = explode ("/",$_GET["q"]);
    if (count($q)>3) {
      $iso=strtoupper($q[3]);
      if (strlen($iso) != 2) {
        die ("not a country, url: /civicrm/candidate/view/fr");
      }
      $country=civicrm_api3("country","getsingle",array("iso_code" =>$iso));
      $candidates = civicrm_api3("Candidate","get",array("country"=>$country["id"]));
      $filter = "in ". $country["name"];
    } else {
      $filter = "";
      $candidates = civicrm_api3("Candidate","get");
    }
    $this->assign("candidates", json_encode($candidates["values"]));
    CRM_Utils_System::setTitle ($candidates["count"]." known candidates $filter. $days days to go.");
    parent::run();
  }
}
