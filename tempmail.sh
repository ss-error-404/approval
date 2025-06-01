#!/data/data/com.termux/files/usr/bin/bash

# === Tempmail CLI using 1secmail.com API ===

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
  echo "📧 Generated Email: $email"
}

# Fetch inbox safely
get_inbox() {
  echo -e "\n📥 Checking inbox for $email..."
  response=$(curl -s "${BASE_URL}?action=getMessages&login=$login&domain=$domain")
  echo "$response" | jq empty 2>/dev/null
  if [ $? -ne 0 ]; then
    echo "❌ Error: Response is not valid JSON:"
    echo "$response"
  else
    echo "$response" | jq .
  fi
}

# Read a message by ID
read_email() {
  read -p "✉️  Enter message ID to read: " msgid
  echo -e "\n📖 Reading message ID $msgid..."
  response=$(curl -s "${BASE_URL}?action=readMessage&login=$login&domain=$domain&id=$msgid")
  echo "$response" | jq empty 2>/dev/null
  if [ $? -ne 0 ]; then
    echo "❌ Error: Response is not valid JSON:"
    echo "$response"
  else
    echo "$response" | jq .
  fi
}

# Main menu
main() {
  echo "==============================="
  echo "     TEMPMAIL CLI TOOL"
  echo "==============================="
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
      3) echo "👋 Goodbye!"; break ;;
      *) echo "❗ Invalid option" ;;
    esac
  done
}

main
