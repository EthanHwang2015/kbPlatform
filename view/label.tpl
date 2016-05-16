<!DOCTYPE html>
<html lang="zh-CN">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- 上述3个meta标签*必须*放在最前面，任何其他内容都*必须*跟随其后！ -->
    <title>标注语料</title>

    <!-- Bootstrap -->
    <link href="/bootstrap/css/bootstrap.min.css" rel="stylesheet">
    <!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
    <script src="/bootstrap/js/jquery.min.js"></script>
    <!-- Include all compiled plugins (below), or include individual files as needed -->
    <script src="/bootstrap/js/bootstrap.min.js"></script>

    <!-- zTree -->
	<link rel="stylesheet" href="/zTree/css/zTreeStyle/zTreeStyle.css" type="text/css">
	<link rel="stylesheet" href="/bootstrap-table/bootstrap-table.css" type="text/css">
	<link rel="stylesheet" href="/bootstrap-table/bootstrap-editable.css" type="text/css">
	<script type="text/javascript" src="/bootstrap-table/bootstrap-table.js"></script>
	<script type="text/javascript" src="/bootstrap-table/bootstrap-editable.js"></script>
	<script type="text/javascript" src="/bootstrap-table/extensions/editable/bootstrap-table-editable.js"></script>
    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
      <script src="//cdn.bootcss.com/html5shiv/3.7.2/html5shiv.min.js"></script>
      <script src="//cdn.bootcss.com/respond.js/1.4.2/respond.min.js"></script>

    <![endif]-->
  </head>
  <body>
    <div class="container">
    <div class="row">
      <div class="col-md-11">
        <div class="col-md-10">
            <label> class</label>
            <input id='classInput' type="text" placeholder="发烧"> </input>
            <label> seed</label>
            <input id='seedInput' type="text" placeholder="发烧"> </input>
            <label> source</label>
            <input id='sourceInput' type="text" placeholder="百度"> </input>
            <button id='filter' type="button" class="btn btn-primary btn-sm">Filter</button>
        </div>
        <div class="col-md-11"> 
            <table id="label"
                   data-pagination="true">
            </table>

        </div>
      </div>
    </div><!-- /.row --> 

    </div>
    <script>
            //var $table = $('#mutexTable');
            var table = $('#label');
            var $remove = $('#remove');
                var data = [
                    {
                        "class": "腹痛1",
                        "sentence": "腹痛1",
                    },
                    {
                        "class": "腹痛2",
                        "sentence": "腹痛sentence2",
                    },

                ];
 

            function initTable() {
               table.bootstrapTable({
                    columns: [
                        [
                            {
                                    field: 'class',
                                    title: 'class',
                                    align: 'center',
                            }, {
                                    field: 'seed',
                                    title: 'seed',
                                    align: 'center',
                            }, {
                                    field: 'source',
                                    title: 'source',
                                    align: 'center',
                            }, {
                                    field: 'sentence_src',
                                    title: 'sentence_src',
                                    align: 'center',
                            }, {
                     
                                    field: 'sentence_dest',
                                    title: 'sentence_dest',
                                    
                                    editable: {
                                        type: 'text'
                                    },
                                    
                                    align: 'center',
                            }, {
                                title: '标注',
                                field: 'operate',
                                align: 'center',
                                events: operateEvents,
                                formatter: operateFormatter   
                            },
                        ], 
                    ],
                    pageSize:50,
                    //data: data,
                });
            }
            function operateFormatter(value, row, index) {
                return [
                    '<a class="checkOk" href="javascript:void(0)" title="checkOk">',
                    '<i class="glyphicon glyphicon-ok"></i>',
                    '</a> ',
                    '<a class="checkBad" href="javascript:void(0)" title="checkBad">',
                    '<i class="glyphicon glyphicon-remove"></i>',
                    '</a>'
                ].join('');
            }
            rowStyleMap = {};
            window.operateEvents = {
                'click .checkOk': function (e, value, row, index) {
                    table.bootstrapTable('updateRow', {
                        index:index,
                        row: row,
                        _class: 'success'
                    });
                    
                    var rowData = table.bootstrapTable('getData')[index];
                    rowData['label'] = 1;
                    $.ajax({
                        url:'updateLabel',
                        data: JSON.stringify(rowData),
                        //async : false,
                        type:'POST',
                        contentType: "application/json",
                        dataType:'json',
                        success: function(data) {
                            if (data.msg != "ok") {
                                alert('call updateLabel failed');
                            }

                        },
                        error: function(data) {
                                alert('call updateLabel failed');
                        },
                    });
                },
                'click .checkBad': function (e, value, row, index) {
                    var curIndex = index;
                    var rowData = table.bootstrapTable('getData')[index];
                    rowData['label'] = -1;
                    table.bootstrapTable('updateRow', {
                        index:index,
                        row: row,
                        _class: 'danger'
                    });

                    $.ajax({
                        url:'updateLabel',
                        //async : false,
                        data: JSON.stringify(rowData),
                        type:'POST',
                        contentType: "application/json",
                        dataType:'json',
                        success: function(data) {
                            if (data.msg != "ok") {
                                alert('call updateLabel failed');
                            }

                        },
                        error: function(data) {
                            alert('call updateLabel failed');
                        },
                    });

                }
            };
            $('#insertMutex').click(function(event) {
                var $table = $('#mutexTable');
                $table.bootstrapTable('append', 
                        {
                            mutex: 'new',
                        }
                    );
            });
            $('#insertTerm').click(function(event) {
                var $table = $('#termTable');
                $table.bootstrapTable('append', 
                        {
                            term: 'new',
                        }
                    );
            });
            $('#insertSeed').click(function(event) {
                var $table = $('#seedTable');
                $table.bootstrapTable('append', 
                        {
                            seed: 'new',
                        }
                    );
            });

            function getInputDataById(id) {
                var table = $(id);
                return table.val();
            }

            $('#filter').click(function(event) {
                var classInput = getInputDataById('#classInput');
                var seedInput = getInputDataById('#seedInput');
                var sourceInput = getInputDataById('#sourceInput');
                var output = {'class': classInput, 'seed':seedInput, 'source': sourceInput};
                $.ajax({
                        url:'filter',
                        data: JSON.stringify(output),
                        type:'POST',
                        contentType: "application/json",
                        dataType:'json',
                        success: function(data) {
                            if (data.msg == "ok") {
                                rowStyleMap = {}
                                var table = $('#label');
                                table.bootstrapTable('removeAll');
                                table.bootstrapTable('append', data.res);
                            } else {
                                alert(data.msg);
                            }

                        },
                        error: function(data) {
                            alert('error');
                        },
                });
                
            });

            initTable();
    </script>

    <script type="text/javascript">
            $("#search").click(function() {
                if ( $("#textbox").val() == "") {
                    location.href = "#";
                    alert("haha");
                } else {
                    location.href = "search?keywords=" + $("#textbox").val();

                }
            });
            $("#textbox").keyup(function(event) {
                    if (event.keyCode == 13) {
                        $("#search").trigger('click');
                    }
            });
    </script>
  </body>
</html>
