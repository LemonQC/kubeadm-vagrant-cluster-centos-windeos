#coding=utf-8
import re
import os
import subprocess

if __name__ == "__main__":
    files=os.listdir('/vagrant/node_images')
    print 'noes**************************'
    for filename in files:
        if '.tar' in filename:
            print(filename)
            newfilepath='/vagrant/node_images/'+filename
            os.system('sudo docker load -i %s'%newfilepath)