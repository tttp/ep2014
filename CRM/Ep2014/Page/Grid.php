<?php

class CRM_Ep2014_Page_Grid extends CRM_Core_Page {
  function run() {
   CRM_Core_Resources::singleton()
   ->addScript ("jQuery = cj;")
   ->addScriptFile('org.ep2014.editor', 'packages/SlickGrid/lib/jquery.event.drag-2.2.js', 110, 'html-header', FALSE)
    ->addScriptFile('org.ep2014.editor', 'packages/SlickGrid/slick.grid.js', 110, 'html-header', FALSE)
    ->addScriptFile('org.ep2014.editor', 'packages/SlickGrid/slick.core.js', 110, 'html-header', FALSE)
    ->addScriptFile('org.ep2014.editor', 'packages/SlickGrid/slick.formatters.js', 110, 'html-header', FALSE)
    ->addScriptFile('org.ep2014.editor', 'packages/SlickGrid/slick.editors.js', 110, 'html-header', FALSE)
    ->addScriptFile('org.ep2014.editor', 'packages/SlickGrid/plugins/slick.rowselectionmodel.js', 110, 'html-header', FALSE)
    ->addScriptFile('org.ep2014.editor', 'packages/SlickGrid/slick.dataview.js', 110, 'html-header', FALSE)
    ->addScriptFile('org.ep2014.editor', 'packages/SlickGrid/controls/slick.pager.js', 110, 'html-header', FALSE)
    ->addScriptFile('org.ep2014.editor', 'packages/SlickGrid/controls/slick.columnpicker.js', 110, 'html-header', FALSE)
    ->addScriptFile('org.ep2014.editor', 'packages/SlickGrid/plugins/slick.autotooltips.js', 110, 'html-header', FALSE)
    ->addScriptFile('org.ep2014.editor', 'js/grid.js', 110, 'html-header', FALSE)
    ->addScriptFile('civicrm', 'js/jquery/jquery.crmeditable.js', 110, 'html-header', FALSE)
    ->addStyleFile('org.ep2014.editor', 'packages/SlickGrid/slick.grid.css', 12)
    ->addStyleFile('org.ep2014.editor', 'packages/SlickGrid/controls/slick.pager.css', 12)


;



//    ->addStyleFile('eu.tttp.civisualize', 'js/dc/dc.css');


    // Example: Set the page-title dynamically; alternatively, declare a static title in xml/Menu/*.xml
//    CRM_Utils_System::setTitle(ts('Ep2014_Grid'));

    parent::run();
  }
}
