<?php

require_once 'CRM/Core/Page.php';

class CRM_Editor_Page_Party extends CRM_Core_Page {
  function run() {
    // Example: Set the page-title dynamically; alternatively, declare a static title in xml/Menu/*.xml
    CRM_Utils_System::setTitle(ts('Party'));

   if (array_key_exists ("country",$_GET))  {
    $this->assign("country", $_GET["country"]);

   }
    CRM_Core_Resources::singleton()
     ->addScriptFile('civicrm.root','js/jquery/jquery.crmEditable.js', -9998, 'html-header', FALSE)
     ->addScriptFile('org.ep2019.editor', 'js/datatable/media/js/jquery.dataTables.js', -9998, 'html-header', FALSE);

//    ->addScriptFile('org.ep2019.editor', 'js/datatable/media/js/jquery.dataTables.js', 0, 'html-header', FALSE);

    parent::run();
  }
}
