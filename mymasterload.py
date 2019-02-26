#coding=utf-8
import re
import os
import subprocess

if __name__ == "__main__":
    files=os.listdir('/vagrant/master_images')
    print 'masters**************************'
    for filename in files:
        if '.tar' in filename:
            print(filename)
            newfilepath='/vagrant/master_images/'+filename
            os.system('sudo docker load -i %s'%newfilepath)