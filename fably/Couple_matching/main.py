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
            },
            "women" : {
                "casual": {
                    "top": ["Blouse", "Crop Top", "T-shirt"],
                    "bottom": ["Jeans", "Skirt", "Leggings"],
                    "shoes": ["Flats", "Sneakers"]
                },
                "formal": {
                    "top": ["Blazer", "Formal Blouse"],
                    "bottom": ["Pencil Skirt", "Dress Pants"],
                    "shoes": ["Heels", "Ballet Flats"]
                },
                "sporty": {
                    "top": ["Tank Top", "Sports Bra"],
                    "bottom": ["Leggings", "Shorts"],
                    "shoes": ["Running Shoes", "Trainers"]
                }
            }

        }
    
    def generate_outfit(self, style):
        if style not in self.clothing_items["men"] or style not in self.clothing_items["women"]:
            return "Invalid style. Choose from casual, formal, or sporty."
        
        men_outfit = {
            "top": random.choice(self.clothing_items["men"][style]["top"]),
            "bottom": random.choice(self.clothing_items["men"][style]["bottom"]),
            "shoes": random.choice(self.clothing_items["men"][style]["shoes"])
        }

        women_outfit = {
            "top": random.choice(self.clothing_items["women"][style]["top"]),
            "bottom": random.choice(self.clothing_items["women"][style]["bottom"]),
            "shoes": random.choice(self.clothing_items["women"][style]["shoes"])
        }

        return {"Men's Outfit": men_outfit, "Women's Outfit": women_outfit}