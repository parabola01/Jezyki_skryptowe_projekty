#!/usr/bin/python3
#Aleksandra Jaroszek grupa 

import json
import string
import random
import os
def load_zxcvbn():
    try:
        from zxcvbn import zxcvbn
        return zxcvbn
    except ImportError:
        print("Can not import zxcvbn")
        return None
zxcvbn = load_zxcvbn()

class PasswordManager:
    def __init__(self, key_file='key.key', data_file='passwords.json'):
        self.key_file = key_file
        self.data_file = data_file
        if not os.path.exists(self.key_file):
            self.create_key_file()
        self.load_key()
        if not os.path.exists(self.data_file):
            self.create_data_file()
        self.load_passwords()
    
    def create_key_file(self):
        with open(self.key_file, 'w') as key_file:
            key_file.write('defaultkey')
    
    def create_data_file(self):
        with open(self.data_file, 'w') as data_file:
            data_file.write('{}')

    def load_key(self):
        try:
            with open(self.key_file, 'r') as key_file:
                self.key = key_file.read().strip()  
        except FileNotFoundError:
            self.key = 'defaultkey'  # Klucz domyślny
            with open(self.key_file, 'w') as key_file:
                key_file.write(self.key)

    def encrypt(self, password):
        encrypted_password = ''
        key_index = 0
        for char in password:
            key_char = self.key[key_index]
            encrypted_char = chr(((ord(char) + ord(key_char)) % 256))  
            encrypted_password += encrypted_char
            key_index = (key_index + 1) % len(self.key)  
        return encrypted_password

    def decrypt(self, encrypted_password):
        decrypted_password = ''
        key_index = 0
        for char in encrypted_password:
            key_char = self.key[key_index]
            decrypted_char = chr(((ord(char) - ord(key_char)) % 256))  
            decrypted_password += decrypted_char
            key_index = (key_index + 1) % len(self.key)  
        return decrypted_password

    def load_passwords(self):
        try:
            with open(self.data_file, 'r') as data_file:
                self.passwords = json.load(data_file)
        except FileNotFoundError:
            self.passwords = {}

    def save_passwords(self):
        with open(self.data_file, 'w') as data_file:
            json.dump(self.passwords, data_file)

    def add_password(self, account, password):
        if account in self.passwords:
            print("Password for {} already exists. Use --change option to update.".format(account))
            return 0
        elif len(account.split()) > 1:
            print("Account name must be a single phrase.")
            return 0
        else:
            encrypted_password = self.encrypt(password)
            self.passwords[account] = encrypted_password
            self.save_passwords()
            print("Password added successfully.")
            return 1

    def get_password(self, account):
        encrypted_password = self.passwords.get(account)
        if encrypted_password:
            return self.decrypt(encrypted_password)
        else:
            print("Account not found.")
            return -1

    def delete_password(self, account):
        if account in self.passwords:
            del self.passwords[account]
            self.save_passwords()
            return "Password for {} deleted.".format(account)
        else:
            return "Account not found."

    def change_password(self, account, new_password):
        if account in self.passwords:
            encrypted_password = self.encrypt(new_password)
            self.passwords[account] = encrypted_password
            self.save_passwords()
            return "Password for {} changed successfully.".format(account)
        else:
            return "Account not found."
        
    def generate_random_password(self, length=12):
        uppercase = string.ascii_uppercase
        lowercase = string.ascii_lowercase
        digits = string.digits
        punctuation = string.punctuation

        required_characters = [random.choice(uppercase),
                            random.choice(lowercase),
                            random.choice(digits),
                            random.choice(punctuation)]
        
        remaining_length = length - 4
        characters = uppercase + lowercase + digits + punctuation
        random_characters = ''.join(random.choice(characters) for _ in range(remaining_length))
        
        password = ''.join(required_characters) + random_characters
        
        password_list = list(password)
        random.shuffle(password_list)
        return ''.join(password_list)

    def password_strength(self, password):
        strength = zxcvbn(password)['score']
        return strength
    
    def write_password(self, account):
        if account in self.passwords:
            print("Password for {} already exists.".format(account))
            answer = input("Do you want to overwrite it? (yes/no): ").lower()
            if answer == 'yes':
                random_password = self.generate_random_password()
                self.passwords[account] = self.encrypt(random_password)
                self.save_passwords()
                print("New password for {} written to file: {}".format(account, random_password))
                return random_password
            else:
                print("Operation cancelled.")
        else:
            random_password = self.generate_random_password()
            self.add_password(account, random_password)
            print("Generated Password:", random_password)
            print("Password for", account, "written to file.")
            return random_password