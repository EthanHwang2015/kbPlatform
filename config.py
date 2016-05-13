#encoding=utf8
import sys
import ConfigParser
reload(sys)
sys.setdefaultencoding('utf-8')

class Config:
    def __init__(self, confFile):
        self.conf = ConfigParser.ConfigParser()
        self.conf.read(confFile)

    def getSections(self):
        return self.conf.sections()

    def getOption(self, key):
        return self.conf.options(key)

    def getValues(self, key):
        return self.conf.items(key)

    def get(self, section, key):
        return self.conf.get(section, key)

if __name__ == "__main__":
    config = Config('conf/kbplatform.conf')
    print config.getSections()
    print config.getOption("mysql")
    print config.getValues("mysql")
    print config.get("mysql", "host")

