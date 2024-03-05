#!/usr/bin/python3
#Aleksandra Jaroszek grupa 

import argparse
import sys
from password_manager import PasswordManager
from password_manager import load_zxcvbn
import os

def main():
    parser = argparse.ArgumentParser(description='Simple Password Manager.\n\nA simple command-line tool for managing passwords securely using the Vigenere cipher. The program operates on JSON files for storing passwords, which are located in the same directory as the program. (default: passwords.json - will be created during the first use of the program. It is recommended !not to delete! this file to avoid losing saved passwords.) \n\nRequirements:\n-Python 3\n-json \n-os \n-zxcvbn'
                                     )
    parser.add_argument('-f', '--file', metavar='filename', help='Specify JSON file to load or create. If not provided, operations will be performed on the default file (passwords.json), which will be created during the first use of the program. It is recommended !not to delete! this file to avoid losing saved passwords.')
    parser.add_argument('-a', '--add', nargs=2, metavar=('account', 'password'), help='Add a password/ Account name must be a single phrase.')
    parser.add_argument('-g', '--get', metavar='account', help='Get a password')
    parser.add_argument('-l', '--list', action='store_true', help='List all accounts')
    parser.add_argument('-o', '--order', choices=['asc', 'desc'], help='Sort the list of accounts alphabetically. Specify the sorting order as either "asc" (ascending) or "desc" (descending). If not provided, the list will be displayed in its default order. This option can only be used in conjunction with the `-l` or `--list` option.')
    parser.add_argument('-d', '--delete', metavar='account', help='Delete a password')
    parser.add_argument('-c', '--change', nargs=2, metavar=('account', 'new_password'), help='Change password for an account')
    parser.add_argument('-r', '--generate', nargs='?', const=12, type=int, metavar='length', help='Generate a random password')
    parser.add_argument('-w', '--write', metavar='account', help='Generate and write a random password for the account to a file')
    parser.add_argument('-s', '--strength', action='store_true', help='Check password strength. Can be used in conjunction with the following operations: add (-a, --add), get (-g, --get), change (-c, --change), generate (-r, --generate), write (-w, --write). Returns the password strength for the specified operation')
    
    args = parser.parse_args()

    zxcvbn = load_zxcvbn()
    if zxcvbn is None:
        print("\nError: The 'zxcvbn' module is required. Please install it.")
        sys.exit(1)

    args = parser.parse_args()
    if not any(vars(args).values()):
            print("No options provided.\n")
            print("Use -h or --help for usage information.\n")
            return
    
    try:
        executable_dir = os.path.dirname(os.path.abspath(__file__))
        key_file = os.path.join(executable_dir, 'key.key')

        if args.file:
            data_file = args.file
        else:
            data_file = 'passwords.json'

        data_file_path = os.path.join(executable_dir, data_file)
        password_manager = PasswordManager(data_file=data_file_path, key_file=key_file)

        if args.add:
            account, password = args.add
            password_strength = None
            if password_manager.add_password(account, password) != 0:
                if args.strength:
                    print("Password Strength:", password_manager.password_strength(password),"/ 4")
                if password_strength is not None:
                    print("Password Strength:", password_strength,"/ 4")
        if args.get:
            account = args.get
            password_strength = None
            password = password_manager.get_password(account)
            if(password != -1):
                print("Password:", password)
                if args.strength:
                        print("Password Strength:", password_manager.password_strength(password),"/ 4")
                if password_strength is not None:
                    print("Password Strength:", password_strength,"/ 4")
        if args.list:
            if args.order:
                if password_manager.passwords:
                    sorted_accounts = sorted(password_manager.passwords.keys(), reverse=(args.order == 'desc'))
                    print("Accounts:", ', '.join(sorted_accounts))
                else:
                    print("No accounts saved.")
            else:
                if password_manager.passwords:
                    print("Accounts:", ', '.join(password_manager.passwords.keys()))
                else:
                    print("No accounts saved.")
        if (args.order and not args.list):
            print("This option can only be used in conjunction with the `-l` or `--list` option")
        if args.delete:
            account = args.delete
            print(password_manager.delete_password(account))
        if args.change:
            account, new_password = args.change
            print(password_manager.change_password(account, new_password))
            if args.strength:
                print("Password Strength:", password_manager.password_strength(new_password),"/ 4")
        if args.generate is not None:
            length = args.generate
            if length < 8:
                print("Minimum length for generated password is 8.")
            else:
                random_password = password_manager.generate_random_password(length)
                print("Generated Password:", random_password)
                if args.strength:
                    print("Password Strength:", password_manager.password_strength(random_password),"/ 4")
        if args.write:
            account = args.write
            random_password = password_manager.write_password(account)
            if random_password != 0:
                if args.strength:
                    print("Password Strength:", password_manager.password_strength(random_password),"/ 4")
        
    except argparse.ArgumentError as e:
        print("Error:", e)
        parser.print_help()
        sys.exit(1)
        
if __name__ == "__main__":
    main()