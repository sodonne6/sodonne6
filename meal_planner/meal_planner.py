import requests
from dotenv import load_dotenv
import os
import tkinter


# Load environment variables from .env file
load_dotenv()

# Retrieve API key from environment variable
api_key = os.getenv('API_KEY')

# Function to get recipes from Spoonacular API
def get_recipes(ingredients):
    url = f"https://api.spoonacular.com/recipes/findByIngredients"
    params = {
        'ingredients': ','.join(ingredients),
        'number': 5,  # Number of recipes to return
        'apiKey': api_key
    }
    
    response = requests.get(url, params=params)
    
    if response.status_code != 200:
        print(f"Error: Unable to fetch recipes. Status code {response.status_code}")
        return []
    
    return response.json()

# Function to display recipe details
def display_recipes(recipes):
    if not recipes:
        print("No recipes found.")
        return
    
    for idx, recipe in enumerate(recipes):
        title = recipe.get('title')
        used_ingredients = ', '.join([ing['name'] for ing in recipe['usedIngredients']])
        missing_ingredients = ', '.join([ing['name'] for ing in recipe['missedIngredients']])
        recipe_id = recipe.get('id')
        link = f"https://spoonacular.com/recipes/{title.replace(' ', '-').lower()}-{recipe_id}"
        
        print(f"\nRecipe {idx + 1}: {title}")
        print(f"Used ingredients: {used_ingredients}")
        print(f"Missing ingredients: {missing_ingredients}")
        print(f"Recipe link: {link}")

# Main function to run the script
def main():
    print("Welcome to the Recipe Finder!")
    ingredients_input = input("Enter the ingredients you have, separated by commas: ")
    ingredients = [ingredient.strip() for ingredient in ingredients_input.split(',')]
    
    if not ingredients:
        print("No ingredients provided.")
        return
    
    recipes = get_recipes(ingredients)
    display_recipes(recipes)

if __name__ == "__main__":
    main()

