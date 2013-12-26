cj(function ($) {
  var grid;
//First Name  Last Name National party  European Group  Place on the list email Constituency  Country Telefon Twitter Facebook  Website City of residence

  function countryFormatter(row, cell, value, columnDef, dataContext) {
     return "<span class='country_"+dataContext.country_id+"'>"+value+"</span>";
  }

  function filter(item) {
    for (var columnId in columnFilters) {
      if (columnId !== undefined && columnFilters[columnId] !== "") {
        var c = grid.getColumns()[grid.getColumnIndex(columnId)];
        if (item[c.field] != columnFilters[columnId]) {
          return false;
        }
      }
    }
    return true;
  }
var columnFilters = {};

  
  var columns = [
    {id: "first_name", name: "First Name", field: "first_name", editor: Slick.Editors.Text,sortable:true},
    {id: "last_name", name: "Last name", field: "last_name",minWidth:175, editor: Slick.Editors.Text,sortable:true },
    {id: "party", name: "Party", field: "party",sortable:true},
    {id: "position", name: "Position", field: "position",width:40, editor: Slick.Editors.Integer},
    {id: "email", name: "Email", field: "email", editor: Slick.Editors.Text},
    {id: "constituency", name:"Constituency", field: "constituency"},
    {id: "country", name:"Country", field: "country",formatter:countryFormatter},
    {id: "phone", name:"Phone", field: "phone", editor: Slick.Editors.Text},
    {id: "website", name:"Website", field: "website"},
    {id: "twitter", name:"Twitter", field: "twitter"},
    {id: "facebook", name:"Facebook", field: "facebook"},
    {id: "city", name:"City of residence", field: "city", editor: Slick.Editors.Text}
  ];

  var options = {
    enableCellNavigation: true,
  enableAddRow: true,
  editable: true,
 asyncEditorLoading: true,
  forceFitColumns: false,
  topPanelHeight: 25,
    enableColumnReorder: true
  };

//    var data = candidates.values;
  dataView = new Slick.Data.DataView({ inlineFilters: false });
  dataView.setItems(candidates.values);
 
 grid = new Slick.Grid("#candidates", dataView, columns, options);
//   grid = new Slick.Grid("#candidates", candidates.values, columns, options);
  var pager = new Slick.Controls.Pager(dataView, grid, $("#pager"));
  var columnpicker = new Slick.Controls.ColumnPicker(columns, grid, options);
    grid.registerPlugin( new Slick.AutoTooltips({ enableForHeaderCells: true }) );

 // move the filter panel defined in a hidden div into grid top panel
  $("#inlineFilterPanel")
      .appendTo(grid.getTopPanel())
      .show();

  grid.onCellChange.subscribe(function (e, args) {
console.log (args);
    dataView.updateItem(args.item.id, args.item);
  });

  // wire up model events to drive the grid
  dataView.onRowCountChanged.subscribe(function (e, args) {
    grid.updateRowCount();
    grid.render();
  });

  dataView.onRowsChanged.subscribe(function (e, args) {
    grid.invalidateRows(args.rows);
    grid.render();
  });

  dataView.onPagingInfoChanged.subscribe(function (e, pagingInfo) {
    var isLastPage = pagingInfo.pageNum == pagingInfo.totalPages - 1;
    var enableAddRow = isLastPage || pagingInfo.pageSize == 0;
    var options = grid.getOptions();

    if (options.enableAddRow != enableAddRow) {
      grid.setOptions({enableAddRow: enableAddRow});
    }
  });

    $(grid.getHeaderRow()).delegate(":input", "change keyup", function (e) {
      var columnId = $(this).data("columnId");
      if (columnId != null) {
        columnFilters[columnId] = $.trim($(this).val());
        dataView.refresh();
      }
    });

    grid.onHeaderRowCellRendered.subscribe(function(e, args) {
        $(args.node).empty();
        $("<input type='text'>")
           .data("columnId", args.column.id)
           .val(columnFilters[args.column.id])
           .appendTo(args.node);
    });

  grid.onAddNewRow.subscribe(function (e, args) {
    var item = {"num": data.length, "id": "new_" + (Math.round(Math.random() * 10000)), "title": "New task", "duration": "1 day", "percentComplete": 0, "start": "01/01/2009", "finish": "01/01/2009", "effortDriven": false};
    $.extend(item, args.item);
    dataView.addItem(item);
  });

  grid.onAddNewRow.subscribe(function (e, args) {
      var item = args.item;
      grid.invalidateRow(data.length);
      data.push(item);
      grid.updateRowCount();
      grid.render();
  });
  
  dataView.beginUpdate();
  dataView.setItems(candidates.values);
   dataView.setFilter(filter);
 
/*
  dataView.setFilterArgs({
    country: country,
    party: party,
    searchString: searchString
  });
*/

//  dataView.setFilter(myFilter);

  dataView.endUpdate();

});
