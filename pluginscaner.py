#!/usr/bin/python
# -*- encoding: utf-8 -*-
"""
Vim Plugins Update Scaner

Copyright (c) 2010 Dexter.Yy
Released under GPL Licenses.
"""

import sys, io, os, re
import pickle
import urllib
import json
from pyquery import PyQuery
from optparse import OptionParser


def main(argv=None):
    if argv is None:
        argv = sys.argv

    opt = OptionParser()
    (opt, args) = opt.parse_args()

    VIMHOME = os.getcwd()
    refname = '.pluginsref'
    ptable = {}

    os.chdir(VIMHOME)
    hasRef = os.path.exists(refname)
    if hasRef:
        ref = open(refname, 'rb')
        ptable = pickle.load(ref)
        ref.close()

    for pname in os.listdir(os.path.join(VIMHOME, 'plugin')):
        if not pname in ptable:
            ptable[pname] = {
                'name': re.sub(r"\.vim$", "", pname),
                'version': '0',
                'latest': '0',
                'url': '',
                'download': ''
            }


    if len(args) > 0:

        plugin = ptable.get(args[0] + ".vim", None)

        if not plugin:
            print 'Error: No available plugin for ' + args[0]
            return

        if plugin['version'] == plugin['latest']:
            print "Already up-to-date"
            return

        print "{name} {version} -> {latest}".format(**plugin)
        print "download url: {download}".format(**plugin)

        plugin['version'] = plugin['latest']
        plugin['download'] = ''

        ref = open(refname, 'wb')
        pickle.dump(ptable, ref)

        openBrowser = raw_input("Download from Browser (y/n)? ")
        if openBrowser == 'y':
            os.system('open ' + plugin['url'])

        return
    

    SEARCHAPI = "https://www.googleapis.com/customsearch/v1?key=AIzaSyCUaFs43lfy6X81Gohqx7Z5oWNgW5POHJM&cx=partner-pub-3005259998294962:bvyni59kjr1"
    SITEROOT = "http://www.vim.org/scripts/"

    outdated = []

    for plugin in ptable.values(): 

        if not plugin["url"]:

            result = urllib.urlopen(SEARCHAPI + "&q=" + plugin["name"])
            #print result.read()
            items = json.loads(result.read()).get("items", [])
            result.close()

            if len(items):
                plugin["url"] = items[0]["link"]

        if plugin["url"]:

            html = urllib.urlopen(plugin["url"]).read()
            pq = PyQuery(html)
            try:
                latest = pq(".rowodd").eq(0)
                latestVersion = latest.parent().find("td").eq(1).find("b").html()

                if not latestVersion == plugin["version"]:

                    plugin["download"] = SITEROOT + latest.find("a").attr("href")
                    plugin["latest"] = latestVersion

                    outdated.append(plugin)

            except Exception:

                plugin["version"] = '0'
                plugin["latest"] = '0'
                plugin["download"] = ''

                print Exception


    ref = open(refname, 'wb')
    pickle.dump(ptable, ref)

    if len(outdated):
        print "The following plugins were updated:"
        for p in outdated:
            print "{name} {version} < {latest}".format(**p)
    else:
        print "Already up-to-date"

    #print ptable

    #myplugins = []
    #for fname in vimfiles:
        #f = open(fname)
        #version = None 
        #for line in f:
            #verline = re.search(r"^\s*\"\s*Version:.+?([\d\.]+)", line, re.I)
            #if verline:
                #version = verline.group(1)
                #break
        #pname = re.sub(r"\.vim$", "", fname)
        #myplugins.append([pname, version])
    #print myplugins


if __name__ == "__main__":
    main()
