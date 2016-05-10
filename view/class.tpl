<!DOCTYPE html>
<html lang="zh-CN">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- 上述3个meta标签*必须*放在最前面，任何其他内容都*必须*跟随其后！ -->
    <title>实体管理</title>

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
    <style type="text/css">
            .ztree li span.button.add {margin-left:2px; margin-right: -1px; background-position:-144px 0; vertical-align:top; *vertical-align:middle}
    </style>
	<script type="text/javascript" src="/zTree/js/jquery.ztree.core.js"></script>
	<script type="text/javascript" src="/zTree/js/jquery.ztree.excheck.js"></script>
	<script type="text/javascript" src="/zTree/js/jquery.ztree.exedit.js"></script>
	<script type="text/javascript" src="/bootstrap-table/bootstrap-table.js"></script>
	<script type="text/javascript" src="/bootstrap-table/bootstrap-editable.js"></script>
	<script type="text/javascript" src="/bootstrap-table/extensions/editable/bootstrap-table-editable.js"></script>
    <!-- zTree -->
	<script type="text/javascript">
		<!-- 
		var setting = {
			view: {
                dblClickExpand: dblClickExpand,
				addHoverDom: addHoverDom,
				removeHoverDom: removeHoverDom,
				selectedMulti: false
			},
			edit: {
				enable: true,
				editNameSelectAll: true,
				showRemoveBtn: showRemoveBtn,
				showRenameBtn: showRenameBtn
			},
			data: {
				simpleData: {
					enable: true
				}
			},
			callback: {
				beforeDrag: beforeDrag,
				beforeEditName: beforeEditName,
				beforeRemove: beforeRemove,
				beforeRename: beforeRename,
				onRemove: onRemove,
				enRename: onRename,
                onClick: onClick
			}
		};

		var zNodes =[
			//{ id:1, pId:0, name:"root", open:true},
		];
		var log, className = "dark";
		function beforeDrag(treeId, treeNodes) {
			return false;
		}
		function beforeEditName(treeId, treeNode) {
			className = (className === "dark" ? "":"dark");
			showLog("[ "+getTime()+" beforeEditName ]&nbsp;&nbsp;&nbsp;&nbsp; " + treeNode.name);
			var zTree = $.fn.zTree.getZTreeObj("treeShow");
			zTree.selectNode(treeNode);
			//return confirm("Start node '" + treeNode.name + "' editorial status?");
			return true;
		}
		function beforeRemove(treeId, treeNode) {
			className = (className === "dark" ? "":"dark");
			showLog("[ "+getTime()+" beforeRemove ]&nbsp;&nbsp;&nbsp;&nbsp; " + treeNode.name);
			var zTree = $.fn.zTree.getZTreeObj("treeShow");
			zTree.selectNode(treeNode);
			return confirm("确认删除节点'" + treeNode.name + "' ?");
		}
		function onRemove(e, treeId, treeNode) {
			showLog("[ "+getTime()+" onRemove ]&nbsp;&nbsp;&nbsp;&nbsp; " + treeNode.name);
            input = {}
            var node = treeNode.getParentNode();
            if (node) {
                input['class'] = treeNode.name;
                input['parent'] = node.name;
                input['children'] = new Array();
                for (var child in treeNode.children) {
                    input['children'].push(child.name);
                }
            }
            $.ajax({
                url:'removeZtree',
                data: JSON.stringify(input),
                //async : false,
                type:'POST',
                contentType: "application/json",
                dataType:'json',
                success: function(data) {
                    if (data.msg != "ok") {
                        alert('页面出错');
                    }
                    zNodes.push(data.data);

                },
                error: function(data) {
                    alert('页面出错');
                },
            });



		}
		function beforeRename(treeId, treeNode, newName, isCancel) {
			className = (className === "dark" ? "":"dark");
			showLog((isCancel ? "<span style='color:red'>":"") + "[ "+getTime()+" beforeRename ]&nbsp;&nbsp;&nbsp;&nbsp; " + treeNode.name + (isCancel ? "</span>":""));
			if (newName.length == 0) {
				alert("Node name can not be empty.");
				var zTree = $.fn.zTree.getZTreeObj("treeShow");
				setTimeout(function(){zTree.editName(treeNode)}, 10);
				return false;
			}
			return true;
		}
        function onClick(e, treeId, treeNode) {
            //alert(treeNode.name);
        }
		function onRename(e, treeId, treeNode, isCancel) {
			showLog((isCancel ? "<span style='color:red'>":"") + "[ "+getTime()+" onRename ]&nbsp;&nbsp;&nbsp;&nbsp; " + treeNode.name + (isCancel ? "</span>":""));
		}
		function showRemoveBtn(treeId, treeNode) {
			//return !treeNode.isFirstNode;
			return true;
		}
		function showRenameBtn(treeId, treeNode) {
			//return !treeNode.isLastNode;
			return true;
		}
		function showLog(str) {
			if (!log) log = $("#log");
			log.append("<li class='"+className+"'>"+str+"</li>");
			if(log.children("li").length > 8) {
				log.get(0).removeChild(log.children("li")[0]);
			}
		}
		function getTime() {
			var now= new Date(),
			h=now.getHours(),
			m=now.getMinutes(),
			s=now.getSeconds(),
			ms=now.getMilliseconds();
			return (h+":"+m+":"+s+ " " +ms);
		}

		var newCount = 1;
		function addHoverDom(treeId, treeNode) {
			var sObj = $("#" + treeNode.tId + "_span");
			if (treeNode.editNameFlag || $("#addBtn_"+treeNode.tId).length>0) return;
			var addStr = "<span class='button add' id='addBtn_" + treeNode.tId
				+ "' title='add node' onfocus='this.blur();'></span>";
			sObj.after(addStr);
			var btn = $("#addBtn_"+treeNode.tId);
			if (btn) btn.bind("click", function(){
				var zTree = $.fn.zTree.getZTreeObj("treeShow");
				zTree.addNodes(treeNode, {id:(100 + newCount), pId:treeNode.id, name:"new node" + (newCount++)});
				return false;
			});
		};
		function removeHoverDom(treeId, treeNode) {
            $("#addBtn_"+treeNode.tId).unbind().remove();
		};
		
        function dblClickExpand(treeId, treeNode) {
            return treeNode.level > 0;
        };

		$(document).ready(function(){
            $.ajax({
                url:'getZtree',
                data: JSON.stringify({}),
                async : false,
                type:'POST',
                contentType: "application/json",
                dataType:'json',
                success: function(data) {
                    if (data.msg != "ok") {
                        alert('页面出错');
                    }
                    zNodes.push(data.data);

                },
                error: function(data) {
                    alert('页面出错');
                },
            });

			$.fn.zTree.init($("#treeShow"), setting, zNodes);
		});
		//-->
	</script>

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
      <div class="col-md-4">
        <ul id ="treeShow" class="ztree"> </ul>
      </div><!-- /.col-lg-6 -->
      <div class="col-md-8">
          <div class="col-md-8" id="prepareEdit">
            <div>
                <label> 类名</label>
                <input id='className' type="text" placeholder="类名"> </input>
                <label> 标注个数</label>
                <label id='labelCount' > 0 </label>
                <div class="pull-right">
                    <button id='submit' type="button" class="btn btn-primary btn-md">保存</button>
                </div>
            </div>
            <div >
                <label>父类名</label>
                <input id='classPaName' type="text" placeholder="父类名"> </input>
            </div>
          </div>
        <div class="col-md-8"> 
            <label>互斥类</label>
            <span style='float:right'>
            <a id='insertMutex'>
                <i class="glyphicon glyphicon-plus"></i>
            </a>
            </span>
            <table id="mutexTable">
            </table>
        </div>
        <div class="col-md-8"> 
            <label>术语</label>
            <span style='float:right'>
            <a id='insertTerm'>
                <i class="glyphicon glyphicon-plus"></i>
            </a>
            </span>
            <table id="termTable">
            </table>
        </div>
        <div class="col-md-8"> 
            <label>种子词</label>
            <span style='float:right'>
            <a id='insertSeed'>
                <i class="glyphicon glyphicon-plus"></i>
            </a>
            </span>
            <table id="seedTable">
            </table>

        </div>
      </div>
    </div><!-- /.row --> 

    </div>
    <script>
            //var $table = $('#mutexTable');
            var $remove = $('#remove');
                var data = [
                    {
                        "mutex": "腹痛1",
                    },
                    {
                        "mutex": "腹痛2",
                    },

                ];
 

            function initTable(id, title, field) {
               var $table = $(id);
               $table.bootstrapTable({
                    columns: [
                        [
                            {
                                    field: field,
                                    title: title,
                                    editable: {
                                        type: 'text'
                                    },
                                    align: 'center',
                            }, {
                                title: '操作',
                                field: 'operate',
                                align: 'center',
                                events: operateEvents,
                                formatter: operateFormatter   
                            },
                        ], 
                    ],
                    //data: data,
                });
            }
            function operateFormatter(value, row, index) {
                return [
                    '<a class="remove" href="javascript:void(0)" title="Remove">',
                    '<i class="glyphicon glyphicon-remove"></i>',
                    '</a>'
                ].join('');
            }
            window.operateEvents = {
                'click .remove': function (e, value, row, index) {
                    var toDo = {field:'mutex', values:[row.mutex]};
                    var table = $('#mutexTable');
                    var field = 'mutex';
                    var values = row.mutex;
                    if('term' in row) {
                        table = $('#termTable');
                        field = 'term';
                        values = row.term;
                    } else if('seed' in row){
                        table = $('#seedTable');
                        field = 'seed';
                        values = row.seed;
                    };
                    table.bootstrapTable('remove', {
                        field: field,
                        values: [values]
                    });
                    input = {}
                    input['class'] = $("#className").val();
                    input['field'] = field;
                    input['value'] = values;
                    $.ajax({
                            url:'removeTable',
                            data: JSON.stringify(input),
                            type:'POST',
                            contentType: "application/json",
                            dataType:'json',
                            success: function(data) {
                                if (data.msg == "ok") {
                                } else {
                                    view(data.msg);
                                }

                            },
                            error: function(data) {
                                alert('error');
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

            function getTableDataById(id) {
                var table = $(id);
                var data = table.bootstrapTable('getData');
                var output = new Array()
                for (var item in data) {
                    for (var prop in data[item]) {
                        output.push(data[item][prop]);
                    }
                }
                return output;
            }

            function getSelectNodeName() {
                var result = {}
                var treeObj = $.fn.zTree.getZTreeObj("treeShow");
                var nodes = treeObj.getSelectedNodes();
                if (nodes.length > 0) {
                    var node = nodes[0].getParentNode();
                    if (!node) {
                        result['parent'] = "NULL";
                    } else {
                        result['parent'] = node.name;
                    }
                    result['child'] = nodes[0].name;
                }
                return result;
            }

            $('#submit').click(function(event) {
                var mutexTable = getTableDataById('#mutexTable');
                var termTable = getTableDataById('#termTable');
                var seedTable = getTableDataById('#seedTable');
                var className = $("#className").val();
                var classPaName = $("#classPaName").val();
                if (classPaName == 'NULL' || className == '') {
                    $('#submit').disabled = true;
                    return;
                }
                var output = {'class': className, 'parent': classPaName, 'mutex': mutexTable, 'term':termTable, 'seed': seedTable};
                $.ajax({
                        url:'submit',
                        async: false,
                        data: JSON.stringify(output),
                        type:'POST',
                        contentType: "application/json",
                        dataType:'json',
                        success: function(data) {
                            if (data.msg == "ok") {
                                alert("保存成功");
                                window.location.reload();
                            } else {
                                view(data.msg);
                            }

                        },
                        error: function(data) {
                            alert('error');
                        },
                });
                
            });

            initTable('#mutexTable', '互斥类', 'mutex');
            initTable('#termTable', '术  语', 'term');
            initTable('#seedTable', '种子词', 'seed');
    </script>

    <script type="text/javascript">
            function getDetail(className) {
                var detail = {};
                var input = {};
                input['class'] = className;
                $.ajax({
                        url:'getDetail',
                        async: false,
                        data: JSON.stringify(input),
                        type:'POST',
                        contentType: "application/json",
                        dataType:'json',
                        success: function(data) {
                            if (data.msg == "ok") {
                                detail = data.res;
                            } else {
                                alert('error');
                            }

                        },
                        error: function(data) {
                            alert('error');
                        },
                });
                return detail;
            }
            $("#prepareEdit").click(function() {
                    var result = getSelectNodeName();
                    mutexTable = $('#mutexTable');
                    mutexTable.bootstrapTable('removeAll');
                    termTable = $('#termTable');
                    termTable.bootstrapTable('removeAll');
                    seedTable = $('#seedTable');
                    seedTable.bootstrapTable('removeAll');
                     
                    if (JSON.stringify(result) != '{}') {
                        $("#className").val(result['child']);
                        $("#classPaName").val(result['parent']);
                        detail = getDetail(result['child']);
                        mutexTable.bootstrapTable('append', detail['mutex']);
                        termTable.bootstrapTable('append', detail['term']);
                        seedTable.bootstrapTable('append', detail['seed']);
                    }
            });
 
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
