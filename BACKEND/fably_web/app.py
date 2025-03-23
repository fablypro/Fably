import base64
from io import BytesIO
from pathlib import Path
from flask import Flask, request, jsonify
from flask_cors import CORS
import numpy as np
import tensorflow as tf
import os
import bson  # Binary storage for MongoDB
from sklearn.metrics.pairwise import cosine_similarity
from db import accessory_collection  # Import MongoDB connection
from feature_extraction import extract_features
import stripe
import cloudinary
import cloudinary.uploader
from flask import Flask, json, request, render_template, redirect, url_for, flash, jsonify, session, abort, make_response
from flask_login import LoginManager, login_user, login_required, logout_user, current_user
from pymongo import MongoClient
import requests
from werkzeug.security import generate_password_hash, check_password_hash
from flask_wtf.csrf import CSRFProtect, generate_csrf
from bson import ObjectId
from datetime import datetime, timedelta
import time
import hashlib
import config
from models import Seller
from werkzeug.utils import secure_filename
import os
from cloudinary.uploader import upload
from cloudinary.utils import cloudinary_url
from cloudinary.api import delete_resources_by_prefix, delete_resources
from flask import Flask, jsonify
from flask_pymongo import PyMongo
from flask_cors import CORS
import secrets
import hmac
from PIL import Image, ExifTags
import threading
import copy
#import logging



import send_email as mail
import virtual_try_on
import vton
import check_url

reset_tokens = {}
vton_check_lock = threading.Lock()
vton_lock = threading.Lock()
cloudinary_credentials = [
    config.CLOUDINARY_CLOUD_NAME,
    config.CLOUDINARY_API_KEY,
    config.CLOUDINARY_API_SECRET
]

cloudinary2_credentials = [
    config.CLOUDINARY_CLOUD_NAME2,
    config.CLOUDINARY_API_KEY2,
    config.CLOUDINARY_API_SECRET2
]

def custom_cors_origin(origin):
    # Allow all origins
    return origin

app = Flask(__name__)
CORS(app, supports_credentials=True, origins="*")

app.secret_key = 'f46a1ac2564717c33df1b0dcd5f2b336'
stripe.api_key = "sk_test_51QxRgVG8IzWoJC0qhizvf6sBgpfEErQexvGlhomL0tRoM18uQymCwi4SweGupBhHijqkFSjfAqes9vJW3s70PPKj00jqzDNXtl"


app.config['UPLOAD_FOLDER'] = 'static/uploads'
if not os.path.exists(app.config['UPLOAD_FOLDER']):
    os.makedirs(app.config['UPLOAD_FOLDER'])

app.config['SECRET_KEY'] = config.SECRET_KEY
csrf = CSRFProtect(app)
app.config['DEBUG'] = True
app.config['WTF_CSRF_ENABLED'] = False
#logging.basicConfig(level=logging.WARNING)

# MongoDB setup
client = MongoClient(config.MONGO_URI)
db = client.fably_db  # Database name
sellers_collection = db.sellers  # Seller/auth info
items_collection = db.items  # Item info
checkout_collection = db.checkouts  # Checkout data

orders_collection = db['orders']
vtons_collection = db['vtons']

customers_collection = db.customers

# Login manager setup
login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = 'login'

@login_manager.user_loader
def load_user(user_id):
    seller_data = sellers_collection.find_one({'_id': ObjectId(user_id)})
    return Seller(seller_data) if seller_data else None


UPLOAD_FOLDER = "uploads"
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

# Allowed file types for uploads
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif'}

@app.after_request
def add_cors_headers(response):
    #response.headers['Access-Control-Allow-Origin'] = 'http://localhost:3000'  # Replace with your Flutter app's origin
    response.headers['Access-Control-Allow-Credentials'] = 'true'
    response.headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization'
    response.headers['Access-Control-Allow-Methods'] = 'GET, POST, OPTIONS'
    return response

def clean_invalid_from_cart():
    user = customers_collection.find_one({'_id': ObjectId(session["user_id"])})
    user_cart = user['cart']

    if len(user_cart)>0:
        for i in range(len(user_cart)):
            item = user_cart[i]
            try:
                item_product = items_collection.find_one({'_id': ObjectId(item['_id'])})# product info corrosponding to id
                if(item['quantity']==0):
                    result = customers_collection.update_one(
                        {"_id": session["user_id"]},# Filter the user by id
                        {"$pull": {"cart": item}}  # Remove the item from the cart array
                    )
                    continue
            except:
                result = customers_collection.update_one(
                    {"_id": session["user_id"]},  # Filter the user by id
                    {"$pull": {"cart": item}}  # Remove the item from the cart array
                )
                continue

@app.route('/get-csrf-token', methods=['GET'])
def get_csrf_token():# temporary solution
    token = generate_csrf()
    return jsonify({"csrf_token": token})

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@app.route('/')
def home():
    return render_template('index.html')

# ---------------- CHECKOUT FUNCTIONALITY ----------------

@app.route('/checkout', methods=['POST'])
def checkout():
    """Handles checkout form submission from Flutter"""
    try:
        if not verify_csrf(request.headers.get('X-CSRFToken')):
            return "Unauthorised CSRF!", 400

        if not customer_logged_in(""):
            print("Unauthorised")
            return "Unauthorised!", 400
        
        
        data = request.get_json()

        print (session["user_id"])
        
        # Validate required fields
        if not all(key in data for key in ["name", "address", "phone", "postalCode"]):
            return jsonify({"error": "Missing required fields"}), 400
        
        checkout_data = {
            "name": data["name"],
            "address": data["address"],
            "phone": data["phone"],
            "postalCode": data["postalCode"],
            "timestamp": datetime.now()
        }

        clean_invalid_from_cart()
        user = customers_collection.find_one({'_id': ObjectId(session["user_id"])})
        user_cart = user['cart']
        
        order_items = copy.deepcopy(user_cart)

        if len(order_items)>0:
            for i in range(len(order_items)):
                item = order_items[i]
                item_product = items_collection.find_one({'_id': ObjectId(item['_id'])})
                order_items[i]['price'] = item_product['price']
                order_items[i]['name'] = item_product['name']
                order_items[i]['seller_id'] = str(item_product['seller_id'])


        order_data = {
            "userId": session["user_id"],
            "items": order_items,
            "checkoutInfo": checkout_data,
            "orderDate": datetime.now()
        }
            
        orders_collection.insert_one(order_data)
        customers_collection.update_one(
            {"_id": ObjectId(session["user_id"])},  
            {"$set": {"cart": []}}
        )

        return_cart = []
        print('user_cart:',user_cart)
        if len(user_cart)>0:
            for i in range(len(user_cart)):
                item = user_cart[i]
                item_product = items_collection.find_one({'_id': ObjectId(item['_id'])})
                item_product["quantity"] = item["quantity"] # add the quantity attribute.
                item_product["_id"] = str(item_product["_id"]) # convert objectid to string
                item_product["seller_id"] = str(item_product["seller_id"]) # convert objectid to string
                return_cart.append(item_product)

        '''
        total_cost = 0
        email_text = "Dear Customer,<br><br>"
        email_text += "Your order was created successfully!<br><br>"
        email_text += "<table border=1>"
        email_text += "<tr><th>Image</th><th>Item</th><th>Unit Price</th><th>Quantity</th><th>Sum</th></tr>"
        for item in return_cart:
            total_cost += item["quantity"]*item["price"]
            email_text += f"<tr><td><img src=\"{item["photos"][0]}\" alt=\"Product Image\" height=100 style=\"display:block; margin:auto;\" \"></td><td>{item["name"]}</td><td>${item["price"]}</td><td>X {item["quantity"]}</td><td>${item["quantity"]*item["price"]}</td></tr>"
        email_text += f"<tr><th colspan=4>Total</th><th>{total_cost}</th></tr>"
        email_text += "</table>"
        '''
        total_cost = sum(item["quantity"] * item["price"] for item in return_cart)
        email_text = render_template('email_templates/order_confirmation.html', return_cart = return_cart, total_cost = total_cost)

        mail.send_email(session["email"], "Fably Checkout successful", email_text)
        return jsonify({"message": "Checkout successful!"}), 201
    
    except Exception as e:
        import traceback
        print(traceback.format_exc())
        print(e)
        return jsonify({"error": str(e)}), 400

@app.route('/checkouts', methods=['GET'])
@login_required
def get_checkouts():
    """Retrieve all checkout records (Admin Only)"""

    if not verify_csrf(request.headers.get('X-CSRFToken')):
        return "Unauthorised CSRF!", 400
    
    checkouts = list(checkout_collection.find({}, {"_id": 0}))  # Exclude MongoDB _id
    return jsonify(checkouts)

@app.route('/orders/', methods=['GET'])
@login_required
def get_orders():
    """Retrieve all checkout records (Admin Only)"""
    orders = list(orders_collection.find({}, {"_id": 0}))  # Exclude MongoDB _id
    
    return jsonify(orders)


### User Orders
@app.route('/customer_orders/<user_id>/', methods=['POST'])
def get_user_orders(user_id):
    if not verify_csrf(request.headers.get('X-CSRFToken')):
        return "Unauthorised CSRF!", 400
    
    if not customer_logged_in(user_id):
        return "Unauthorised!", 400

    """Retrieve all orders of user"""
    orders = list(orders_collection.find({"userId":user_id}))

    for o in range(len(orders)):
        order_total = 0
        for i in range(len(orders[o]['items'])):
            item = orders[o]['items'][i]
            item_removed = False
            try:
                item_product = items_collection.find_one({'_id': ObjectId(item['_id'])})
                if item_product == None:
                    item_removed=True

            except:
                continue
            order_total += item["quantity"]*item["price"]
        orders[o]["total"] = order_total
        orders[o]["_id"] = str(orders[o]["_id"])
        orders[o]["orderDate"] = orders[o]["orderDate"].strftime("%d-%m-%Y")
    print("orders", orders)

    return jsonify(orders), 200
### User Orders

### User Order
@app.route('/customer_orders_items/<user_id>/', methods=['POST'])
def get_user_order_items(user_id):

    if not verify_csrf(request.headers.get('X-CSRFToken')):
        return "Unauthorised CSRF!", 400

    if not customer_logged_in(user_id):
        return "Unauthorised!", 400

    data = request.get_json()
    order_id = data["order_id"]

    """Retrieve all items of user order"""
    orders = list(orders_collection.find({"userId":user_id, "_id": ObjectId(order_id)}))

    return_order = {}

    return_order["orderDate"] = str(orders[0]["orderDate"].strftime("%d-%m-%Y"))
    return_order["_id"] = str(orders[0]["_id"])
    return_order['checkoutInfo'] = {}


    return_items = []

    for i in range(len(orders[0]['items'])):
        item = orders[0]['items'][i]
        item_removed = False
        return_item = {}
        try:
            item_product = items_collection.find_one({'_id': ObjectId(item['_id'])})
            if item_product==None:
                item_removed = True

        except Exception as e:
            print(e)
            item_removed = True
        return_item["quantity"] = item["quantity"]
        return_item["_id"] = str(item["_id"])
        return_item["price"] = item["price"]
        return_item["name"] = item["name"]
        
        if (item_removed): # if the item has been removed from the shop
            return_item["name"] += " (Removed)"
            return_item["photos"] = [""]
        else:
            return_item["photos"] = item_product["photos"]

        return_items.append(return_item)
    import json
    return_order["items"] = return_items
    print("return_order", json.dumps(return_order, indent = 4))

    return jsonify(return_order), 200
### User Order

app.route("/create-payment-intent", methods=["POST"])
def create_payment():
    try:
        data = request.json
        amount = data.get("amount")  # Amount in cents (e.g., 1000 for $10.00)

        if not amount:
            return jsonify({"error": "Amount is required"}), 400

        # Create a PaymentIntent with Stripe
        intent = stripe.PaymentIntent.create(
            amount=amount,
            currency="usd",
            payment_method_types=["card"],
        )
        return jsonify({"clientSecret": intent.client_secret})

    except Exception as e:
        return jsonify({"error": str(e)}), 500


# ---------------- SELLER & ITEM MANAGEMENT (UNCHANGED) ----------------
@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        existing_user = sellers_collection.find_one({'email': request.form['email']})
        
        if existing_user is None:
            hashed_password = generate_password_hash(request.form['password'])
            sellers_collection.insert_one({
                'name': request.form['name'],
                'email': request.form['email'],
                'password': hashed_password,
                'phone': request.form['phone'],
                'created_date': datetime.now()
            })
            '''body = f"""Hello, {request.form['name']}

Thank you for Signing Up to Fably!
""" '''
            body = render_template('email_templates/register_seller.html', name = request.form['name'])
            mail.send_email(request.form["email"], "Registration to Fably", body)
            flash('Registration successful! Please login.', 'success')
            return redirect(url_for('login'))
        
        flash('Email already exists!', 'error')
    return render_template('register.html')

#csrf.exempt(register)

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        seller = sellers_collection.find_one({'email': request.form['email']})
        
        if seller and check_password_hash(seller['password'], request.form['password']):
            user_obj = Seller(seller)
            login_user(user_obj)
            return redirect(url_for('dashboard'))
            
        flash('Invalid email or password!', 'error')
    return render_template('login.html')
#csrf.exempt(login)

@app.route('/login_customer', methods=['GET', 'POST'])
def login_customer():
    if request.method == 'POST':
        customer = customers_collection.find_one({'email': request.get_json()['email'].strip()})
        
        if customer and check_password_hash(customer['password'], request.get_json()['password']):
            session["type"] = "Customer"
            session["email"] = customer["email"]
            session["user_id"] = str(customer["_id"])
            session["csrf"] = str(request.headers.get('X-CSRFToken'))
            customer["_id"] = str(customer["_id"])

            return_data = {
                '_id': str(customer['_id']),
                'email': customer["email"],
                'name': customer["fname"] + " " + customer["lname"],
                'fname': customer["fname"],
                'lname': customer["lname"]
            }

            response = make_response(jsonify(return_data))
            
            return response, 200
            
    return "Invalid email or password!", 401

@app.route('/check_logged_in')
def checkLoggedIn():
    if "type" in session:
        if session["type"] == "Customer":
            return "LoggedIn", 200

    if "user_id" in session:
        if session["user_id"] != '':
            return "LoggedIn", 200

    return "LoggedOut", 401

@app.route('/register_customer', methods=['GET', 'POST'])
def register_customer():
    if request.method == 'POST':
        existing_user = customers_collection.find_one({'email': request.get_json()['email'].strip()})
        
        if existing_user is None:
            hashed_password = generate_password_hash(request.get_json()['password'])
            customers_collection.insert_one({
                #'name': request.get_json()['name'],
                'fname': request.get_json()['first_name'].strip(),
                'lname': request.get_json()['last_name'].strip(),
                'email': request.get_json()['email'].strip(),
                'password': hashed_password,
                'created_date': datetime.now(),
                'cart':[],
                'wishlist':[]
            })
            body = f"""Hello, Customer<br>

Thank you for Signing Up to Fably!
"""
            body = render_template('email_templates/register_customer.html', name=request.get_json()['first_name'].strip())
            mail.send_email(request.get_json()["email"].strip(), "Registration to Fably", body)
            
            return "Success!", 200
    return "Already Exists", 400

@app.route('/logout')
@login_required
def logout():
    if 'type' in session.keys():
        if session['type'] == "Customer":
            #logout_user()
            session.clear()
            return {"message":"Logged out succesfully!"}, 200
    logout_user()
    session.clear()
    return redirect(url_for('login'))

@app.route('/dashboard')
@login_required
def dashboard():
    seller_id = ObjectId(current_user.id) if isinstance(current_user.id, str) else current_user.id
    items = db.items.find({'seller_id': seller_id})
    return render_template('dashboard.html', items=items)


@app.route('/categories')
def get_categories():
    """Get all categories and subcategories"""
    categories = list(db.categories.find({}, {'_id': 1, 'name': 1, 'subcategories': 1}))
    return jsonify(categories)

# Add Items to DB
@app.route('/item/add', methods=['GET', 'POST'])
@login_required
def add_item():
    if request.method == 'POST':
        name = request.form.get('name')
        description = request.form.get('description')
        price = float(request.form.get('price'))
        category = request.form.get('category')
        stock_quantity = int(request.form.get('stock_quantity'))
        
        # Handle photo uploads
        photos = []
        if 'photos' in request.files:
            files = request.files.getlist('photos')
            for file in files:
                if file and allowed_file(file.filename):
                    upload_result = upload(file)
                    photos.append(upload_result['secure_url'])
        
        # Create item document
        item_data = {
            'seller_id': ObjectId(current_user.id),
            'name': name,
            'description': description,
            'price': price,
            'category': category,
            'photos': photos,
            'stock_quantity': stock_quantity,
            'created_at': datetime.now(),
            'updated_at': datetime.now()
        }
        
        db.items.insert_one(item_data)
        flash('Item added successfully!', 'success')
        return redirect(url_for('dashboard'))
    
    categories = list(db.categories.find())
    return render_template('add_item.html', categories=categories)


@app.route("/edit_item/<item_id>", methods=["GET", "POST"])
@login_required
def edit_item(item_id):
    item = items_collection.find_one({"_id": ObjectId(item_id)})
    
    if not item or item.get('seller_id') != ObjectId(current_user.id):
        flash('Item not found or you do not have permission to edit it.', 'error')
        return redirect(url_for("dashboard"))
    
    categories = list(db.categories.find())

    if request.method == "POST":
        updated_data = {
            "name": request.form.get("name"),
            "description": request.form.get("description"),
            "price": float(request.form.get("price")),
            "category": request.form.get("category"),
            "stock_quantity": int(request.form.get("stock_quantity")),
            "updated_at": datetime.now()
        }
        
        result = items_collection.update_one(
            {
                "_id": ObjectId(item_id), 
                "seller_id": ObjectId(current_user.id)
            }, 
            {"$set": updated_data}
        )
        
        flash('Item updated successfully!' if result.modified_count > 0 else 'No changes made.', 'success')
        return redirect(url_for("dashboard"))

    return render_template("edit_item.html", item=item, categories=categories)

@app.route("/delete_item/<item_id>", methods=["POST"])
@login_required
def delete_item(item_id):
    item = items_collection.find_one({"_id": ObjectId(item_id), "seller_id": ObjectId(current_user.id)})
    
    if not item:
        flash('Item not found.', 'error')
        return redirect(url_for("dashboard"))

    # Delete Cloudinary images
    for img_url in item.get('photos', []):
        public_id = img_url.split("/")[-1].split(".")[0]  # Extract public ID
        delete_resources_by_prefix(public_id)

    # Delete from MongoDB
    result = items_collection.delete_one({"_id": ObjectId(item_id)})
    
    flash('Item deleted successfully!' if result.deleted_count else 'Item not found.', 'success')
    return redirect(url_for("dashboard"))

# returns the items as a JSON response
@app.route('/products', methods=['GET'])
def get_products():
    try:
        # Fetch the items from the collection
        items = list(items_collection.find({}, {"_id": 1, "name": 1, "price": 1, "photos": 1, "description": 1, "category": 1, "stock_quantity": 1}))  # Example: also include other fields like 'name' or 'price'
        
        # Convert ObjectId to string
        for item in items:
            item["_id"] = str(item["_id"])
        
        return jsonify(items)
    
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route('/get_cart/<user_id>/', methods=['GET'])
def get_cart_items(user_id):
    try:

        if not verify_csrf(request.headers.get('X-CSRFToken')):
            return "Unauthorised CSRF!", 400
        
        if not customer_logged_in(user_id):
            return "Unauthorised!", 400
        
        # Fetch the user cart
        user = customers_collection.find_one({'_id': ObjectId(user_id)})
        user_cart = user["cart"]

        return_cart = []
        print('user_cart:',user_cart)
        if len(user_cart)>0:
            for i in range(len(user_cart)):
                item = user_cart[i]
                try:
                    item_product = items_collection.find_one({'_id': ObjectId(item['_id'])})# product info corrosponding to id
                    if(item['quantity']==0):
                        result = customers_collection.update_one(
                            {"_id": ObjectId(session["user_id"])},  # Filter the user by id
                            {"$pull": {"cart": item}}  # Remove the item from the cart array
                        )
                        continue
                except:
                    result = customers_collection.update_one(
                        {"_id": ObjectId(session["user_id"])},  # Filter the user by id
                        {"$pull": {"cart": item}}  # Remove the item from the cart array
                    )
                    continue
                item_product["quantity"] = item["quantity"] # add the quantity attribute.
                item_product["_id"] = str(item_product["_id"]) # convert objectid to string
                item_product["seller_id"] = str(item_product["seller_id"]) # convert objectid to string
                return_cart.append(item_product)
        #print("return_cart:", return_cart)
        return jsonify(return_cart)
    
    except Exception as e:
        import traceback
        print(traceback.format_exc())
        return jsonify({"error": str(e)}), 500

@app.route('/get_wishlist/<user_id>/', methods=['GET'])
def get_wishlist_items(user_id):
    try:
        if not verify_csrf(request.headers.get('X-CSRFToken')):
            return "Unauthorised CSRF!", 400
        
        if not customer_logged_in(user_id):
            return "Unauthorised!", 400
        
        # Fetch the user cart
        user = customers_collection.find_one({'_id': ObjectId(user_id)})

        if "wishlist" not in user.keys():
            customers_collection.update_one(
                {'_id': ObjectId(user_id)},  # Match the user
                {'$set': {'wishlist': []}}   # Add an empty wishlist
            )
            user = customers_collection.find_one({'_id': ObjectId(user_id)})
        user_wishlist = user["wishlist"]


        return_wishlist = []
        print('user_wishlist:',user_wishlist)
        if len(user_wishlist)>0:
            for i in range(len(user_wishlist)):
                item = user_wishlist[i]
                try:
                    item_product = items_collection.find_one({'_id': ObjectId(item)})# product info corrosponding to id
                    if item_product==None:
                        user_wishlist.pop(i)
                        result = customers_collection.update_one(
                            {"_id": ObjectId(session["user_id"])},  # Filter the user by id
                            {"$pull": {"wishlist": item}}  # Remove the item from the cart array
                        )
                        continue
                except Exception as e:
                    print("item_produc fetching exception",e)
                    result = customers_collection.update_one(
                        {"_id": ObjectId(session["user_id"])},  # Filter the user by id
                        {"$pull": {"wishlist": item}}  # Remove the item from the cart array
                    )
                    continue
                item_product['_id'] = str(item_product["_id"])
                item_product["seller_id"] = str(item_product["seller_id"])
                return_wishlist.append(item_product)
        #print("return_wishlist:", return_wishlist)
        return jsonify(return_wishlist)
    
    except Exception as e:
        import traceback
        print(traceback.format_exc())
        return jsonify({"error": str(e)}), 500



@app.route('/add_to_cart/<user_id>/', methods=['GET', 'POST'])
def add_cart_item(user_id):
    '''
accepts input: {'item_id':'1234', 'quantity':1}
TODO: add crsf token to the input
'''
    if request.method=='POST':
        try:
            if not verify_csrf(request.headers.get('X-CSRFToken')):
                return "Unauthorised CSRF!", 400

            if not customer_logged_in(user_id):
                return "Unauthorised!", 400
            
            # Fetch the user cart
            print("Fetch the user cart")
            user = customers_collection.find_one({'_id': ObjectId(user_id)})

            if not user:
                return "Error: User not found", 404
            
            cart = user["cart"]

            item_id = request.get_json()["item_id"].strip()
            quantity = request.get_json()["quantity"]

            print("Item Id:",item_id)
            item_found = False
            try:
                item = items_collection.find_one({'_id': ObjectId(item_id)})

                print(item)
            except Exception as e:
                print(e)
                item = None;
            
            if not item:
                return "Error: Item not found", 404
            
            for i in range(len(cart)):
                if cart[i]['_id'] == item_id:
                    cart[i]['quantity'] += quantity  # Update the quantity
                    item_found = True
                    break

            if not item_found:
                # Add a new item to the cart
                cart.append({"_id": item_id, "quantity": quantity})

            customers_collection.update_one(
                {'_id': ObjectId(user_id)},
                {'$set': {'cart': cart}}
            )

            return "Success!", 200
        
        except Exception as e:
            import traceback
            print(traceback.format_exc())
            return ("error: "+str(e)), 500
    return abort(404)


@app.route('/add_to_wishlist/<user_id>/', methods=['GET', 'POST'])
def add_wishlist_item(user_id):
    '''
accepts input: {'item_id':'1234'}
TODO: add crsf token to the input
'''
    if request.method=='POST':
        try:
            if not verify_csrf(request.headers.get('X-CSRFToken')):
                return "Unauthorised CSRF!", 400

            if not customer_logged_in(user_id):
                return "Unauthorised!", 400
            
            # Fetch the user
            print("Fetch the user wishlist")
            user = customers_collection.find_one({'_id': ObjectId(user_id)})

            #check if user exists
            if not user:
                return "Error: User not found", 404
            
            wishlist = user["wishlist"]

            item_id = request.get_json()["item_id"]

            print("Item Id:",item_id)

            #check if item exists
            try:
                item = items_collection.find_one({'_id': ObjectId(item_id)})

                print(item)
            except Exception as e:
                print(e)
                item = None;
            
            if not item:
                return "Error: Item not found", 404

            # Check if item is already in wishlist. if so do not add.
            if item_id in wishlist:
                return "Already Exists", 200
            else:
                wishlist.append(item_id)
                
            customers_collection.update_one(
                {'_id': ObjectId(user_id)},
                {'$set': {'wishlist': wishlist}}
            )

            return "Success!", 200
        
        except Exception as e:
            import traceback
            print(traceback.format_exc())
            return ("error: "+str(e)), 500
    return abort(404)

@app.route('/add_review/<user_id>/', methods=['GET', 'POST'])
def add_review(user_id):
    '''
accepts input: {'item_id':'1234', 'rating':5, 'review':'Good product'}
TODO: add crsf token to the input
'''
    if request.method=='POST':
        try:
            if not verify_csrf(request.headers.get('X-CSRFToken')):
                return "Unauthorised CSRF!", 400

            if not customer_logged_in(user_id):
                return "Unauthorised!", 400
            
            # Fetch the user
            print("Fetch the user wishlist")
            user = customers_collection.find_one({'_id': ObjectId(user_id)})

            #check if user exists
            if not user:
                return "Error: User not found", 404

            item_id = request.get_json()["item_id"]
            rating = request.get_json()["rating"]
            review = request.get_json()["review"]


            try:
                item = items_collection.find_one({'_id': ObjectId(item_id)})

                if not item:
                    return "Error: Item not found", 404
            except:
                return "Error: Item not found", 404
            
            if "reviews" not in item.keys():
                item["reviews"] = {}
                item["review_count"] = 0
                item["rating_sum"] = 0

            reviews = item["reviews"]
            
            reviews[user_id] = {
                "user_id": user_id,
                "rating": rating,
                "review": review
            }

            item['review_count'] = len(reviews)
            item['rating_sum'] = item['rating_sum'] = sum([reviews[r]["rating"] for r in reviews.keys()])

            items_collection.update_one(
                {'_id': ObjectId(item_id)},
                {'$set': {'reviews': reviews, 'review_count': item['review_count'], 'rating_sum': item['rating_sum']}}
            )
            
            return "Success!", 200
        
        except Exception as e:
            import traceback
            print(traceback.format_exc())
            return ("error: "+str(e)), 500
    return abort(404)

@app.route('/get_reviews/', methods=['GET', 'POST'])
def get_reviews():
    '''
accepts input: {'item_id':'1234', 'rating':5, 'review':'Good product'}
TODO: add crsf token to the input
'''
    if request.method=='POST':
        try:
            if not verify_csrf(request.headers.get('X-CSRFToken')):
                return "Unauthorised CSRF!", 400

            if not customer_logged_in(''):
                return "Unauthorised!", 400
            
            item_id = request.get_json()["item_id"]

            try:
                item = items_collection.find_one({'_id': ObjectId(item_id)})

                if not item:
                    return "Error: Item not found", 404
            except:
                return "Error: Item not found", 404
            
            if "reviews" not in item.keys():
                item["reviews"] = {}
                item["review_count"] = 0
                item["rating_sum"] = 0

            reviews = item["reviews"]

            return_reviews = {}
            
            for i in reviews.keys():
                try:
                    user = customers_collection.find_one({'_id': ObjectId(reviews[i]["user_id"])})

                    if not user:
                        reviews.pop(i)
                        item['review_count'] -= 1
                        item['rating_sum'] -= reviews[i]["rating"]
                        continue
                except:
                    return "Error: User not found", 404
                return_reviews[i] = {}
                return_reviews[i]["user_id"] = str(reviews[i]["user_id"])
                return_reviews[i]["rating"] = reviews[i]["rating"]
                return_reviews[i]["review"] = reviews[i]["review"]
                return_reviews[i]["user_name"] = user["fname"] + " " + user["lname"]

            item['review_count'] = len(return_reviews)
            item['rating_sum'] = sum([return_reviews[r]["rating"] for r in return_reviews.keys()])

            items_collection.update_one(
                {'_id': ObjectId(item_id)},
                {'$set': {'reviews': reviews, 'review_count': item['review_count'], 'rating_sum': item['rating_sum']}}
            )
            
            return jsonify(return_reviews), 200
        
        except Exception as e:
            import traceback
            print(traceback.format_exc())
            return ("error: "+str(e)), 500
    return abort(404)

@app.route('/get_review_average/', methods=['GET', 'POST'])
def get_review_average():
    '''
accepts input: {'item_id':'1234', 'rating':5, 'review':'Good product'}
TODO: add crsf token to the input
'''
    if request.method=='POST':
        try:
            if not verify_csrf(request.headers.get('X-CSRFToken')):
                return "Unauthorised CSRF!", 400

            if not customer_logged_in(''):
                return "Unauthorised!", 400
            
            item_id = request.get_json()["item_id"]

            try:
                item = items_collection.find_one({'_id': ObjectId(item_id)})

                if not item:
                    return "Error: Item not found", 404
            except:
                return "Error: Item not found", 404
            
            if "reviews" not in item.keys():
                item["reviews"] = {}
                item["review_count"] = 0
                item["rating_sum"] = 0

            reviews = item["reviews"]
            
            for i in reviews.keys():
                try:
                    user = customers_collection.find_one({'_id': ObjectId(reviews[i]["user_id"])})

                    if not user:
                        reviews.pop(i)
                        item['review_count'] -= 1
                        item['rating_sum'] -= reviews[i]["rating"]
                except Exception as e:
                    import traceback
                    print(traceback.format_exc())
                    return f"Error: {e}", 404
                

            items_collection.update_one(
                {'_id': ObjectId(item_id)},
                {'$set': {'reviews': reviews, 'review_count': item['review_count'], 'rating_sum': item['rating_sum']}}
            )
            
            return jsonify({"review_count":item["review_count"], "rating_sum":item["rating_sum"]}), 200
        
        except Exception as e:
            import traceback
            print(traceback.format_exc())
            return ("error: "+str(e)), 500
    return abort(404)


@app.route('/remove_from_cart/<user_id>/', methods=['GET', 'POST'])
def remove_cart_item(user_id):
    '''
accepts input: {'item_id':'1234', 'quantity':1}
TODO: add crsf token to the input
'''
    if request.method=='POST':
        try:
            if not verify_csrf(request.headers.get('X-CSRFToken')):
                return "Unauthorised CSRF!", 400

            if not customer_logged_in(user_id):
                return "Unauthorised!", 400
            
            # Fetch the user cart
            print("Fetch the user cart")
            user = customers_collection.find_one({'_id': ObjectId(user_id)})

            if not user:
                return "Error: User not found", 404
            
            cart = user["cart"]

            item_id = request.get_json()["item_id"]
            quantity = request.get_json()["quantity"]

            item = items_collection.find_one({'_id': ObjectId(item_id)})
            
            if not item:
                return "Error: Item not found", 404
            
            for i in range(len(cart)):
                if cart[i]['_id'] == item_id:
                    cart[i]['quantity'] -= quantity  # Update the quantity
                    if cart[i]['quantity']<1:
                        cart.pop(i)
                    break

            customers_collection.update_one(
                {'_id': ObjectId(user_id)},
                {'$set': {'cart': cart}}
            )

            return "Success!", 200
        
        except Exception as e:
            import traceback
            print(traceback.format_exc())
            return ("error: "+str(e)), 500
    return abort(404)

@app.route('/remove_from_wishlist/<user_id>/', methods=['GET', 'POST'])
def remove_wishlist_item(user_id):
    '''
accepts input: {'item_id':'1234', 'quantity':1}
'''
    if request.method=='POST':
        try:
            if not verify_csrf(request.headers.get('X-CSRFToken')):
                return "Unauthorised CSRF!", 400

            if not customer_logged_in(user_id):
                return "Unauthorised!", 400
            
            # Fetch the user
            print("Fetch the user wishlist")
            user = customers_collection.find_one({'_id': ObjectId(user_id)})

            #check if user exists
            if not user:
                return "Error: User not found", 404
            
            wishlist = user["wishlist"]

            item_id = request.get_json()["item_id"]

            item = items_collection.find_one({'_id': ObjectId(item_id)})
            #check if item exists
            if not item:
                return "Error: Item not found", 404
            
            if item_id not in wishlist:
                return "Not Exists", 200
            else:
                wishlist.remove(item_id)

            customers_collection.update_one(
                {'_id': ObjectId(user_id)},
                {'$set': {'wishlist': wishlist}}
            )

            return "Success!", 200
        
        except Exception as e:
            import traceback
            print(traceback.format_exc())
            return ("error: "+str(e)), 500
    return abort(404)

@app.route('/in_wishlist/<user_id>/', methods=['GET', 'POST'])
def in_wishlist(user_id):
    '''
accepts input: {'item_id':'1234', 'quantity':1}
'''
    if request.method=='POST':
        try:
            if not verify_csrf(request.headers.get('X-CSRFToken')):
                return "Unauthorised CSRF!", 400

            if not customer_logged_in(user_id):
                return "Unauthorised!", 400
            
            # Fetch the user
            print("Fetch the user wishlist")
            user = customers_collection.find_one({'_id': ObjectId(user_id)})

            #check if user exists
            if not user:
                return "Error: User not found", 404
            
            wishlist = user["wishlist"]

            item_id = request.get_json()["item_id"]

            item = items_collection.find_one({'_id': ObjectId(item_id)})
            #check if item exists
            if not item:
                return "Error: Item not found", 404

            # check if item is in wishlist
            if item_id not in wishlist:
                print("false")
                return "false", 200
            else:
                print("true")
                return "true", 200
        
        except Exception as e:
            import traceback
            print(traceback.format_exc())
            return ("error: "+str(e)), 500
    return abort(404)

@app.route('/forgot_password', methods = ['POST'])
def forgot_password():
    if request.method == 'POST':
        try:
            email = request.get_json()['email'].strip()

            # Fetch the user
            try:
                customer = customers_collection.find_one({'email': email})
            
            except Exception as e:
                print(e)
                return "No such customer", 404

            if (str(customer['_id']) in reset_tokens.keys()):
                if (reset_tokens[str(customer['_id'])]['expires']>datetime.now()):
                    print("token already sent")
                    return "Email already sent", 200
            
            # code to generate a token and email the url belongin to that token to the customer
            raw_token = secrets.token_urlsafe(32)
            hashed_token = hashlib.sha256(raw_token.encode()).hexdigest()

            # Save token to the database with expiry
            expiry = datetime.now() + timedelta(hours=1)  # Token valid for 1 hour
            
            reset_tokens[str(customer['_id'])] = {
                'token':hashed_token, 
                'expires':expiry
            }

            reset_url = url_for('password_reset', _external=True, token=raw_token, uid=str(customer['_id']))
            
            email_text = render_template('email_templates/password_reset.html', expiry = expiry, reset_url = reset_url)

            mail.send_email(customer['email'], 'Reset Fably Password', email_text)

            return "Success!", 200

        except Exception as e:
            print("Error:",e)
            return "An Unexpected error occured", 500

    return "Wrong method", 500

@app.route('/password_reset', methods = ['GET', 'POST'])
def password_reset():
    token = request.args.get('token')
    uid = request.args.get('uid')

    if not token or not uid:
        return render_template("reset_password/invalid_link.html"), 400
    
    if uid not in reset_tokens.keys():
        return render_template("reset_password/missing_token.html"), 404
    
    if datetime.now()> reset_tokens[uid]['expires']:
        return render_template("reset_password/expired_token.html"), 400
    
    if not verify_hash_value(token, reset_tokens[uid]['token']):
        return render_template("reset_password/invalid_token.html"), 400
    
       
    # code to return the reset password page.
    if request.method == 'POST':
        # Extract form data
        new_password = request.form.get('new_password')
        confirm_password = request.form.get('confirm_password')

        # Validate passwords
        if new_password != confirm_password:
            return "Passwords do not match", 400

        # Update the user's password in the database
        hashed_password = generate_password_hash(new_password)
        uid = request.args.get('uid')  # Extract UID from the query parameter
        customers_collection.update_one({'_id': ObjectId(uid)}, {'$set': {'password': hashed_password}})

        return render_template("password_reset_success.html"), 200
    
    return render_template("reset_password.html"), 200

@app.route('/virtual_try_on', methods = ['POST'])
def virtual_try_on_endpoint():
    # Save the original configuration
    
    cloudinary.config(
        cloud_name=config.CLOUDINARY_CLOUD_NAME,
        api_key=config.CLOUDINARY_API_KEY,
        api_secret=config.CLOUDINARY_API_SECRET
    )

    if not verify_csrf(request.headers.get('X-CSRFToken')):
        return "Unauthorised CSRF!", 400

    if not customer_logged_in(""):
        return "Unauthorised!", 400
    
    try:
        # Get the ID from the form data
        item_id = request.get_json()['item_id']
        if not item_id:
            return 'Item ID is required', 400

        # Get the Base64-encoded image
        image_data = request.get_json()['image']
        if not image_data:
            return 'Error: Image file is required', 400
        
        # Decode the Base64 image
        try:
            image = Image.open(BytesIO(base64.b64decode(image_data)))
        except Exception as e:
            return 'Invalid image data', 400
        
        root_folder = f"try_ons/{session['user_id']}"

        folder_path = Path(root_folder+"/inputs")

        if not folder_path.exists():
            folder_path.mkdir(parents=True, exist_ok=True)
            print(f"Folder created: {folder_path}")
        else:
            print(f"Folder already exists: {folder_path}")

        folder_path = Path(root_folder+"/outputs")

        if not folder_path.exists():
            folder_path.mkdir(parents=True, exist_ok=True)
            print(f"Folder created: {folder_path}")
        else:
            print(f"Folder already exists: {folder_path}")

        # Save the image file (optional)
        image.save(f'{root_folder}/inputs/person.png', format="PNG")
        # fetched person image and added to the inputs folder

        item = items_collection.find_one({'_id': ObjectId(item_id)})

        image2 = fetch_image_from_cloudinary(item['photos'][0])

        image2.save(f'{root_folder}/inputs/cloth.png', format="PNG")
        #||| added image of the cloth to the inputs folder

        # virtual try on processing starts here

        # temporary code to copy the person image to the outputs folder
        debug = False
        if 'debug' in request.get_json():
            if request.get_json()['debug'].lower() == 'true':
                print("Debug mode")
                debug = True

        if debug:
            image.save(f'{root_folder}/outputs/output.png', format="PNG")

        else:

            result_text = virtual_try_on.tryOn(root_folder)

            if result_text != "Success":
                import traceback
                print(traceback.format_exc())
                return result_text, 500

            try:
                with Image.open(f'{root_folder}/outputs/output_image.webp') as img:
                    img.save(f'{root_folder}/outputs/output.png', format="PNG")
                print(f"Image successfully converted to {f'{root_folder}/outputs/output.png'}")
                os.remove(f'{root_folder}/outputs/output_image.webp')
            except Exception as e:
                import traceback
                print(traceback.format_exc())
                print(f"An error occurred while converting webP to PNG: {e}")
                return f"An error occurred while converting webP to PNG: {e}", 500

        #||| virtual try on processing ends here with the output image saved in the outputs folder

        user = customers_collection.find_one({'_id': ObjectId(session["user_id"])})

        if "virtualTryOns" not in user.keys():
            user["virtualTryOns"] = {}
        
        if item_id in user["virtualTryOns"].keys():
            try:
                delete_cloudinary_image(user["virtualTryOns"][item_id]['publicId'])
            except Exception as e:
                print(e)
            user["virtualTryOns"][item_id] = {}
            print("Deleted previous image")
        user["virtualTryOns"][item_id] = {}
        
        user["virtualTryOns"][item_id]["publicId"] = upload_image_to_cloudinary(f"{root_folder}/outputs/output.png")
        image_secure_url = generate_secure_cloudinary_url(user["virtualTryOns"][item_id]["publicId"])
        print("URL:",image_secure_url)
        print("Uploaded new image:", user["virtualTryOns"][item_id]["publicId"])

        customers_collection.update_one(
            {'_id': ObjectId(session["user_id"])},  # Query to find the user
            {'$set': {'virtualTryOns': user["virtualTryOns"]}}  # Update the `virtualTryOns` field
        )
        try:
            os.remove(f'{root_folder}/inputs/cloth.png')
        except Exception as e:
            print(e)
        try:
            os.remove(f'{root_folder}/inputs/person.png')
        except Exception as e:
            print(e)
        try:
            os.remove(f'{root_folder}/outputs/output.png')
        except Exception as e:
            print(e)
        try:
            os.remove(f'{root_folder}/outputs/blank_white_output.png')
        except Exception as e:
            print(e)

        #||| uploaded the image to cloudinary
        

        return image_secure_url
        #return f'Image and ID received successfully | id : {item_id} ', 200
    except Exception as e:
        import traceback
        print(traceback.format_exc())
        print('Error: ' + str(e))
        return 'Error: ' + str(e), 500

@app.route('/vton_history/')
def vton_history():
    cloudinary.config(
        cloud_name=config.CLOUDINARY_CLOUD_NAME,
        api_key=config.CLOUDINARY_API_KEY,
        api_secret=config.CLOUDINARY_API_SECRET
    )

    if not verify_csrf(request.headers.get('X-CSRFToken')):
        return "Unauthorised CSRF!", 400

    if not customer_logged_in(""):
        return "Unauthorised!", 400
    
    try:
        user = customers_collection.find_one({'_id': ObjectId(session["user_id"])})

        vton = user["virtualTryOns"]

        return_vton = []

        for product_id in vton.keys():
            try:
                item = items_collection.find_one({'_id': ObjectId(product_id)})
                if item==None:
                    personImage = user["virtualTryOns"][product_id]['personImage']
                    vtonPhoto = user["virtualTryOns"][product_id]['vtonPhoto']
                    delete_cloudinary_image(personImage)
                    delete_cloudinary_image(vtonPhoto, cloudCredentials=cloudinary2_credentials)
                    
                    result = customers_collection.update_one(
                        {"_id": ObjectId(session["user_id"])},  # Filter the user by id
                        {"$unset": {f"virtualTryOns.{product_id}": ""}}  # Remove the item from the cart array
                    )
                    continue
            except Exception as e:
                import traceback
                print(traceback.format_exc())
                print('Error: ' + str(e))
                continue
            vton[product_id]['name'] = item["name"]
            vton[product_id]['itemId'] = product_id
            vton[product_id]['clothPhoto'] = item["photos"][0]
            vton[product_id]['personPhoto'] = generate_secure_cloudinary_url(vton[product_id]['personImage'])
            vton[product_id]['imageUrl'] = generate_secure_cloudinary_url(vton[product_id]['vtonPhoto'], cloudCredentials=cloudinary2_credentials)
            #print("Vton:", json.dumps(vton, indent=4))

            #TEST
            #vton[product_id]['status'] = "processing"

            return_vton.append(vton[product_id])
            #print(return_vton)
        
        return jsonify(return_vton)

    except Exception as e:
        import traceback
        print(traceback.format_exc())
        print('Error: ' + str(e))
        return "Error", 500

    return jsonify({})

@app.route('/virtual_try_on_v2', methods = ['POST'])
def virtual_try_on_endpoint_two():
    # Save the original configuration
    
    cloudinary.config(
        cloud_name=config.CLOUDINARY_CLOUD_NAME,
        api_key=config.CLOUDINARY_API_KEY,
        api_secret=config.CLOUDINARY_API_SECRET
    )

    if not verify_csrf(request.headers.get('X-CSRFToken')):
        return "Unauthorised CSRF!", 400

    if not customer_logged_in(""):
        return "Unauthorised!", 400
        
    try:

        with vton_lock:
            # Get the ID from the form data
            item_id = request.get_json()['item_id']
            if not item_id:
                return 'Item ID is required', 400

            # Get the Base64-encoded image
            image_data = request.get_json()['image']
            if not image_data:
                return 'Error: Image file is required', 400
            
            # Decode the Base64 image
            try:
                image = Image.open(BytesIO(base64.b64decode(image_data)))
            except Exception as e:
                return 'Invalid image data', 400
            
            image = handle_image_orientation(image)

            if image==None:
                return 'Error orienting image', 500
            
            root_folder = f"try_ons/{session['user_id']}"

            folder_path = Path(root_folder+"/inputs")

            if not folder_path.exists():
                folder_path.mkdir(parents=True, exist_ok=True)
                print(f"Folder created: {folder_path}")
            else:
                print(f"Folder already exists: {folder_path}")

            folder_path = Path(root_folder+"/outputs")

            if not folder_path.exists():
                folder_path.mkdir(parents=True, exist_ok=True)
                print(f"Folder created: {folder_path}")
            else:
                print(f"Folder already exists: {folder_path}")

            # Save the image file (optional)
            image.save(f'{root_folder}/inputs/person.jpg', format="JPEG")
            # fetched person image and added to the inputs folder
            compress_image(f'{root_folder}/inputs/person.jpg', f'{root_folder}/inputs/person.jpg')
            # Compress image

            item = items_collection.find_one({'_id': ObjectId(item_id)})

            cloth_url = item['photos'][0]

            # virtual try on processing starts here

            # temporary code to copy the person image to the outputs folder
            debug = False
            if 'debug' in request.get_json():
                if request.get_json()['debug'].lower() == 'true':
                    print("Debug mode")
                    debug = True
            user = customers_collection.find_one({'_id': ObjectId(session["user_id"])})

            if "vtonCount" not in user.keys():
                user["vtonCount"] = 0
            user["vtonCount"] +=1

            if user["vtonCount"]>5:
                print("TryOn Limit reached")
                return "TryOn Limit reached", 400
            
            customers_collection.update_one(
                {'_id': ObjectId(session["user_id"])},  # Query to find the user
                {'$set': {'vtonCount': user["vtonCount"]}}  # Update the `vtonCount` count
            )
            
            if debug:
                #image.save(f'{root_folder}/outputs/output.png', format="PNG")
                webhook_url = url_for('vton_webhook', _external=True)
                print("Sleeping")
                time.sleep(10)
                print(f"webhook_url: {webhook_url}")
                return "https://res.cloudinary.com/dcmelcukm/image/upload/v1740397581/Fably_ruvxxh.png", 201

            else:
                
                person_public_id = upload_image_to_cloudinary(f'{root_folder}/inputs/person.jpg')
                person_url = generate_secure_cloudinary_url(person_public_id)
                webhook_url = url_for('vton_webhook', _external=True)
                print(f"webhook_url: {webhook_url}")
                vton_id = vton.tryOn(cloth_url, person_url, webhook_url)

                if vton_id == "Error":
                    import traceback
                    print(traceback.format_exc())
                    return vton_id, 500

                # Check for try on result
                vton_record = {'vtonId': vton_id, 'status':'processing'}
                vtons_collection.insert_one(vton_record)

            #||| virtual try on processing ends here with the output image saved in the outputs folder
            user = customers_collection.find_one({'_id': ObjectId(session["user_id"])})

            if "virtualTryOns" not in user.keys():
                try:
                    delete_cloudinary_image(user["virtualTryOns"][item_id]['personImage'])
                except Exception as e:
                    print(e)
                try:
                    delete_cloudinary_image(user["virtualTryOns"][item_id]['vtonPhoto'])
                except Exception as e:
                    print(e)
                user["virtualTryOns"] = {}
            if item_id in user["virtualTryOns"].keys():
                try:
                    delete_cloudinary_image(user["virtualTryOns"][item_id]['personImage'])
                except Exception as e:
                    print(e)
                try:
                    delete_cloudinary_image(user["virtualTryOns"][item_id]['vtonPhoto'], cloudCredentials=cloudinary2_credentials)
                except Exception as e:
                    print(e)
                user["virtualTryOns"][item_id] = {}
                print("Deleted previous images")
            user["virtualTryOns"][item_id] = {}
            
            user["virtualTryOns"][item_id]["vtonId"] = vton_id
            user["virtualTryOns"][item_id]["personImage"] = person_public_id
            user["virtualTryOns"][item_id]["status"] = "processing"

            print("Generating new image:", user["virtualTryOns"][item_id]["vtonId"])

            customers_collection.update_one(
                {'_id': ObjectId(session["user_id"])},  # Query to find the user
                {'$set': {'virtualTryOns': user["virtualTryOns"]}}  # Update the `virtualTryOns` field
            )
            try:
                os.remove(f'{root_folder}/inputs/person.jpg')
            except Exception as e:
                print(e)
            
            #||| uploaded the image to cloudinary
            
            return vton_id
            #return f'Image and ID received successfully | id : {item_id} ', 200
    except Exception as e:
        import traceback
        print(traceback.format_exc())
        print('Error: ' + str(e))
        return 'Error: ' + str(e), 500

@app.route("/vton/webhook/", methods = ['POST'])
def vton_webhook():
    try:
        result = request.get_json()

        if result['error'] != None:
            print("Error")
            print(result)
            print("An Error occured while generating the image")
            return "", 200
        
        vton_item = vtons_collection.find_one({'vtonId': result['id']})
        vton_item['url'] = result['output'][0]

        vtons_collection.update_one(
            {'vtonId': result['id']},
            {'$set': {'url': vton_item['url'], 'status': 'completed'}}
        )

        return "", 200
    
    except Exception as e:
        import traceback
        print(traceback.format_exc())
        print('Error: ' + str(e))
        return "", 200
    
    return "", 200

@app.route("/vton/fetch_url/", methods = ['POST'])
def vton_fetch_url():
    try:

        if not verify_csrf(request.headers.get('X-CSRFToken')):
            return "Unauthorised CSRF!", 400

        if not customer_logged_in(""):
            return "Unauthorised!", 400
        

        result = request.get_json()

        vton_id = result['vton_id']
        item_id = result['item_id']
        print("Start VTON")
        with vton_check_lock:
            try:
                vton_item = vtons_collection.find_one({'vtonId': result['vton_id']})
            except Exception as e:
                import traceback
                print(traceback.format_exc())
                return "Error", 500
            
            # ALTERNATE SOLUTION
            _url = f"https://cdn.fashn.ai/{result['vton_id']}/output_0.png"
            user = customers_collection.find_one({'_id': ObjectId(session["user_id"])})
            if vton_item['status']=='completed':
                if user["virtualTryOns"][item_id]['status']=='completed':
                    print("already completed url")
                    return_url = generate_secure_cloudinary_url(user["virtualTryOns"][item_id]["vtonPhoto"], cloudCredentials=cloudinary2_credentials)
                    print(return_url)
                    return return_url, 200
                return "fetching", 403
            if (check_url.check_image(_url)):
                vton_item['status']='completed'
                vton_item['url']=_url

                vton_change = {}
                vton_change['status'] = vton_item['status']
                vton_change['url'] = vton_item['url']

                vtons_collection.update_one(
                    {'vtonId': result['vton_id']},
                    {'$set': vton_change}
                )

            # ALTERNATE SOLUTION END

            if (vton_item["status"]=="processing"):
                return "processing", 200

            # get VTON url
            vton_url = vton_item['url']

            root_folder = f"try_ons/{session['user_id']}"

            folder_path=Path(root_folder+"/outputs")

            if not folder_path.exists():
                folder_path.mkdir(parents=True, exist_ok=True)
                print(f"Folder created: {folder_path}")
            else:
                print(f"Folder already exists: {folder_path}")
            

            # Add url to the user record
            user = customers_collection.find_one({'_id': ObjectId(session["user_id"])})
            
            # download image from FASHN
            download_image(vton_url, f'{root_folder}/outputs/output.png')
            # Compress image
            compress_image(f'{root_folder}/outputs/output.png', f'{root_folder}/outputs/output.jpg')
            # delete previous image in cloudinary
            try:
                delete_cloudinary_image(
                    user["virtualTryOns"][item_id]["vtonPhoto"], 
                    cloudCredentials=cloudinary2_credentials
                )
            except Exception as e:
                print(e)
            # Upload to cloudinary and get publicId
            vton_cloudinary_id = upload_image_to_cloudinary(
                f'{root_folder}/outputs/output.jpg', 
                folder="vton_result", 
                cloudCredentials=cloudinary2_credentials
            )

            try:
                os.remove(f'{root_folder}/outputs/output.png')
            except Exception as e:
                print(e)
            try:
                os.remove(f'{root_folder}/outputs/output.jpg')
            except Exception as e:
                print(e)
            

            # save publicId to vtonPhoto
            user["virtualTryOns"][item_id]["vtonPhoto"] = vton_cloudinary_id

            user["virtualTryOns"][item_id]["url"] = vton_url
            user["virtualTryOns"][item_id]["status"] = "completed"

            customers_collection.update_one(
                {'_id': ObjectId(session["user_id"])},  # Query to find the user
                {'$set': {'virtualTryOns': user["virtualTryOns"]}}  # Update the `virtualTryOns` field
            )
            return_url = generate_secure_cloudinary_url(
                user["virtualTryOns"][item_id]["vtonPhoto"], 
                cloudCredentials=cloudinary2_credentials
            )
            print(vton_url)
            print(return_url)
            if not return_url:
                return_url=""
            return return_url, 200

    except Exception as e:
        import traceback
        print(traceback.format_exc())
        print('Error: ' + str(e))
        return "Error", 500

def fetch_image_from_cloudinary(url):
    """
    Fetches an image from Cloudinary using its public ID.

    Args:
        public_id (str): The public ID of the image in Cloudinary.
        cloud_name (str): The name of your Cloudinary account.

    Returns:
        Image object: PIL.Image object of the fetched image.
    """
    cloudinary_url = url

    try:
        # Make the GET request to Cloudinary
        response = requests.get(cloudinary_url)
        response.raise_for_status()  # Raise an exception for HTTP errors

        # Load the image into a PIL Image object
        image = Image.open(BytesIO(response.content))
        return image

    except requests.exceptions.RequestException as e:
        print(f"Error fetching the image: {e}")
        return None

def generate_secure_cloudinary_url(public_id, cloudCredentials = cloudinary_credentials):
    expiration = int(time.time()) + 3600  # URL valid for 1 hour
    url, _ = cloudinary_url(
        public_id,
        type='authenticated',  # For authenticated resources
        sign_url=True,
        expires_at=expiration,  # Optional: Expiration timestamp
        cloud_name=cloudCredentials[0],
        api_key=cloudCredentials[1],
        api_secret=cloudCredentials[2]
    )
    return url

def delete_cloudinary_image(publicId, cloudCredentials = cloudinary_credentials):
    public_id = publicId
    #public_id = url.split("/")[-1].split(".")[0]  # Extract public ID
    #delete_resources_by_prefix(public_id)
    response = cloudinary.uploader.destroy(
        public_id, 
        type="authenticated",
        cloud_name=cloudCredentials[0],
        api_key=cloudCredentials[1],
        api_secret=cloudCredentials[2]
        )  # Delete the exact resource
    print(f"Deleted image with public ID: {public_id}, Response: {response}")

def upload_image_to_cloudinary(image_path, folder="", cloudCredentials = cloudinary_credentials):
    """
    Uploads an image to Cloudinary.
    """
    try:
        # Open the image file in binary mode
        with open(image_path, "rb") as image_file:
            # Upload the image to Cloudinary
            upload_result = upload(
                image_file, 
                type='authenticated',
                folder=folder,
                cloud_name=cloudCredentials[0],
                api_key=cloudCredentials[1],
                api_secret=cloudCredentials[2]
                )
        
        # Return the secure URL of the uploaded image
        return upload_result['public_id']
    except Exception as e:
        print(f"Error uploading image to Cloudinary: {e}")
        return None

def verify_hash_value(raw_value, hashed_value):
    hashed_user_token = hashlib.sha256(raw_value.encode()).hexdigest()
    if hmac.compare_digest(hashed_user_token, hashed_value) :
        return True
    else:
        return False

def verify_csrf(csrf):
    if csrf == session["csrf"]:
        return True
    return False

def customer_logged_in(user_id):
    if user_id=="":
        if "user_id" not in session.keys():
            return False
    else:
        if "user_id" not in session.keys() or user_id!=session["user_id"]:
            return False
    return True

def compress_image(input_path, output_path, quality=85, max_width=1000, max_height=1280):
    try:
        # Open the image
        image = Image.open(input_path)

        # Handle EXIF orientation (ensure correct orientation)
        try:
            for orientation in ExifTags.TAGS.keys():
                if ExifTags.TAGS[orientation] == 'Orientation':
                    break
            exif = image._getexif()
            if exif is not None:
                orientation_value = exif.get(orientation, 1)
                if orientation_value == 3:
                    image = image.rotate(180, expand=True)
                elif orientation_value == 6:
                    image = image.rotate(270, expand=True)
                elif orientation_value == 8:
                    image = image.rotate(90, expand=True)
        except (AttributeError, KeyError, IndexError):
            # EXIF data not present or couldn't be processed
            pass

        # Resize image if necessary
        if max_width and max_height:
            image.thumbnail((max_width, max_height), Image.Resampling.LANCZOS)

        # Convert to RGB if the image is in a different mode (e.g., "P" or "RGBA")
        if image.mode in ("RGBA", "P"):
            image = image.convert("RGB")

        # Save the compressed image as JPG
        image.save(output_path, format="JPEG", optimize=True, quality=quality)
        print(f"Image saved and compressed successfully at: {output_path}")

    except Exception as e:
        print(f"Error compressing image: {e}")

def download_image(image_url, save_path):
    """
    Downloads an image from a given URL and saves it to the specified path.

    :param image_url: The URL of the image to download.
    :param save_path: The local path where the image will be saved.
    """
    try:
        # Send a GET request to the image URL
        response = requests.get(image_url, stream=True)
        response.raise_for_status()  # Raise an exception for HTTP errors
        
        # Write the image content to a file
        with open(save_path, "wb") as file:
            for chunk in response.iter_content(1024):
                file.write(chunk)
        
        print(f"Image downloaded and saved to {save_path}")
    except requests.exceptions.RequestException as e:
        print(f"Error downloading image: {e}")


def handle_image_orientation(image):
    """
    Adjusts the orientation of a PIL.Image object based on its EXIF data.
    
    Parameters:
        image (PIL.Image.Image): The image to process.
    
    Returns:
        PIL.Image.Image: The correctly oriented image.
    """
    try:
        # Handle EXIF orientation
        try:
            for orientation in ExifTags.TAGS.keys():
                if ExifTags.TAGS[orientation] == 'Orientation':
                    break
            exif = image._getexif()
            if exif is not None:
                orientation_value = exif.get(orientation, 1)
                if orientation_value == 3:
                    image = image.rotate(180, expand=True)
                elif orientation_value == 6:
                    image = image.rotate(270, expand=True)
                elif orientation_value == 8:
                    image = image.rotate(90, expand=True)
        except (AttributeError, KeyError, IndexError):
            # EXIF data not present or couldn't be processed
            pass

        return image

    except Exception as e:
        print(f"Error handling image orientation: {e}")
        return None

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
