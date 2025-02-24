from flask import Flask, request, render_template, redirect, url_for, flash, jsonify, session, abort, make_response
from flask_login import LoginManager, login_user, login_required, logout_user, current_user
from pymongo import MongoClient
from werkzeug.security import generate_password_hash, check_password_hash
from flask_wtf.csrf import CSRFProtect, generate_csrf
from bson import ObjectId
from datetime import datetime, timedelta
import hashlib
import config
from models import Seller
from werkzeug.utils import secure_filename
import os
from cloudinary.uploader import upload
from cloudinary.utils import cloudinary_url
from cloudinary.api import delete_resources_by_prefix
from flask import Flask, jsonify
from flask_pymongo import PyMongo
from flask_cors import CORS
import secrets
import hmac

import send_email as mail

reset_tokens = {}

def custom_cors_origin(origin):
    # Allow all origins
    return origin

app = Flask(__name__)
CORS(app, supports_credentials=True, origins="*")

app.secret_key = 'f46a1ac2564717c33df1b0dcd5f2b336'

app.config['UPLOAD_FOLDER'] = 'static/uploads'
if not os.path.exists(app.config['UPLOAD_FOLDER']):
    os.makedirs(app.config['UPLOAD_FOLDER'])

app.config['SECRET_KEY'] = config.SECRET_KEY
csrf = CSRFProtect(app)
app.config['DEBUG'] = True
app.config['WTF_CSRF_ENABLED'] = False

# MongoDB setup
client = MongoClient(config.MONGO_URI)
db = client.fably_db  # Database name
sellers_collection = db.sellers  # Seller/auth info
items_collection = db.items  # Item info
checkout_collection = db.checkouts  # Checkout data

orders_collection = db['orders']

customers_collection = db.customers

# Login manager setup
login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = 'login'

@login_manager.user_loader
def load_user(user_id):
    seller_data = sellers_collection.find_one({'_id': ObjectId(user_id)})
    return Seller(seller_data) if seller_data else None

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
            
        order_data ={
            "userId": session["user_id"],
            "items": user_cart,
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
    checkouts = list(checkout_collection.find({}, {"_id": 0}))  # Exclude MongoDB _id
    return jsonify(checkouts)

@app.route('/orders/', methods=['GET'])
@login_required
def get_orders():
    """Retrieve all checkout records (Admin Only)"""
    orders = list(orders_collection.find({}, {"_id": 0}))  # Exclude MongoDB _id
    
    return jsonify(orders)

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
            body = render_template('email_template/register_customer.html', name = request.form['name'])
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
            customer["_id"] = str(customer["_id"])

            return_data = {
                '_id': str(customer['_id']),
                'email': customer["email"],
                'name': ''
            }

            response = make_response(jsonify(return_data))
            #response.set_cookie('test','test_cookie', httponly=False, samesite='Lax', secure=False)
            
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
            body = render_template('email_templates/register_customer.html')
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
        print("return_cart:", return_cart)
        return jsonify(return_cart)
    
    except Exception as e:
        import traceback
        print(traceback.format_exc())
        return jsonify({"error": str(e)}), 500

@app.route('/get_wishlist/<user_id>/', methods=['GET'])
def get_wishlist_items(user_id):
    try:
        
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
        print("return_wishlist:", return_wishlist)
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


@app.route('/remove_from_cart/<user_id>/', methods=['GET', 'POST'])
def remove_cart_item(user_id):
    '''
accepts input: {'item_id':'1234', 'quantity':1}
TODO: add crsf token to the input
'''
    if request.method=='POST':
        try:
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
            
            '''
            email_text = "Dear Customer,<br><br>"
            email_text += "Given below is the url for your password reset. If you did not request this request then please ignore this email.<br>"
            email_text += f"Please note that the password expires at {expiry.day}-{expiry.month}-{expiry.year} {expiry.strftime("%I:%M:%S %p")}<br><br>"
            email_text += f"<a href=\"{reset_url}\" >Password Reset link</a>"
            '''
            
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
        return "Invalid request", 400
    
    if uid not in reset_tokens.keys():
        return "token not found", 404
    
    if datetime.now()> reset_tokens[uid]['expires']:
        return "Expired Token", 400
    
    if not verify_hash_value(token, reset_tokens[uid]['token']):
        return "Invalid Token", 400
    
       
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

def verify_hash_value(raw_value, hashed_value):
    hashed_user_token = hashlib.sha256(raw_value.encode()).hexdigest()
    if hmac.compare_digest(hashed_user_token, hashed_value) :
        return True
    else:
        return False

def customer_logged_in(user_id):
    if user_id=="":
        if "user_id" not in session.keys():
            return False
    else:
        if "user_id" not in session.keys() or user_id!=session["user_id"]:
            return False
    return True

if __name__ == '__main__':
    app.run(debug=True, use_reloader=False, host='0.0.0.0', port=5000)
