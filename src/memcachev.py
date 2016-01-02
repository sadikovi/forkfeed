#!/usr/bin/env python

from google.appengine.api import memcache

def set(key, value, namespace=""):
    keys = memcache.get(namespace)
    if not keys:
        keys = []
    keys.append(key)
    # save value for the key
    memcache.set(key=key, value=value, namespace=namespace)
    # save key for namespace
    memcache.set(key=namespace, value=keys)

def get(key, namespace=""):
    return memcache.get(key, namespace=namespace)

def get_all(namespace=""):
    keys = memcache.get(namespace)
    if not keys:
        return None
    data = memcache.get_multi(keys, namespace=namespace)
    # to be consistent with "keys", return None if no data found
    return None if not data else data

def delete(key, namespace=""):
    status = memcache.delete(key=key, namespace=namespace)
    return True if status == 2 else False
