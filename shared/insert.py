from pymongo import MongoClient 
from datetime import datetime
import os
import sys

uri = sys.argv[1]

client = MongoClient(uri) 
collection = client.demo.data

message = {
    "message": "hello world"
}

collection.insert_one(message)