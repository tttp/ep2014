function civicrm_api3_contact_fix ($params) {
  $value= array();
  $sql="update civicrm_contact set display_name = organization_name, sort_name = organization_name where contact_type = "Organization" and organization_name <> display_name;";
  $dao = CRM_Core_DAO::executeQuery($sql); 
  return civicrm_api3_create_success($values, $params, NULL, NULL, $dao); 
};


