<?php 

//function _civicrm_api3_Country_Getstat_spec ($params) {
//}

function civicrm_api3_Country_Getstat ($params) {
  $sqlParam = null;
  $join ="JOIN civicrm_value_ep_1 as candidate ON candidate.entity_id = contact.id 
   JOIN civicrm_country as country ON country.id = candidate.country_3";

  $where = "contact_sub_type = 'mep'";
  if ($params["group"]) {
    $where = "agroup.group_id = %1";
    $join .= " JOIN civicrm_group_contact as agroup ON agroup.contact_id = contact.id ";
    $sqlParam =  array(1 => array((int) $params["group"], 'Integer'));
  }
  $sql = "SELECT country.iso_code, country.id, country.name, count(contact.id) as count
    FROM civicrm_contact as contact $join WHERE $where GROUP BY country.id;";
  $dao = CRM_Core_DAO::executeQuery($sql, $sqlParam); 

  $values = array(); 
  while ($dao->fetch()) { 
    $values[] = $dao->toArray(); 
  }
  return civicrm_api3_create_success($values, $params, NULL, NULL, $dao); 

}
