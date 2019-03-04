<body>
<ul id="country">
</ul>
{crmTitle string="choose a country"}
<script>
var countries={crmAPI entity="Country"}.values;
{literal}
var t="";
CRM.$.each(countries,function(k,d){
  console.log(d);
  t += "<li><a href='/civicrm/candidate/"+d.iso_code+"'>"+d.name+"</a></li>";
});

CRM.$("#country").html(t);
{/literal}
</script>
</body>
