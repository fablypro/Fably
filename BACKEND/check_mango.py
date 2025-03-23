from pymongo import MongoClient

# Connect to MongoDB
client = MongoClient("mongodb://localhost:27017/")  # Change if needed
db = client["accessory_db"]  # Replace with your actual database name
collection = db["accessories"]  # Replace with your actual collection name

# Fetch all documents from the collection
documents = list(collection.find({}))

if documents:
    print("Accessories in MongoDB:")
    for doc in documents:
        print(doc)
else:
    print("No accessories found in MongoDB. Try running 'store_accessories.py'.")
