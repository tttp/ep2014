SELECT 
contact_a.id, first_name, last_name,
civicrm_value_mep_2.id as civicrm_value_mep_2_id, 
party_5 as party_id,
twitter_8 as twitter,
civicrm_value_mep_2.country_4 as country_id,
a.status_id,activity_id,
activity_date_time as date
FROM civicrm_contact contact_a 
join civicrm_activity_contact ac on ac.contact_id=contact_a.id and record_type_id=2 
join civicrm_activity a on activity_id=a.id  and activity_type_id=32 
join civicrm_campaign camp on camp.id=campaign_id
LEFT JOIN civicrm_value_mep_2 ON civicrm_value_mep_2.entity_id = contact_a.id

WHERE  
  contact_a.is_deleted = '0' 
  AND (contact_a.contact_sub_type LIKE '%Candidate%') 
  AND camp.name ="ILGA"
order by activity_date_time desc
;
