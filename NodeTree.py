#encoding=utf8
import json

class Node:
    def __init__(self, name):
        '''
        name should be utf8
        '''
        self.parent = None
        self.name = name
        self.children = []

    def setParent(self, parent):
        self.parent = parent

    def addChild(self, child):
        self.children.append(child)
        child.setParent(self)

    def getAllChildren(self):
        return self.children

    def hasChild(self):
        return len(self.children) > 0

    def hasParent(self):
        return self.parent is not None
        
class NodeTree:
    def __init__(self):
        pass

    def rowsToTree(self, rows):
        '''
        将形如( u'上腹痛', 1, u'上左腹痛')的数据处理成树
        '''
        #所有节点, name:node
        nodes = {} 
        for row in rows:
            parentName = row[0]
            childName = row[2]
            if parentName in nodes:
                if childName in nodes:
                    nodes[parentName].addChild(nodes[childName]) 
                else :
                    child = Node(childName)
                    nodes[childName] = child
                    nodes[parentName].addChild(child) 
            else :
                parent = Node(parentName)
                nodes[parentName]= parent
                if childName in nodes:
                    nodes[parentName].addChild(nodes[childName]) 
                else :
                    child = Node(childName)
                    nodes[childName] = child
                    nodes[parentName].addChild(child) 

        
        root = []

        for node in nodes:
            #合并独立的树
            if nodes[node].hasChild() and not nodes[node].hasParent():
                root.append(nodes[node])

        if len(root) == 0:
            root.append(Node('root'))

        return root

    def findNode(self, name, root):
        '''
        name should be utf8
        '''
        node = None
        if root is None:
            return node 
        if root.name == name:
            return root
        for child in root.getAllChildren():
            node = self.findNode(name, child)
            if node is not None:
                return node
        return node

    #中序遍历
    def toJson(self, root):
        if root is None:
            return {}
        res = {}
        res['name'] = root.name
        res['children'] = []
        for child in root.getAllChildren():
            res['children'].append(self.toJson(child))
        return res


if __name__ == '__main__':
    rows = [
        ( u'上腹痛', 1, u'上左腹痛'),
        ( u'腹痛', 1, u'下腹痛'),
        ( u'腹痛', 1, u'上腹痛'),
        ( u'root', 1, u'腹痛'),
        ( u'root', 1, u'头疼'),
        ( u'上腹痛', 1, u'上右腹痛')]

    nodeTree = NodeTree()

    roots = nodeTree.rowsToTree(rows)
    print len(roots)
    for root in roots:
        print json.dumps(nodeTree.toJson(root))

