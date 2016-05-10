#encoding=utf8
import MySQLdb
import traceback

class Mysql:
    def __init__(self, db, host='localhost', user='root', passwd='', port=3306):
        self.db = db
        self.host = host
        self.user = user
        self.passwd = passwd
        self.port = port

    def connect(self):
        self.conn=MySQLdb.connect(host=self.host, user=self.user,passwd=self.passwd,db=self.db, port=self.port, charset="utf8")
        self.cur = self.conn.cursor()

    def executeNoConn(self, sql):
        self.cur.execute(sql)
        res = self.cur.fetchall()
        self.conn.commit()

        return res
        
    def close(self):
        self.cur.close()
        self.conn.close()
     

    def execute(self, sql):
        self.conn=MySQLdb.connect(host=self.host, user=self.user,passwd=self.passwd,db=self.db, port=self.port, charset="utf8")
        self.cur = self.conn.cursor()
        self.cur.execute(sql)
        res = self.cur.fetchall()
        self.cur.close()
        self.conn.commit()
        self.conn.close()
        return res

    def executeMany(self, sql, args):
        self.conn=MySQLdb.connect(host=self.host, user=self.user,passwd=self.passwd,db=self.db, port=self.port, charset="utf8")
        self.cur = self.conn.cursor()
        self.cur.executemany(sql, args)
        res = self.cur.fetchall()
        self.cur.close()
        self.conn.commit()
        self.conn.close()
        return res


if __name__ == '__main__':
    className = u'头疼'
    relation = 1
    parent = 'root'
        #sql = 'insert into class_relation(class_src, relation, class_dest) values (\'%s\', %d, \'%s\')' %(parent, relation, className)
        #sql = 'select class_src, class_dest from class_relation where class_src=\'%s\'' %(className)
    '''
    mysql = Mysql('kb')
    mysql.connect()
    words = ['绞痛','刺痛']
    for word in words:
        try:
            sql = 'insert into class_term(class,term) values (\'腹痛\', \'%s\')' %(word)
            print sql
            res = mysql.executeNoConn(sql)
            print res, len(res)

        except MySQLdb.Error, e:
            if e.args[0] == 1062: 
                pass 
            else:
                print traceback.format_exc()

    mysql.close()
    '''
    sql = 'select * from class_relation where class_src=\'\''
    rows = Mysql('kb').execute(sql)
    print rows


