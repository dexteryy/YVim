#!/usr/bin/env python
# -*- encoding: utf-8 -*-
"""
Vim Plugins Update Scaner

Copyright (c) 2010 Dexter.Yy
Released under GPL Licenses.
"""

import sys, os, re
import threading
import pickle
import urllib
import json
from pyquery import PyQuery
from optparse import OptionParser


class HttpPool():

    def __init__(self):
        self.workers = []
        self.lock = threading.Lock()

    def add(self, url, callback=None, args=()):
        lock = self.lock

        def asynHttpRequest(*args, **opt):
            result = urllib.urlopen(url)
            data = result.read()

            retry = opt.get("retry", 0)
            if not data and retry < 5:
                retry += 1
                return asynHttpRequest(*args, retry=retry)

            lock.acquire()

            if callback:
                callback({
                    "url": url,
                    "data": data
                }, *args)

            lock.release()

        self.workers.append(
            threading.Thread(target=asynHttpRequest, args=args)
        )

    def send(self):
        for w in self.workers:
            w.start()
        for w in self.workers:
            w.join()
        self.onComplete()

    def onComplete(self):
        pass


def main(argv=None):
    if argv is None:
        argv = sys.argv

    opt = OptionParser()
    (opt, args) = opt.parse_args()

    VIMHOME = os.getcwd()
    refname = '.pluginsref'
    pluginLib = {}

    os.chdir(VIMHOME)
    hasRef = os.path.exists(refname)
    if hasRef:
        ref = open(refname, 'rb')
        pluginLib = pickle.load(ref)
        ref.close()

    for pname in os.listdir(os.path.join(VIMHOME, 'plugin')):
        if not pname in pluginLib:
            pluginLib[pname] = {
                'name': re.sub(r"\.vim$", "", pname),
                'version': '0',
                'latest': '0',
                'url': '',
                'download': ''
            }

    if len(args) > 0:

        plugin = pluginLib.get(args[0] + ".vim", None)

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
        pickle.dump(pluginLib, ref)

        openBrowser = raw_input("Download from Browser (y/n)? ")
        if openBrowser == 'y':
            os.system('open ' + plugin['url'])

    else:

        SEARCHAPI = "https://www.googleapis.com/customsearch/v1?key=AIzaSyCUaFs43lfy6X81Gohqx7Z5oWNgW5POHJM&cx=partner-pub-3005259998294962:bvyni59kjr1"
        SITEROOT = "http://www.vim.org/scripts/"

        outdated = []

        searchPool = HttpPool()
        checkPool = HttpPool()

        def searchPlugin(res, plugin):
            print "search: ", plugin["name"]
            items = json.loads(res["data"]).get("items", [])
            if not len(items):
                return

            plugin["url"] = items[0]["link"]

            if plugin["url"]:
                checkVersion(plugin)

        def checkVersion(plugin):
            if not plugin["download"]:
                checkPool.add(plugin["url"],
                               callback=parseInfo,
                               args=(plugin,))
            else:
                outdated.append(plugin)

        def parseInfo(res, plugin):
            print "check: ", plugin["name"]
            backup = plugin.copy()
            try:
                pq = PyQuery(res["data"])
                latest = pq(".rowodd").eq(0)
                latestVersion = latest.parent().find("td").eq(1).find("b").html()

                if not latestVersion == plugin["version"]:

                    plugin["download"] = SITEROOT + latest.find("a").attr("href")
                    plugin["latest"] = latestVersion

                    outdated.append(plugin)

            except Exception:
                plugin.update(backup)
                print "Error: {name} parse error!".format(**plugin)

        def startCheck():
            checkPool.send()

        def onComplete():
            ref = open(refname, 'wb')
            pickle.dump(pluginLib, ref)

            if len(outdated):
                print "The following plugins were updated:"
                for p in outdated:
                    print "{name} {version} < {latest}".format(**p)
            else:
                print "Already up-to-date"

            #print pluginLib

        for plugin in pluginLib.values():
            if not plugin["url"]:
                searchPool.add(SEARCHAPI + "&q=" + plugin["name"],
                               callback=searchPlugin,
                               args=(plugin,))
            else:
                checkVersion(plugin)

        searchPool.onComplete = startCheck
        checkPool.onComplete = onComplete

        searchPool.send()

    #print pluginLib

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
