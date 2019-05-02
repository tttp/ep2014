<?php

require_once 'CRM/Core/Page.php';
//    <script type="text/javascript" charset="utf-8" src="media/js/TableTools.js"></script>
class CRM_Editor_Page_Candidate extends CRM_Core_Page {
  function run() {
	  CRM_Core_Resources::singleton()
            ->addScriptFile('civicrm.root','js/jquery/jquery.crmEditable.js', 0, 'html-header', FALSE)
            ->addScriptFile('civicrm.root','packages/jquery/plugins/jquery.jeditable.min.js', 0, 'html-header', FALSE)

                ->addScriptFile('org.ep2019.editor', 'TableTools/js/dataTables.tableTools.min.js', 110, 'html-header', FALSE)
//          ->addScriptFile('org.ep2019.editor', 'js/datatable/dataTables.buttons.min.js','html-header', FALSE);

    $datediff = strtotime("2019-05-23") - time();
    $days= floor($datediff/(60*60*24));
    $q = explode ("/",$_GET["q"]);
    if (count($q)>2) {
      $iso=strtoupper($q[2]);
      if (strlen($iso) != 2) {
        die ("not a country, url: /civicrm/candidate/fr");
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
