<?php 

function civicrm_api3_candidate_fix ($params) {
	//	update civicrm_value_mep_2 set twitter_8 = replace(twitter_8,"https://twitter.com/","") where twitter_8 like "http%"
	//	update civicrm_value_mep_2 set twitter_8 = replace(twitter_8,"@","") where twitter_8 like "@%"
  return;
  $urlfixes = array (
   "wwwfacebook.com" => "www.facebook.com",
   "/ttp://" => "",
   "/ttps://www.facebook.com" => "",
   "/ttps://de-de.facebook.com" => "",
   "/ww.facebook.com" => "",
   "hhttps://www.facebook.com/" => "https://www.facebook.com/",
   "http://https://" => "https://",
   "facebook.comwww.facebook.com" => "www.facebook.com",

   "?sk=info" => "",
   "&sk=info" => "",
   "?ref=ts" => "",
   "&ref=ts" => "",
   "?fref=ts" => "",
   "&fref=ts" => "",
   "&sk=wall" => "",
   "&ref=tn_tnmn" => "",
   "?ref=home" => "",
   "?ref=logo" => "",
   "?sk=wall" => "",
   "?ref=sgm" => "",
   "?ref=hl" => "",
   "?ref=tn_tnmn" => "",
   "?ref=stream" => "",
   "?ref=mf" => "",
   "?ref=profile" => "",

   "/home.php#!" => "",
   "/#!/profile.php" => "/profile.php",

   "http://facebook.com/" => "https://www.facebook.com/",
   "http://www.facebook.com/" => "https://www.facebook.com/",
   "https://facebook.com/" => "https://www.facebook.com/",
   "https://www.facebook.com/#!/" => "https://www.facebook.com/",
  );
  foreach ($urlfixes as $from => $to) {
    $sql = "UPDATE civicrm_website set url = REPLACE(url, %1,%2) WHERE website_type_id=3 AND url like %3";
    $dao = CRM_Core_DAO::executeQuery($sql, array (
      1=>array ($from,"String"), 
      2=> array ($to,"String"), 
      3=>array ("%$from%","String")
    ));   
  }
  $sql = "delete from civicrm_website where url is NULL;";
  CRM_Core_DAO::executeQuery($sql);
   $dao = $sql = "delete w1 from civicrm_website w1, civicrm_website w2 where w1.id < w2.id AND w1.contact_id = w2.contact_id AND w1.website_type_id = w2.website_type_id;";
  CRM_Core_DAO::executeQuery($sql);
  return civicrm_api3_create_success($values, $params, NULL, NULL, $dao); 
}

function civicrm_api3_candidate_denormalise ($params) {
  CRM_Core_DAO::dropTriggers("civicrm_value_ep_1");
  CRM_Core_DAO::dropTriggers("civicrm_value_ep_group_3");
  $sql="update civicrm_value_ep_1 as candidate, civicrm_contact as p,civicrm_value_ep_group_3 as pcustom set euparty_18=eu_party_10,group_6=ep_group_9 where candidate.party_5=p.id AND pcustom.entity_id=p.id";
//always update AND euparty_18 is NULL AND group_6 is NULL;";
  $dao = CRM_Core_DAO::executeQuery($sql); 
  return civicrm_api3_create_success($values, $params, NULL, NULL, $dao); 
  CRM_Core_DAO::triggerRebuild("civicrm_value_ep_1");
  CRM_Core_DAO::triggerRebuild("civicrm_value_ep_group_3");
};


function civicrm_api3_candidate_create ($params) {
  foreach (array ("elected"=>"custom_7","position"=>"custom_6","country"=>"custom_4","twitter"=>"custom_8","party"=>"custom_5") as $a => $f) {
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
      if ($params[$type][0]) 
        $params[$type] = "https://".$type.".com/". substr($params[$type],1);
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
  if ($params["field"] == "twitter") $params["field"]= "custom_8";
  if ($params["field"] == "elected") $params["field"]= "custom_30";
  return civicrm_api3("contact","setvalue",$params);
}

function civicrm_api3_candidate_get ($params) {
  $sqlParam = array();
  $join="LEFT JOIN civicrm_value_mep_2 mep ON mep.entity_id = c.id ";
  $select ="c.id as id, c.first_name, c.last_name, country_4 as country, position_6 as position, party_5 as party, elected_7 as elected,  twitter_8 as twitter";
  if (! ($params["options"] && $params["options"]["public"])){
    $select .= ",mep.id as candidate_id,c.contact_sub_type as type,email, civicrm_email.id as email_id";
    $join .= " LEFT JOIN civicrm_email ON c.id = civicrm_email.contact_id AND is_primary=1 ";
  } else {
    $select = "civicrm_country.name as country_name, iso_code as country_iso,p.organization_name as party_name," . $select;
    $join .= " LEFT JOIN civicrm_contact p ON p.id = party_5 LEFT JOIN civicrm_country ON civicrm_country.id=country_4 ";
  }
  if (array_key_exists ("pledge",$params)) {
	  $join .=
		  " join civicrm_activity_contact ac on ac.contact_id=c.id and record_type_id=3"
		  ." join civicrm_activity a on activity_id=a.id  and activity_type_id=32 and a.status_id=2"
		  ." join civicrm_campaign camp on camp.id=campaign_id and (camp.name=%2 or camp.external_identifier=%2)";
     $where = " (1=1) ";
     $sqlParam[2] = array($params["pledge"], 'String');
  } else {
    $params["pledge"] = null;
    $where = "c.contact_sub_type like '%candidate%'";
  }
  if (array_key_exists ("filter_include",$params)) {
    $where .= " OR c.contact_sub_type like '%mep%'";
  }
  if (array_key_exists ("elected",$params)) {
     $where .= " AND elected_/ like '%1%'";
  }
  if (array_key_exists ("country",$params)) {
    $where .= " AND mep.country_4 = %1";
    $sqlParam [1] = array((int) $params["country"], 'Integer');
  }
    $where .= " AND c.is_deleted = 0";
  if (array_key_exists ("return",$params)) {
    if (strpos($params["return"],"created") !== false)
      $select .= " , date(created_date) as created , date(modified_date) as modified "; 
    if (strpos($params["return"],"sub_type") !== false)
      $select .= " , contact_sub_type "; 
  }


  $sql = "SELECT $select FROM civicrm_contact as c $join WHERE $where";
  $dao = CRM_Core_DAO::executeQuery($sql, $sqlParam); 

  $values = array(); 
  while ($dao->fetch()) { 
    $values[] = $dao->toArray(); 
  }
  return civicrm_api3_create_success($values, $params, NULL, NULL, $dao); 

}
