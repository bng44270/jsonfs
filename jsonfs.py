######################
# jsonfs.py
#
# Python JsonFS Library
#
# ParseDirectory - Parse a directory structure and return JsonFS data
# DumpDirectory - Parse JsonFS data and create directory/file structure
#
# Also see Javascript Library https://gist.github.com/bng44270/183eed06ec1bda30535278e36e1295cb
######################

from os import walk, mkdir
from os.path import isfile, join, getmtime, getsize
from time import ctime
from base64 import b64encode,b64decode
from json import dumps,loads

def ParseDirectory(p):
  thisfs = {}
  
  for (dirpath, dirnames, filenames) in walk(p):
    for file in filenames:
      fd = open(join(dirpath,file),"r")
      filecontent = fd.read()
      fd.close()
      
      filemodified = getmtime(join(dirpath,file))
      
      filesize = getsize(join(dirpath,file))
      
      thisfs[file] = {}
      thisfs[file]["content"] = b64encode(filecontent.encode('ascii')).decode('ascii')
      thisfs[file]["modified"] = ctime(filemodified)
      thisfs[file]["size"] = filesize
      
    for dir in dirnames:
      thisfs[dir] = ParseDirectory(join(dirpath,dir))
    
  return dumps(thisfs)

def DumpDirectory(json,d):
  fs = loads(json)
  for entry in fs:
    if "content" in fs[entry] and "modified" in fs[entry] and "size" in fs[entry]:
      filecontent = b64decode(fs[entry]["content"].encode('ascii')).decode('ascii')
      fd = open(join(d,entry),'w')
      fd.write(filecontent)
      fd.close()
    else:
      mkdir(join(d,entry))
      DumpDirectory(dumps(fs[entry]),join(d,entry))
