import tkinter as tk
from tkinter import scrolledtext, messagebox
from PIL import Image, ImageTk
import requests
from io import BytesIO
from dotenv import load_dotenv
import os

# Load environment variables from .env file
load_dotenv()

# Retrieve API key from environment variable
api_key = os.getenv('API_KEY')
if api_key is None:
    raise ValueError("API key not found. Please check your .env file.")

def get_recipes(ingredients):
    """Fetch recipes from Spoonacular API based on the ingredients."""
    url = "https://api.spoonacular.com/recipes/findByIngredients"
    params = {
        'ingredients': ','.join(ingredients),
        'number': 5,
        'apiKey': api_key
    }
    
    response = requests.get(url, params=params)
    
    if response.status_code != 200:
        messagebox.showerror("Error", f"Unable to fetch recipes. Status code {response.status_code}")
        return []
    
    return response.json()

def display_recipes(recipes, text_widget, image_label):
    """Display recipes in the text widget and show the first recipe's image."""
    text_widget.delete(1.0, tk.END)  # Clear previous content
    
    if not recipes:
        text_widget.insert(tk.END, "No recipes found.\n")
        return
    
    for idx, recipe in enumerate(recipes):
        title = recipe.get('title')
        used_ingredients = ', '.join([ing['name'] for ing in recipe['usedIngredients']])
        missing_ingredients = ', '.join([ing['name'] for ing in recipe['missedIngredients']])
        recipe_id = recipe.get('id')
        image_url = recipe.get('image')
        link = f"https://spoonacular.com/recipes/{title.replace(' ', '-').lower()}-{recipe_id}"
        
        text_widget.insert(tk.END, f"\nRecipe {idx + 1}: {title}\n")
        text_widget.insert(tk.END, f"Used ingredients: {used_ingredients}\n")
        text_widget.insert(tk.END, f"Missing ingredients: {missing_ingredients}\n")
        text_widget.insert(tk.END, f"Recipe link: {link}\n")
        
        if idx == 0 and image_url:  # Display the first recipe's image
            display_image(image_url, image_label)

def display_image(url, image_label):
    """Download and display an image from a URL in the provided label."""
    try:
        response = requests.get(url)
        response.raise_for_status()  # Check if the request was successful
        img_data = response.content
        img = Image.open(BytesIO(img_data))
        img = img.resize((200, 200))  # Resize the image to fit the label
        img_tk = ImageTk.PhotoImage(img)
        image_label.config(image=img_tk)
        image_label.image = img_tk  # Keep a reference to the image to prevent garbage collection
    except requests.exceptions.RequestException as e:
        messagebox.showerror("Error", f"Failed to load image: {e}")

def add_new_ingredient_entry():
    """Create a new entry widget for another ingredient."""
    new_entry = tk.Entry(ingredients_frame, width=50)
    new_entry.pack(padx=10, pady=5)
    ingredient_entries.append(new_entry)

def search_recipes():
    """Handle the search button click event."""
    ingredients = [entry.get().strip() for entry in ingredient_entries if entry.get().strip()]
    
    if not ingredients:
        messagebox.showwarning("Input Error", "Please enter at least one ingredient.")
        return
    
    recipes = get_recipes(ingredients)
    display_recipes(recipes, text_area, image_label)

# Create the main window
root = tk.Tk()
root.title("Recipe Finder")

# Create a frame to hold the ingredient entry widgets
ingredients_frame = tk.Frame(root)
ingredients_frame.pack(padx=10, pady=5)

ingredient_entries = []  # List to hold all entry widgets

# Add the first ingredient entry widget
add_new_ingredient_entry()

# Button to add new ingredient entry
add_button = tk.Button(root, text="+", command=add_new_ingredient_entry)
add_button.pack(padx=10, pady=5)

search_button = tk.Button(root, text="Search Recipes", command=search_recipes)
search_button.pack(padx=10, pady=5)

image_label = tk.Label(root)  # Label to display the image
image_label.pack(padx=10, pady=5)

text_area = scrolledtext.ScrolledText(root, width=80, height=20)
text_area.pack(padx=10, pady=10)

# Start the GUI event loop
root.mainloop()
