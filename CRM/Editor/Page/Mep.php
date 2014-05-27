<?php
require_once 'CRM/Core/Page.php';
//    <script type="text/javascript" charset="utf-8" src="media/js/TableTools.js"></script>
class CRM_Editor_Page_Mep extends CRM_Core_Page {
  function run() {
     CRM_Core_Resources::singleton()
      ->addScriptFile('org.ep2014.editor', 'TableTools/js/dataTables.tableTools.min.js', 110, 'html-header', FALSE);

    $datediff = time() - strtotime("2014-05-25");
    $days= floor($datediff/(60*60*24));
    $q = explode ("/",$_GET["q"]);
    if (count($q)>2) {
      $iso=strtoupper($q[2]);
      if (strlen($iso) != 2) {
        die ("not a country, url: /civicrm/mep/fr");
      }
      $country=civicrm_api3("country","getsingle",array("iso_code" =>$iso));
      $candidates = civicrm_api3("Candidate","get",array("country"=>$country["id"],"elected"=>1));
      $filter = "in ". $country["name"];
    } else {
      $filter = "";
      $candidates = civicrm_api3("Candidate","get", array("elected"=>1));
    }
    $this->assign("candidates", json_encode($candidates["values"]));
    CRM_Utils_System::setTitle ($candidates["count"]." known meps $filter. $days days ago.");
    
    parent::run();
  }
}
