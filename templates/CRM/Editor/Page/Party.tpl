<h3>Parties</h3>

<script>

var countries = {crmAPI sequential=0 entity="Constant" name="country"}.values;
{if isset($country)}
var parties = {crmAPI entity="Contact" contact_sub_type="party" option_limit=1000 return="organization_name,nick_name,legal_name,country" option_sort="organization_name DESC" country=$country};
{else}
var parties = {crmAPI entity="Contact" contact_sub_type="party" option_limit=1000 return="organization_name,nick_name,legal_name,country" option_sort="organization_name DESC"};
{/if}
{literal}
cj(function($) {
    var oTable = $('#example').dataTable( {
        "bPaginate":false,
        "aaData": parties.values,
        "aoColumns": [
 //           { "sTitle": "id",mData:"id"},
            { "sTitle": "name", mDataProp: "organization_name",sClass: "editable"},
            { "sTitle": "english", mDataProp:"legal_name","sClass": "editable" },
            { "sTitle": "accronym" , mDataProp:"nick_name","sClass": "editable"},
            { "sTitle": "country", mDataProp:"country", "sClass": "country" }
        ]
    } )

   var editableSettings = { 
     callBack:function(data){
          if (data.is_error) {
            editableSettings.error.call (this,data);
          } else {
             return editableSettings.success.call (this,data);
          }
        },
        error: function(entity,field,value) {
          $(this).crmError(data.error_message, ts('Error'));
          $(this).removeClass('crm-editable-saving');
        },
        success: function(entity,field,value) {
          var $i = $(this);
          CRM.alert('', ts('Saved'), 'success');
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
        "placeholder": '<span class="crm-editable-placeholder">Click to edit</span>'
  
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
          editableSettings.error.call(this,entity,field,value);
        },
        success: function (data) {
          editableSettings.success.call(this,entity,field,value);
        }
      });
    },settings);

    settings.type="select";
    settings.data=countries;
    settings.onblur = 'submit';
 
    oTable.$('td.country').editable( function(value,settings) {
      $(this).addClass ('crm-editable-saving');
      pos = oTable.fnGetPosition( this );
      row= pos[0];
      column= pos[2];
      address_id=parties.values[row].address_id;
      entity="Address";
      CRM.api(entity, "setvalue", {"field":"country_id","value":value, "id":address_id}, {
        context: this,
        error: function (data) {
          editableSettings.error.call(this,entity,"country",value);
        },
        success: function (data) {
          value = countries[value];
          editableSettings.success.call(this,entity,"country",value);
        }
      });
    },settings);
});

{/literal}
</script>

<table id="example"></table>
