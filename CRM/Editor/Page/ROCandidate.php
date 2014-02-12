<?php

require_once 'CRM/Core/Page.php';

class CRM_Editor_Page_ROCandidate extends CRM_Core_Page {
  function run() {
     CRM_Core_Resources::singleton()
      ->addScriptFile('org.ep2014.editor', 'TableTools/js/dataTables.tableTools.min.js', 110, 'html-header', FALSE);

     $datediff = strtotime("2014-05-22") - time();
     $days= floor($datediff/(60*60*24));
    CRM_Utils_System::setTitle (" known candidates. $days days to go.");
    parent::run();
  }
}
