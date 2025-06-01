#!/data/data/com.termux/files/usr/bin/bash

# === Tempmail CLI using 1secmail API ===

BASE_URL="https://www.1secmail.com/api/v1/"
CHARS="abcdefghijklmnopqrstuvwxyz1234567890"

# Generate random email
generate_email() {
  name=""
  for i in {1..10}; do
    index=$((RANDOM % ${#CHARS}))
    name="$name${CHARS:$index:1}"
  done
  login="$name"
  domain="1secmail.com"
  email="$login@$domain"
  echo "Generated Email: $email"
}

# Get inbox messages
get_inbox() {
  echo -e "\nFetching inbox for $email..."
  curl -s "${BASE_URL}?action=getMessages&login=$login&domain=$domain" | jq .
}

# Read a specific message
read_email() {
  read -p "Enter message ID to read: " msgid
  echo -e "\nFetching message ID $msgid..."
  curl -s "${BASE_URL}?action=readMessage&login=$login&domain=$domain&id=$msgid" | jq .
}

# Main menu
main() {
  echo "=== TEMPMAIL CLI ==="
  generate_email
  while true; do
    echo -e "\nOptions:"
    echo "1. Check Inbox"
    echo "2. Read Message"
    echo "3. Exit"
    read -p "Select: " opt
    case $opt in
      1) get_inbox ;;
      2) read_email ;;
      3) break ;;
      *) echo "Invalid option" ;;
    esac
  done
}

main
