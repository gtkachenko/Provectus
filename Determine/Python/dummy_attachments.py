#!/usr/bin/env python
import io
import os
import sys
import re
import shutil
import argparse
import import cx_Oracle
parser = argparse.ArgumentParser()
parser.add_argument("-z", "--zip_files", action="store_true",
                    help="display if need make cope of origin zip_files")
parser.add_argument("-c", "--customer", required=True,
		    help="display a customer name system")
parser.add_argument("-f","--files", action="store_true",
		    help="display if need make full copy BO and caluse files")

args = parser.parse_args()
zip_orig = args.zip_files
customer = args.customer
bo_and_clause = args.files

base_path = '/data/backup/rsync/'
path_suffix = '.selectica.com' 
file_attach = 'attach.file'
bo_and_clause_file = 'export.txt'
dest = '/tmp/temp/'
pattern = re.compile("^(?!#).*attachments.+")
db_server = '*'

matches = []
base_folders = []
base_folders = (os.listdir(base_path))
for i in base_folders:
 if os.path.isdir(base_path  + i):
  lists = (os.listdir(base_path + i))
  if (customer + path_suffix)  in lists:
   client_path = (os.path.abspath(base_path + i + '/' + customer + path_suffix))

clm_folder_tmp = (os.path.dirname(client_path).split("/")[-1:])
clm_folder = "".join([str(i) for i in clm_folder_tmp])
with open (client_path + '/' + clm_folder + '/clients/' + customer + '/conf/' + customer + '_properties', 'r') as f:
 for line in f:
  matches += pattern.findall(line)
if len(matches) == 0:
 attachment_path = client_path + '/' + clm_folder + '/clients/' + customer + '/appSupport/attachments/'
else:
 attachment_path = client_path + '/' + clm_folder + '/clients/' + customer + '/data/'
list_folder = os.listdir(attachment_path)

for item in list_folder:
 if item == '*':
  source_dir=os.path.join(attachment_path, '*')
 elif item == '*':
  source_dir=os.path.join(attachment_path, '*')
 elif item == '*':
  source_dir=os.path.join(attachment_path, '*')
 elif item == '*':
  source_dir=os.path.join(attachment_path, '*')

for root, dirs, files, in os.walk(source_dir):
 for name in files:
  with open(file_attach, 'a+') as myf:
   myf.write("/".join(str(os.path.join(root, name)).split("/")[-3:]) + '\n') 

path_list = []
with open(file_attach) as list_attach:_f:
 lines = list_attach_f.read().splitlines()
 for line in lines:
  try:
   file_path, file_name = os.path.split(line)
   file_prefix, file_extension = os.path.splitext(file_name)
   if not file_extension:
    file_extension = '.pdf'
   if file_path not in path_list:
    path_list.append(file_path)
    if not os.path.exists(file_path):
     os.makedirs(file_path)
   file_in = open('Template%s' % file_extension.lower(), 'r')
   with open(line, "a+") as f1:
    f1.write(file_in.read())
   file_in.close()
  except:
   print("ERRROR -%s" % line)

present_dir = os.getcwd()
find_dir = os.listdir(present_dir)
for folder in find_dir:
 if os.path.isdir(folder):
  shutil.copytree (folder, dest + folder)
  shutil.rmtree(folder)

if zip_orig:
 print ("Start make full cope of zip archive files")
 path_zip_files= []
 with open(file_attach) as list_zip_f:
  lines = list_zip_f.read().splitlines()
  for line in lines:
   try:
    file_path, file_name = os.path.split(line)
    file_prefix, file_extension = os.path.splitext(file_name)
    if file_extension == '.zip':
     shutil.copyfile(attachment_path + line, dest + line)
   except:
    print("ERROR -%s" % line)

if os.path.exists(file_attach):
 os.remove(file_attach)

if bo_and_clause:
 print("Start make full copy of clauses and bo files")
 SQL = "SELECT to_char(ap.value) as filename FROM attachment a JOIN attachmentparam ap ON ap.id = a.id JOIN contract1 c ON a.parentid = c.id JOIN contract1param cp ON c.id = cp.id WHERE a.status = 0 and a.comptype = 'ReqNewBoilerplate' AND cp.value = 'active' AND cp.name='contractStatus' AND ap.name = 'serverFileName' union all select distinct to_char(pm.value) from C_MCPINFO01PARAM pm, C_MCPINFO01 mm  where name = 'ClauseFile' and mm.status = 0 and pm.value is not null"
 os.putenv('ORACLE_HOME', '/opt/instantclient_12_2')
 os.putenv('LD_LIBRARY_PATH', '/opt/instantclient_12_2')
 path_bo = []
 connection = cx_Oracle.connect('*/*' + db_server)
 cursor = connection.cursor()
 cursor.execute(SQL)
 for row in cursor:
  path_bo.append(row)
 try:
  for line in path_bo:
   shutil.copyfile(attachment_path + line[0], dest + line[0])
 except:
  print("ERROR -%s" % line[0])
else:
 print ("Just dummy attachments made")
 
