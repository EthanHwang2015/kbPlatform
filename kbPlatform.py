#encoding=utf8
# -*- coding: utf-8 -*-
import sys
import os
reload(sys)
sys.setdefaultencoding('utf-8')
#sys.path.append("../mining/entity_tag/src/")
from bottle import route, run, template, static_file, request, redirect
import json
import commands
from Mysql import Mysql, MySQLdb
from NodeTree import NodeTree
from config import Config
import traceback
import hashlib
import httplib

config = Config("./conf/kbplatform.conf")
MYSQL_HOST = config.get("mysql", "host")
USER = config.get("mysql", "user")
PASSWD = config.get("mysql", "passwd")
etaggerHost = config.get("etagger", "host")
etaggerPort= int(config.get("etagger", "port"))


@route('/inputCase')
def index():
    return template('view/input_case')

@route('/')
def index():
    return template('view/index')

@route('/class')
def index():
    return template('view/class')

@route('/label')
def index():
    return template('view/label')

@route('/processCase', method='POST')
def index():
    input = request.json
    txt = input['txt']
    res = {}
    md5 = hashlib.md5()
    md5.update(txt)
    out = '/tmp/'+md5.hexdigest()
    #cmd = 'python /home/yongsheng/EMR_search_demo/mining/entity_tag/src/entity_tag_service.py \'%s\' %s' %(txt, out)
    #os.system(cmd)
    """
    send request to search module
    """
    requests = {'input':txt, 'output':os.getcwd() + '/' + out}
    headers = {"Content-type": "application/json"}
    httpClient = httplib.HTTPConnection(etaggerHost, etaggerPort, timeout=30)
    httpClient.request("POST", "/etagger", json.dumps(requests), headers)
    response = httpClient.getresponse()
    httpClient.close()
    res['html'] = out
    return {"msg":"ok", "res":res} 
 
@route('/filter', method='POST')
def index():
    input = request.json
    className = input['class']
    seed = input['seed']
    source = input['source']
    sql = 'select class,seed,source,sentence_src,sentence_dest from sentence where flag=0 '
    if len(className) > 0:
        sql = sql + 'and class=\'%s\'' %(className)
    if len(seed) > 0:
        sql = sql + 'and seed=\'%s\'' %(seed)
    if len(source) > 0:
        sql = sql + 'and source=\'%s\'' %(source)

    res = []
    try:
        rows = Mysql('healthai', host=MYSQL_HOST, user=USER, passwd=PASSWD).execute(sql)
        for row in rows:
            res.append({"class":row[0], "seed":row[1], "source":row[2],"sentence_src":row[3], "sentence_dest": row[4]})
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

    dbMap = {'mutex':'healthai', 'term':'healthai', 'seed':'healthai'}
    sqlMap = {
        'mutex':'delete from kb_class_relation where class_src=\'%s\' and class_dest=\'%s\''%(className, value),
        'term':'delete from kb_class_term where class=\'%s\' and term=\'%s\'' %(className, value),
        'seed':'delete from class where class=\'%s\' and seed=\'%s\'' %(className, value)
    }

    try:
        rows = Mysql(dbMap[field], host=MYSQL_HOST, user=USER, passwd=PASSWD).execute(sqlMap[field])
    except MySQLdb.Error, e:
        print traceback.format_exc()
    
    return {'msg': 'ok'}

@route('/updateLabel', method='POST')
def index():
    input = request.json
    className = input['class']
    seed = input['seed']
    sentence = input['sentence_src']
    sentence_dest = input['sentence_dest']
    label = input['label']
    sql = 'update sentence set flag=%d,sentence_dest=\'%s\' where class=\'%s\' and sentence_src=\'%s\'' %(label, sentence_dest,className, sentence)
    mysql = Mysql('healthai', host=MYSQL_HOST, user=USER, passwd=PASSWD)
    mysql.connect()
    try:
        rows = mysql.executeNoConn(sql)
    except MySQLdb.Error, e:
        print traceback.format_exc()
    #标注ok ,将sentence或sentence_dest写入术语
    if int(label) == 1:
        term = sentence_dest if len(sentence_dest) > 0 else sentence
        sql = 'insert into kb_class_term(class,term) values (\'%s\', \'%s\')' % (className, term)
        try:
            rows = mysql.executeNoConn(sql)
        except MySQLdb.Error, e:
            #key exists
            if e.args[0] == 1062:
                pass
            else:
                print traceback.format_exc()

    mysql.close()
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
        sql = 'delete from kb_class_relation where class_src=\'%s\' and relation=1 and class_dest=\'%s\'' %(parent, className)
        try:
            rows = Mysql('healthai', host=MYSQL_HOST, user=USER, passwd=PASSWD).execute(sql)
        except MySQLdb.Error, e:
            print traceback.format_exc()

    return {'msg':'ok'}


@route('/getZtree', method='POST')
def index():
    input = request.json
    for key in input:
        print key, input[key]
    sql = 'select * from kb_class_relation where relation=1'
    rows = Mysql('healthai', host=MYSQL_HOST, user=USER, passwd=PASSWD).execute(sql)

    nodeTree = NodeTree()
    rank = {u'症状':1, u'测量':2, u'疾病':3, u'手术':4, u'化疗':5}
    root = nodeTree.rowsToTree(rows, rank)
    js = nodeTree.toJson(root[0])
    print json.dumps(js)
    return {'msg':'ok', 'data':js}

@route('/getDetail', method='POST')
def index():
    input = request.json
    className = input['class']
    res = {}
    """
    healthai.kb_class_relation
    """
    sql = 'select class_dest from kb_class_relation where class_src=\'%s\' and relation=2' %(className)
    res['mutex'] = []
    try:
        rows = Mysql('healthai', host=MYSQL_HOST, user=USER, passwd=PASSWD).execute(sql)
        for row in rows:
            res['mutex'].append({'mutex':row[0]})
    except MySQLdb.Error, e:
        print traceback.format_exc()

    """
    healthai.kb_class_term
    """
    sql = 'select term from kb_class_term where class=\'%s\'' %(className)
    res['term'] = []
    try:
        rows = Mysql('healthai', host=MYSQL_HOST, user=USER, passwd=PASSWD).execute(sql)
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
        rows = Mysql('healthai', host=MYSQL_HOST, user=USER, passwd=PASSWD).execute(sql)
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
    healthai.kb_class_relation
    """
    #sql = 'select count(*) from kb_class_relation where class_src=%s relation=%d class_dest=%s'  %(parent, 1, className)

    #rows = Mysql('healthai', host=MYSQL_HOST).execute(sql)
    #count = int(rows[0][0])
    #if count == 0:
    mysql= Mysql('healthai', host=MYSQL_HOST, user=USER, passwd=PASSWD)
    mysql.connect()
    sql = 'insert into kb_class_relation(class_src,relation,class_dest) values (\'%s\', %d, \'%s\')' % (parent, 1, className)
    try:
        rows = mysql.executeNoConn(sql)
    except MySQLdb.Error, e:
        #key exists
        if e.args[0] == 1062:
            pass
        else:
            print traceback.format_exc()
    for mutex in mutexs:
        sql = 'insert into kb_class_relation(class_src,relation,class_dest) values (\'%s\', %d, \'%s\')' %(className, 2, mutex)
        try:
            rows = mysql.executeNoConn(sql)
        except MySQLdb.Error, e:
            #key exists
            if e.args[0] == 1062:
                pass
            else:
                print traceback.format_exc()
    """
    healthai.kb_class_term
    """
    for term in terms:
        sql = 'insert into kb_class_term(class,term) values (\'%s\', \'%s\')' % (className, term)
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
            rows = Mysql('healthai', host=MYSQL_HOST, user=USER, passwd=PASSWD).execute(sql)
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

@route('/tmp/<filePath:path>')
def server_static(filePath):
    return static_file(filePath, root='./tmp/')




if __name__ == "__main__":
    run(host='0.0.0.0', port=8090)
