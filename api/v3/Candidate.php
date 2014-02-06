<?php 
function civicrm_api3_candidate_get ($params) {
  $sqlParam = array();
  $select ="c.id as id, first_name, last_name, email, civicrm_email.id as email_id, civicrm_value_ep_1.id as candidate_id, country_3 as country, position_2 as position, party_5 as party, website.url as website, facebook.url as facebook, twitter.url as twitter, image_URL";
  $join="LEFT JOIN civicrm_value_ep_1 ON civicrm_value_ep_1.entity_id = c.id ";
  $join .= "LEFT JOIN civicrm_email ON c.id = contact_id AND is_primary=1 ";
  $join .= "LEFT JOIN civicrm_website as website ON website.contact_id=c.id AND website.website_type_id=1 ";
  $join .= "LEFT JOIN civicrm_website as facebook ON facebook.contact_id=c.id AND facebook.website_type_id=2 ";
  $join .= "LEFT JOIN civicrm_website as twitter ON facebook.contact_id=c.id AND twitter.website_type_id=3 ";
  if (array_key_exists ("group",$params)) {
    $where = "agroup.group_id = %1 ";
    $join .= " JOIN civicrm_group_contact as agroup ON agroup.contact_id = c.id ";
    $sqlParam =  array(1 => array((int) $params["group"], 'Integer'));
  } else {
    $params["group"] = null;
    $where = "contact_sub_type like '%candidate%'";
  }
  if (array_key_exists ("country",$params)) {
    $where .= " AND civicrm_value_ep_1.country_3 = %1";
    $sqlParam =  array(1 => array((int) $params["country"], 'Integer'));
  }
    $where .= " AND c.is_deleted = 0";


  $sql = "SELECT $select FROM civicrm_contact as c $join WHERE $where";

  $dao = CRM_Core_DAO::executeQuery($sql, $sqlParam); 

  $values = array(); 
  while ($dao->fetch()) { 
    $values[] = $dao->toArray(); 
  }
  return civicrm_api3_create_success($values, $params, NULL, NULL, $dao); 

}
