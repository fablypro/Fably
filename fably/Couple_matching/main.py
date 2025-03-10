import random

class OutfitMatcher:
    def __init__(self):
        self.clothing_items = {
            "men":{
                "casual":{
                    "top":["T-shirt","polo shirt","Casual shirt"],
                    "bottom":["jeans","chinos","Shorts"],
                    "shoes":["Sneakers","Loafers"]
                },
                "formal":{
                    "top":["Dress shirt","Blazer"],
                    "bottom":["Dress pants","Suit pants"],
                    "shoes":["Oxfords","Derby shoes"]
                },
                "sporty":{
                    "top":["Tank top","sporty jersey"],
                    "bottom":["Joggers","Shorts"],
                    "shoes":["Running shoes","Trainers"]
                }
            }

            
        }