<?php

require_once 'editor.civix.php';

/**
 * Implementation of hook_civicrm_config
 */
function editor_civicrm_config(&$config) {
  _editor_civix_civicrm_config($config);
}

/**
 * Implementation of hook_civicrm_xmlMenu
 *
 * @param $files array(string)
 */
function editor_civicrm_xmlMenu(&$files) {
  _editor_civix_civicrm_xmlMenu($files);
}

/**
 * Implementation of hook_civicrm_install
 */
function editor_civicrm_install() {
  return _editor_civix_civicrm_install();
}

/**
 * Implementation of hook_civicrm_uninstall
 */
function editor_civicrm_uninstall() {
  return _editor_civix_civicrm_uninstall();
}

/**
 * Implementation of hook_civicrm_enable
 */
function editor_civicrm_enable() {
  return _editor_civix_civicrm_enable();
}

/**
 * Implementation of hook_civicrm_disable
 */
function editor_civicrm_disable() {
  return _editor_civix_civicrm_disable();
}

/**
 * Implementation of hook_civicrm_upgrade
 *
 * @param $op string, the type of operation being performed; 'check' or 'enqueue'
 * @param $queue CRM_Queue_Queue, (for 'enqueue') the modifiable list of pending up upgrade tasks
 *
 * @return mixed  based on op. for 'check', returns array(boolean) (TRUE if upgrades are pending)
 *                for 'enqueue', returns void
 */
function editor_civicrm_upgrade($op, CRM_Queue_Queue $queue = NULL) {
  return _editor_civix_civicrm_upgrade($op, $queue);
}

/**
 * Implementation of hook_civicrm_managed
 *
 * Generate a list of entities to create/deactivate/delete when this module
 * is installed, disabled, uninstalled.
 */
function editor_civicrm_managed(&$entities) {
  return _editor_civix_civicrm_managed($entities);
}

/**
 * Implementation of hook_civicrm_caseTypes
 *
 * Generate a list of case-types
 *
 * Note: This hook only runs in CiviCRM 4.4+.
 */
function editor_civicrm_caseTypes(&$caseTypes) {
  _editor_civix_civicrm_caseTypes($caseTypes);
}

function editor_civicrm_alterAPIPermissions($entity, $action, &$params, &$permissions)
{
    $permissions['country']['get'] = array('access CiviCRM');
    $permissions['candidate']['get'] = array('access CiviCRM');
    $permissions['candidate']['create'] = array('add contacts');
    $permissions['candidate']['setvalue'] = array('add contacts');
}
