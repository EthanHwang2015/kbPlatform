#encoding=utf8
# -*- coding: utf-8 -*-
import sys
reload(sys)
sys.setdefaultencoding('utf-8')
#sys.path.append("../mining/entity_tag/src/")
from bottle import route, run, template, static_file, request, redirect
import json
import commands
from Mysql import Mysql, MySQLdb
from NodeTree import NodeTree
import traceback

MYSQL_HOST = 'localhost'
#etagger = None


@route('/')
def index():
    return template('view/index')

@route('/class')
def index():
    return template('view/class')

@route('/label')
def index():
    return template('view/label')

@route('/filter', method='POST')
def index():
    input = request.json
    className = input['class']
    seed = input['seed']
    source = input['source']
    sql = 'select class,seed,sentence_src from sentence where flag=0 '
    if len(className) > 0:
        sql = sql + 'and class=\'%s\'' %(className)
    if len(seed) > 0:
        sql = sql + 'and seed=\'%s\'' %(seed)
    if len(source) > 0:
        sql = sql + 'and source=\'%s\'' %(source)

    res = []
    try:
        rows = Mysql('crawl_raw', host=MYSQL_HOST).execute(sql)
        for row in rows:
            res.append({"class":row[0], "seed":row[1], "sentence":row[2]})
    except MySQLdb.Error, e:
        print traceback.format_exc()

    #res.append({"class":"class1", "sentence":"sentence2"})
    return {"success":True, "msg":"ok", "res":res} 


@route('/removeTable', method='POST')
def index():
    input = request.json
    className = input['class']
    field = input['field']
    value = input['value']

    dbMap = {'mutex':'kb', 'term':'kb', 'seed':'crawl_raw'}
    sqlMap = {
        'mutex':'delete from class_relation where class_src=\'%s\' and class_dest=\'%s\''%(className, value),
        'term':'delete from class_term where class=\'%s\' and term=\'%s\'' %(className, value),
        'seed':'delete from class where class=\'%s\' and seed=\'%s\'' %(className, value)
    }

    try:
        rows = Mysql(dbMap[field], host=MYSQL_HOST).execute(sqlMap[field])
    except MySQLdb.Error, e:
        print traceback.format_exc()
    
    return {'msg': 'ok'}

@route('/updateLabel', method='POST')
def index():
    input = request.json
    className = input['class']
    seed = input['seed']
    sentence = input['sentence']
    label = input['label']
    sql = 'update sentence set flag=%d where class=\'%s\' and sentence_src=\'%s\'' %(label, className, sentence)
    print sql
    try:
        rows = Mysql('crawl_raw', host=MYSQL_HOST).execute(sql)
    except MySQLdb.Error, e:
        print traceback.format_exc()
    return {'msg': 'ok'}

def jsonTree(rows):
    """
    {name: "父节点1", children: [
        {name: "子节点1"},
        {name: "子节点2"}
    ]}
    """
    res = {}

@route('/removeZtree', method='POST')
def index():
    input = request.json
    print input
    if 'class' in input and 'parent' in input:
        className = input['class']
        parent = input['parent']
        sql = 'delete from class_relation where class_src=\'%s\' and relation=1 and class_dest=\'%s\'' %(parent, className)
        try:
            rows = Mysql('kb', host=MYSQL_HOST).execute(sql)
        except MySQLdb.Error, e:
            print traceback.format_exc()



    return {'msg':'ok'}


@route('/getZtree', method='POST')
def index():
    input = request.json
    for key in input:
        print key, input[key]
    sql = 'select * from class_relation where relation=1'
    rows = Mysql('kb', host=MYSQL_HOST).execute(sql)

    nodeTree = NodeTree()
    root = nodeTree.rowsToTree(rows)
    js = nodeTree.toJson(root[0])
    print json.dumps(js)
    return {'msg':'ok', 'data':js}

@route('/getDetail', method='POST')
def index():
    input = request.json
    className = input['class']
    res = {}
    """
    kb.class_relation
    """
    sql = 'select class_dest from class_relation where class_src=\'%s\' and relation=2' %(className)
    res['mutex'] = []
    try:
        rows = Mysql('kb', host=MYSQL_HOST).execute(sql)
        for row in rows:
            res['mutex'].append({'mutex':row[0]})
    except MySQLdb.Error, e:
        print traceback.format_exc()

    """
    kb.class_term
    """
    sql = 'select term from class_term where class=\'%s\'' %(className)
    res['term'] = []
    try:
        rows = Mysql('kb', host=MYSQL_HOST).execute(sql)
        for row in rows:
            res['term'].append({'term':row[0]})
    except MySQLdb.Error, e:
        print traceback.format_exc()

    """
    crawl_raw.seed
    """
    sql = 'select seed from class where class=\'%s\'' %(className)
    res['seed'] = []
    try:
        rows = Mysql('crawl_raw', host=MYSQL_HOST).execute(sql)
        for row in rows:
            res['seed'].append({'seed':row[0]})
    except MySQLdb.Error, e:
        print traceback.format_exc()

    print 'getDetail', res
    return {'msg':'ok', 'res':res}

@route('/submit', method='POST')
def index():
    input = request.json
    for key in input:
        print key, input[key]
    className = input['class']
    parent = input['parent']
    mutexs = input['mutex']
    terms = input['term']
    seeds = input['seed']
    """
    kb.class_relation
    """
    #sql = 'select count(*) from class_relation where class_src=%s relation=%d class_dest=%s'  %(parent, 1, className)

    #rows = Mysql('kb', host=MYSQL_HOST).execute(sql)
    #count = int(rows[0][0])
    #if count == 0:
    mysql = Mysql('kb', host=MYSQL_HOST)
    mysql.connect()
    sql = 'insert into class_relation(class_src,relation,class_dest) values (\'%s\', %d, \'%s\')' % (parent, 1, className)
    try:
        rows = Mysql('kb', host=MYSQL_HOST).execute(sql)
    except MySQLdb.Error, e:
        #key exists
        if e.args[0] == 1062:
            pass
        else:
            print traceback.format_exc()
    for mutex in mutexs:
        sql = 'insert into class_relation(class_src,relation,class_dest) values (\'%s\', %d, \'%s\')' %(className, 2, mutex)
        try:
            rows = mysql.executeNoConn(sql)
        except MySQLdb.Error, e:
            #key exists
            if e.args[0] == 1062:
                pass
            else:
                print traceback.format_exc()
    """
    kb.class_term
    """
    for term in terms:
        sql = 'insert into class_term(class,term) values (\'%s\', \'%s\')' % (className, term)
        try:
            rows = mysql.executeNoConn(sql)
        except MySQLdb.Error, e:
            #key exists
            if e.args[0] == 1062:
                pass
            else:
                print traceback.format_exc()

    mysql.close()
    
    """
    crawl_raw.class_seed
    """
    for seed in seeds:
        sql = 'insert into class(class,seed) values (\'%s\',\'%s\')' % (className, seed)
        try:
            rows = Mysql('crawl_raw', host=MYSQL_HOST).execute(sql)
        except MySQLdb.Error, e:
            #key exists
            if e.args[0] == 1062:
                pass
            else:
                print traceback.format_exc()
    return {'msg': 'ok'}

@route('/search')
def index():
    keywords = request.query.get('keywords')
    results = getSearchResult(keywords)
    return template('view/search', keywords = keywords, results= results)


@route('/bootstrap/<filePath:path>')
def server_static(filePath):
    return static_file(filePath, root='./bootstrap/')

@route('/zTree/<filePath:path>')
def server_static(filePath):
    return static_file(filePath, root='./zTree/')

@route('/bootstrap-table/<filePath:path>')
def server_static(filePath):
    return static_file(filePath, root='./bootstrap-table/')



if __name__ == "__main__":
    run(host='localhost', port=8080)
