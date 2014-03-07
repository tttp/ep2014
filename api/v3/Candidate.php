<?php 

function civicrm_api3_candidate_denormalise ($params) {
  CRM_Core_DAO::dropTriggers("civicrm_value_ep_1");
  CRM_Core_DAO::dropTriggers("civicrm_value_ep_group_3");
  $sql="update civicrm_value_ep_1 as candidate, civicrm_contact as p,civicrm_value_ep_group_3 as pcustom set euparty_18=eu_party_10,group_6=ep_group_9 where candidate.party_5=p.id AND pcustom.entity_id=p.id AND euparty_18 is NULL AND group_6 is NULL;";
  $dao = CRM_Core_DAO::executeQuery($sql); 
  return civicrm_api3_create_success($values, $params, NULL, NULL, $dao); 
  CRM_Core_DAO::triggerRebuild("civicrm_value_ep_1");
  CRM_Core_DAO::triggerRebuild("civicrm_value_ep_group_3");
};


function civicrm_api3_candidate_create ($params) {
  foreach (array ("position"=>"custom_2","country"=>"custom_3","constituency"=>"custom_4","party"=>"custom_5") as $a => $f) {
    if (array_key_exists ($a,$params)) {
      $params[$f] = $params[$a];
    }
  }
  if (array_key_exists ("website",$params)) {
    $params["api.website.create"] = array ("url"=>$params["website"],"website_type_id"=>"home"
      , 'options' => array('match' => array ("website","website_type_id","contact_id"))
    );
  }
  foreach ( array ("facebook","twitter") as $type) {
    if (array_key_exists ($type,$params)) {
      if ($params[$type][0]) $params[$type] = "http://".$type.".com/". substr($params[$type],1);
      $params["api.website.create.".$type] = array ("url"=>$params[$type], "website_type_id"=>$type
        , 'options' => array('match' => array ("website","website_type_id","contact_id"))
      );
    }
  };
  return civicrm_api3("contact","create",$params);
}

function civicrm_api3_candidate_setvalue ($params) {
  if ($params["field"] == "email") {
     $r=civicrm_api3("email","get",array("is_primary"=>1,"contact_id"=>$params["id"]));
     if ($r["count"]==1) {
        return civicrm_api3("email","create",array("id"=>$r["id"],"email"=>$params["value"]));
     } else {
        return civicrm_api3("email","create",array("contact_id"=>$params["id"],"is_primary"=>1,"email"=>$params["value"]));
     }
  }
  if ($params["field"] == "facebook" || $params["field"] == "twitter" || $params["field"] == "website")  {
     if ($params["field"] == "website") $params["field"] = "home";
     $r=civicrm_api3("website","get",array("website_type_id"=>$params["field"],"contact_id"=>$params["id"]));
     if ($r["count"]==1) {
        return civicrm_api3("website","create",array("id"=>$r["id"],"url"=>$params["value"]));
     } else {
        return civicrm_api3("website","create",array("contact_id"=>$params["id"],"website_type_id"=>$params["field"],"url"=>$params["value"]));
     } 
  }
  return civicrm_api3("contact","setvalue",$params);
}

function civicrm_api3_candidate_get ($params) {

  $sqlParam = array();
  $select ="c.id as id, first_name, last_name, email, civicrm_email.id as email_id, civicrm_value_ep_1.id as candidate_id, country_3 as country, position_2 as position, party_5 as party, website.url as website, facebook.url as facebook, twitter.url as twitter, image_URL";
  $join="LEFT JOIN civicrm_value_ep_1 ON civicrm_value_ep_1.entity_id = c.id ";
  $join .= "LEFT JOIN civicrm_email ON c.id = civicrm_email.contact_id AND is_primary=1 ";
  $join .= "LEFT JOIN civicrm_website as website ON website.contact_id=c.id AND website.website_type_id=1 ";
  $join .= "LEFT JOIN civicrm_website as facebook ON facebook.contact_id=c.id AND facebook.website_type_id=3 ";
  $join .= "LEFT JOIN civicrm_website as twitter ON twitter.contact_id=c.id AND twitter.website_type_id=4 ";
  if (array_key_exists ("group",$params)) {
    $where = "agroup.group_id = %1 ";
    $join = " JOIN civicrm_group_contact as agroup ON agroup.contact_id = c.id " . $join;
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
