<?php
// $Id$

/*
 +--------------------------------------------------------------------+
 | CiviCRM version 4.2                                                |
 +--------------------------------------------------------------------+
 | Copyright CiviCRM LLC (c) 2004-2012                                |
 +--------------------------------------------------------------------+
 | This file is a part of CiviCRM.                                    |
 |                                                                    |
 | CiviCRM is free software; you can copy, modify, and distribute it  |
 | under the terms of the GNU Affero General Public License           |
 | Version 3, 19 November 2007 and the CiviCRM Licensing Exception.   |
 |                                                                    |
 | CiviCRM is distributed in the hope that it will be useful, but     |
 | WITHOUT ANY WARRANTY; without even the implied warranty of         |
 | MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.               |
 | See the GNU Affero General Public License for more details.        |
 |                                                                    |
 | You should have received a copy of the GNU Affero General Public   |
 | License and the CiviCRM Licensing Exception along                  |
 | with this program; if not, contact CiviCRM LLC                     |
 | at info[AT]civicrm[DOT]org. If you have questions about the        |
 | GNU Affero General Public License or the licensing of CiviCRM,     |
 | see the CiviCRM license FAQ at http://civicrm.org/licensing        |
 +--------------------------------------------------------------------+
*/

/**
 * File for the CiviCRM APIv3 country functions
 *
 * @package CiviCRM_APIv3
 *
 * @copyright CiviCRM LLC (c) 2004-2012
 */

require_once 'CRM/Core/BAO/Email.php';

function civicrm_api3_country_create($params) {
  return _civicrm_api3_basic_create(_civicrm_api3_get_DAO(__FUNCTION__), $params);
}
/*
 * Adjust Metadata for Create action
 * 
 * The metadata is used for setting defaults, documentation & validation
 * @param array $params array or parameters determined by getfields
 */
function _civicrm_api3_country_create_spec(&$params) {
//  $params['is_primary']['api.default'] = 0;
//  $params['email']['api.required'] = 1;
//  $params['contact_id']['api.required'] = 1;
}

/**
 * @param  array  $params
 *
 * @return boolean | error  true if successfull, error otherwise
 * {@getfields country_delete}
 * @access public
 */
function civicrm_api3_country_delete($params) {
  return _civicrm_api3_basic_delete(_civicrm_api3_get_DAO(__FUNCTION__), $params);
}

function _civicrm_api3_country_get_spec ($params) {
};
 
/**
 * Retrieve one or more countries
 *
 * @param  array input parameters
 *
 *
 * @param  array $params  an associative array of name/value pairs.
 *
 * @return  array api result array
 * {@getfields country_get}
 * @access public
 */


function civicrm_api3_country_get($params) {
  if (!array_key_exists ("option_limit", $params));
    $params['option_limit'] = 9999999;
  $countries = _civicrm_api3_basic_get(_civicrm_api3_get_DAO(__FUNCTION__), $params);
  $actives = civicrm_api3 ("Constant","get",array("name"=>"country","option.limit"=>90000))["values"];
  foreach ($countries["values"] as $k => &$v) {
    if (!array_key_exists ($v["id"], $actives)) {
      unset($countries["values"][$k]);
    }
  }
  $countries["all"] = $countries["count"];
  $countries["count"] = count ($countries["values"]);
  $countries["inactives"] = $countries["all"] - $countries["count"];
  
  return $countries;
}

