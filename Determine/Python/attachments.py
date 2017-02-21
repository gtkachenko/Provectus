#!/usr/bin/env python
import argparse
import os
import sys
import io
import re
import zipfile
import getpass
import time
import shutil
from ftplib import FTP
import shutil
parser = argparse.ArgumentParser()
parser.add_argument("-u", "--user", required=True, action="store",
                    help="display a user which CLM works" )
parser.add_argument("-c", "--customer", required=True, action="store",
                    help="display a customer name system" )
parser.add_argument("-z", "--zip_files", action="store",
                    help="display if need make cope of origin zip_files")
parser.add_argument("-v", "--verbose", action="store_true",
                    help="more details in  output verbosity" )
args = parser.parse_args()
client = args.customer
zip_orig = args.zip_files


dest = os.getcwd() + '/';
print (dest);
file_attach='attach.list'
if os.path.exists(file_attach):
 os.remove(file_attach)
 print ('Removed old file with attachments list')
else:
 print ('Do not present old file with attachments list')

dummy_folder='/home/ec2-user/dummy_file_lib'
list_files = os.listdir(dummy_folder)
for i in list_files:
 if os.path.isdir(i):
  shutil.rmtree(i)
  os.remove(i+'.zip')
  print ("Old folder and zip archive removed")

pattern = re.compile("^(?!#).*attachments.+")
matches = []
if args.user == "stdstg":
 with open ('/CLM_STD_STAGE/clients/' + client + '/conf/'+ client + '_properties', 'r') as file:
    for line in file:
     matches += pattern.findall(line)
 if len(matches) == 0:
    base_path = "/CLM_STD_STAGE/clients/" + client + "/appSupport/attachments/"
 else:
    base_path = "/CLM_STD_STAGE/clients/" + client + "/data/"
 list = os.listdir (base_path)
 print (list)
 attachpath = raw_input ("Chose folder with attachments: ")
 source_dir=os.path.join(base_path, attachpath)
 for root, dirs, files, in os.walk(source_dir):
      for name in files:
          with open('attach.list', 'a+') as f:
              f.write("/".join(str(os.path.join(root, name)).split("/")[-3:]) + '\n')
elif args.user == "stdsvc":
 with open ('/CLM_STD/clients/' + client + '/conf/' + client + '_properties', 'r') as file:
    for line in file:
     matches += pattern.findall(line)
 if len(matches) == 0:
    base_path = "/CLM_STD/clients/" + client + "/appSupport/attachments/"
 else:
    base_path = "/CLM_STD/clients/" + client + "/data/"
 list = os.listdir (base_path)
 print (list)
 attachpath = raw_input ("Chose folder with attachments: ")
 source_dir=os.path.join(base_path, attachpath)
 for root, dirs, files, in os.walk(source_dir):
      for name in files:
          with open('attach.list', 'a+') as f:
              f.write("/".join(str(os.path.join(root, name)).split("/")[-3:]) + '\n')
elif args.user == "perfsvc":
 with open ('/CLM_PERF/clients/' + client +  '/conf/'+ client + '_properties', 'r') as file:
    for line in file:
     matches += pattern.findall(line)
 if len(matches) == 0:
    base_path = "/CLM_PERF/clients/" + client + "/appSupport/attachments/"
 else:
    base_path = "/CLM_PERF/clients/" + client + "/data/"
 list = os.listdir (base_path)
 print (list)
 attachpath = raw_input ("Chose folder with attachments: ")
 source_dir=os.path.join(base_path, attachpath)
 for root, dirs, files, in os.walk(source_dir):
      for name in files:
          with open('attach.list', 'a+') as f:
              f.write("/".join(str(os.path.join(root, name)).split("/")[-3:]) + '\n')
elif args.user == "perfstg":
 with open ('/CLM_PERF_STAGE/clients/' + client + '/conf/'+ client + '_properties', 'r') as file:
    for line in file:
     matches += pattern.findall(line)
 if len(matches) == 0:
    base_path = "/CLM_PERF_STAGE/clients/" + client + "/appSupport/attachments/"
 else:
    base_path = "/CLM_PERF_STAGE/clients/" + client + "/data/"
 list = os.listdir (base_path)
 print (list)
 attachpath = raw_input ("Chose folder with attachments: ")
 source_dir=os.path.join(base_path, attachpath)
 for root, dirs, files, in os.walk(source_dir):
      for name in files:
          with open('attach.list', 'a+') as f:
              f.write("/".join(str(os.path.join(root, name)).split("/")[-3:]) + '\n')
elif args.user == "esssvc":
 with open ('/CLM_ESS/clients/' + client + '/conf/'+ client + '_properties', 'r') as file:
    for line in file:
     matches += pattern.findall(line)
 if len(matches) == 0:
    base_path = "/CLM_ESS/clients/" + client + "/appSupport/attachments/"
 else:
    base_path = "/CLM_ESS/clients/" + client + "/data/"
 list = os.listdir (base_path)
 print (list)
 attachpath = raw_input ("Chose folder with attachments: ")
 source_dir=os.path.join(base_path, attachpath)
 for root, dirs, files, in os.walk(source_dir):
      for name in files:
          with open('attach.list', 'a+') as f:
              f.write("/".join(str(os.path.join(root, name)).split("/")[-3:]) + '\n')

path_list = []
with open('attach.list') as myf:
  lines = myf.read().splitlines()

if zip_orig == 'zip':
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
        with open(line, "a+") as f:
            f.write(file_in.read())
        if file_extension == '.zip':
            shutil.copy (base_path + line , dest + line)
        file_in.close()
    except:
        print("ERRROR -%s" % line)
else:
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
     with open(line, "a+") as f:
            f.write(file_in.read())
     file_in.close()
   except:
        print("ERRROR -%s" % line)
 
zipp = zipfile.ZipFile (attachpath + '.zip', mode='w')
for root, dirs, files in os.walk(attachpath):
    for file in files:
     zipp.write(os.path.join(root,file))
zipp.close()

ftp_host = raw_input("Plese entet ftp Host Name (You can use default ftp in virginia): ")
if not ftp_host:
 ftp_host = "10.100.1.138"
ftp_port = raw_input("Port Number (You can use default 21): ")
if not ftp_port:
 ftp_port = "21"
ftp_user = raw_input("User Name (You can use default user): ")
if not ftp_user:
 ftp_user = "user"
ftp_pass = getpass.getpass("Password: ")
ftp_acct = raw_input("Account (Leave blank if none): ")
if ftp_user and ftp_pass == "":
 ftp = FTP(ftp_host)
 ftp.login()
try:
 ftp = FTP(ftp_host)
 ftp.connect(ftp_host, ftp_port)
 ftp.login(ftp_user, ftp_pass, ftp_acct)
 file = open(attachpath + '.zip', "rb")
 ftp.cwd('/0/')
 ftp.storbinary('STOR ' + attachpath + '.zip', file)
 print "STORING File now..."
 ftp.quit()
 file.close()
 print "File transfered"
except:
 print "An error occured"
