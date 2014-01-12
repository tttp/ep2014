<h3>Parties</h3>

<script>

var countries_flat = {crmAPI sequential=0 entity="Constant" name="country"}.values;
var countries = {crmAPI entity="Country"}.values;

var groups = {crmAPI entity="Contact" contact_sub_type="epgroup" option_limit=1000 return="organization_name,nick_name,legal_name" option_sort="organization_name ASC"}.values;

var parties = {crmAPI entity="Contact" contact_sub_type="party" option_limit=1000 return="organization_name,nick_name,legal_name,country,custom_7" option_sort="organization_name ASC"};
{literal}
var groups_flat = {}; 

cj(function($) {
    $.each(groups, function(n) {
        groups_flat[groups[n].id]=groups[n].organization_name;
    });
    groups_flat[0]="-select-";

    $.each(parties.values, function(n) {
      if (parties.values[n].custom_7) {
        parties.values[n].custom_7=groups_flat[parties.values[n].custom_7];
      };
    });

    var oTable = $('#contacts').dataTable( {
    bJQueryUI: true,
    "bStateSave": true,
    "bPaginate":false,
    "aaData": parties.values,
    "aoColumns": [
//           { "sTitle": "id",mData:"id"},
        { "sTitle": "name", mDataProp: "organization_name",sClass: "editable"},
        { "sTitle": "group", mDataProp:"custom_7","sClass": "group" },
        { "sTitle": "english", mDataProp:"legal_name","sClass": "editable" },
        { "sTitle": "accronym" , mDataProp:"nick_name","sClass": "editable"},
        { "sTitle": "country", mDataProp:"country", "sClass": "country" }
    ],
    "fnDrawCallback": function () {
//TODO: add the editable
    }
  });

   var editableSettings = { 
     callBack:function(data){
          if (data.is_error) {
            editableSettings.error.call (this,data);
          } else {
             return editableSettings.success.call (this,data);
          }
        },
        error: function(data) {
          $(this).crmError(data.error_message, ts('Error'));
          $(this).removeClass('crm-editable-saving');
        },
        success: function(entity,field,value) {
          var $i = $(this);
          CRM.alert(value, ts('Saved'), 'success');
          $i.removeClass ('crm-editable-saving crm-error');
          $i.html(value);
        }
   };

    /* Apply the jEditable handlers to the table */
    var settings =  {
        "callback": function( sValue, y ) {
console.log ("callback");
console.log (oTable.fnGetPosition( this ));
            var aPos = oTable.fnGetPosition( this );
            oTable.fnUpdate( sValue, aPos[0], aPos[1] );
        },
          data: function(value, settings) {
              return value.replace(/<(?:.|\n)*?>/gm, '');
            },
  
        "height": "24px",
        "width": "100%",
        "placeholder": '<span class="crm-editable-placeholder">Click to edit</span>',
        "onblur": "ignore" 
    };

    oTable.$('td.editable').editable( function(value,settings) {
      $(this).addClass ('crm-editable-saving');
      pos = oTable.fnGetPosition( this );
      row= pos[0];
      column= pos[2];
      contact_id=parties.values[row].id;
      field = oTable.fnSettings().aoColumns[column].mData;
      entity="Contact";
      CRM.api(entity, "setvalue", {"field":field,"value":value, "id":contact_id}, {
        context: this,
        error: function (data) {
          editableSettings.error.call(this,data);
        },
        success: function (data) {
          CRM.alert( ts('Saved') + " " + value,parties.values[row].organization_name, 'success');
        }
      });
      return value;
    },settings);

    /* Apply the jEditable handlers to the eu groups */
    settings.type="select";
    settings.data=groups_flat;
    settings.onblur = 'submit';
 
    oTable.$('td.group').editable( function(value,settings) {
      $(this).addClass ('crm-editable-saving');
      pos = oTable.fnGetPosition( this );
      row= pos[0];
      column= pos[2];
      contact_id=parties.values[row].id;
      entity="Contact";
      CRM.api(entity, "create", {"custom_7":value, "id":contact_id}, {
        context: this,
        error: function (data) {
          editableSettings.error.call(this,data);
        },
        success: function (data) {
          CRM.alert( parties.values[row].organization_name , ts('Saved') + " " + groups_flat[value], 'success');
        }
      });
      return groups_flat[value];
    },settings);

    /* Apply the jEditable handlers to the countries */
    settings.data=countries_flat;
    oTable.$('td.country').editable( function(value,settings) {
      $(this).addClass ('crm-editable-saving');
      pos = oTable.fnGetPosition( this );
      row= pos[0];
      column= pos[2];
      address_id=parties.values[row].address_id;
      entity="Address";
      if (address_id) {
        CRM.api(entity, "setvalue", {"field":"country_id","value":value, "id":address_id}, {
          context: this,
          error: function (data) {
            editableSettings.error.call(this,data);
          },
          success: function (data) {
            CRM.alert(parties.values[row].organization_name ,countries_flat[value] +" "+ ts('Saved'), 'success');
          }
        });
      } else {
        contact_id=parties.values[row].id;
        CRM.api(entity, "create", 
          {"location_type_id":2,"is_primary":1,"country_id":value, "contact_id":contact_id}, {
          context: this,
          error: function (data) {
            editableSettings.error.call(this,data);
          },
          success: function (data) {
            parties.values[row].address_id = data.address_id;
            CRM.alert(countries_flat[value]+ " "+ ts('Saved'),parties.values[row].organization_name , 'success');
          }
        });
      }
      return countries_flat[value];
    },settings);

    $(".ui-widget-header").append("<button id='add' class='add_row'>Add</button>");
    var o= "";
    $.each(countries, function (i,d) {
      o = o + "<option value='"+d.id+"'>"+d.name+"</option>";
    });
    $("#new_dialog select#country").append (o);
    
    var o= "<option value=''>-select-</option>";
    $.each(groups, function (i,d) {
      o = o + "<option value='"+d.id+"'>"+d.organization_name+"</option>";
    });
    $("#new_dialog select#custom_7").append (o);
    $("#new_dialog").dialog({"modal":true, autoOpen:false}).submit (function (e) {
      e.preventDefault();
      var fields = ["organization_name", "legal_name", "nick_name", "country","custom_7"];
      var params = {
        "dedupe_check":true,
        "source": "civicrm/party",
        "contact_type":"Organization",
        "contact_sub_type":"party"
      };
      $.each(fields, function(id) {
        params[fields[id]]=$("#"+fields[id]).val();
      });
      params["country"]=countries_flat[params["country"]];
      var entity="contact";
      CRM.api(entity, "create", params, {
        context: this,
        error: function (data) {
          CRM.alert(result.error_message, 'Save error', 'error')
          console.log (data);
        },
        success: function (data) {
          params["id"]=data["id"];
          params["custom_7"]=groups_flat[params["custom_7"]];
          oTable.fnAddData( params);
          $("#new_dialog").dialog('close');
          CRM.alert(params.organization_name, 'Saved', 'error')
        }
      });
    });
      
    $("#add").click(function () { $("#new_dialog").dialog('open'); });

    $('#contacts select').live('change', function () {
      $(this).closest("form").submit();
//      alert("Change Event Triggered On:" + $(this).attr("value"));
    });

});

{/literal}
</script>

<table id="contacts"></table>

<div id="new_dialog">
<form>
<div class="form-item">
<label>Name</label>
<input id="organization_name"  class="form-control "/>
</div>
<div class="form-item">
<label>Group</label>
<select id="custom_7"  class="form-control ">
</select>
</div>
<div class="form-item">
<label>English Name</label>
<input id="legal_name" class="form-control "/>
</div>
<div class="form-item">
<label>Accronym</label>
<input id="nick_name"  class="form-control "/>
<label>Country</label>
<select id="country"  class="form-control ">
</select>
</div>

<input type="submit" name="save" class="btn-primary form-submit"/>
</form>
</div>
