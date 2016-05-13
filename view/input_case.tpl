<!DOCTYPE html>
<html lang="zh-CN">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- 上述3个meta标签*必须*放在最前面，任何其他内容都*必须*跟随其后！ -->
    <title>Index</title>

    <!-- Bootstrap -->
    <link href="/bootstrap/css/bootstrap.min.css" rel="stylesheet">
    <!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
    <script src="/bootstrap/js/jquery.min.js"></script>
    <!-- Include all compiled plugins (below), or include individual files as needed -->
    <script src="/bootstrap/js/bootstrap.min.js"></script>
 </head>
 <body>
    <div class="container">
        <div class="row">
          <div class='col-lg-8'>
            <div class="panel panel-info">
                <textarea id='caseTxt' class="form-control" rows="10"></textarea>
            </div>

            <iframe id="output" frameborder=0 height="300px" width="500px">
            </iframe>
          </div>
          <div class='col-lg-2'>
                <button id='process' type="button" class="btn btn-primary btn-sm">处理</button>
          </div>
        </div>
    </div>
    <script>
        $('#process').click(function(event) {
            var txt = $('#caseTxt').val();
            input = {}
            input['txt'] = txt;
            output = {}
            $.ajax({
                url:'processCase',
                data: JSON.stringify(input),
                async : false,
                type:'POST',
                contentType: "application/json",
                dataType:'json',
                success: function(data) {
                    if (data.msg == "ok") {
                        output = data.res;
                             
                    } else {
                        alert(data.msg);
                    }
                },
                error: function(data) {
                    alert('error');
                },
            });
            if ("html" in output) {
                $('#output').attr('src', output["html"]);
            }
            
        });
    </script>
 </body>
</html>
