<?php

require_once 'CRM/Core/Page.php';
//    <script type="text/javascript" charset="utf-8" src="media/js/TableTools.js"></script>
class CRM_Editor_Page_Candidate extends CRM_Core_Page {
  function run() {
     CRM_Core_Resources::singleton()
      ->addScriptFile('org.ep2014.editor', 'TableTools/js/dataTables.tableTools.min.js', 110, 'html-header', FALSE);

    $datediff = strtotime("2014-05-22") - time();
    $days= floor($datediff/(60*60*24));
    CRM_Utils_System::setTitle (" known candidates. $days days to go.");
    parent::run();
  }
}
