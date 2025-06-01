#!/data/data/com.termux/files/usr/bin/bash

# === TEMPMAIL ADVANCED CLI (1secmail.com) ===

BASE_URL="https://www.1secmail.com/api/v1/"
CHARS="abcdefghijklmnopqrstuvwxyz1234567890"
CHECK_INTERVAL=10  # seconds between inbox refreshes

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
  echo "📧 Generated Temp Email: $email"

  # Copy email to clipboard
  if command -v termux-clipboard-set >/dev/null; then
    echo -n "$email" | termux-clipboard-set
    echo "📋 Email copied to clipboard."
  fi
}

# Safe inbox fetch
get_inbox() {
  echo -e "\n📥 Checking inbox for $email..."
  response=$(curl -s "${BASE_URL}?action=getMessages&login=$login&domain=$domain")
  echo "$response" | jq empty 2>/dev/null
  if [ $? -ne 0 ]; then
    echo "❌ Error: Invalid inbox JSON:"
    echo "$response"
  else
    echo -e "\n=== Inbox ==="
    echo "$response" | jq -r '.[] | "📨 ID: \(.id)\n📛 From: \(.from)\n📌 Subject: \(.subject)\n📅 Date: \(.date)\n---"'
    if [ "$(echo "$response" | jq length)" -eq 0 ]; then
      echo "📭 Inbox is empty."
    fi
  fi
}

# Read a specific message
read_email() {
  read -p "✉️  Enter message ID to read: " msgid
  response=$(curl -s "${BASE_URL}?action=readMessage&login=$login&domain=$domain&id=$msgid")
  echo "$response" | jq empty 2>/dev/null
  if [ $? -ne 0 ]; then
    echo "❌ Error: Invalid message JSON:"
    echo "$response"
  else
    echo "$response" | jq .
  fi
}

# Auto-refresh inbox
auto_refresh_inbox() {
  seen_ids=()
  echo -e "\n🔁 Auto-refreshing inbox every $CHECK_INTERVAL seconds. Press Ctrl+C to stop."

  while true; do
    response=$(curl -s "${BASE_URL}?action=getMessages&login=$login&domain=$domain")
    new_ids=$(echo "$response" | jq -r '.[].id' 2>/dev/null)

    if [ -z "$new_ids" ]; then
      echo "📭 No messages yet. Checking again in $CHECK_INTERVALs..."
    else
      for id in $new_ids; do
        if [[ ! " ${seen_ids[*]} " =~ " $id " ]]; then
          echo -e "\n📬 New message received! ID: $id"
          curl -s "${BASE_URL}?action=readMessage&login=$login&domain=$domain&id=$id" | jq .
          seen_ids+=("$id")
        fi
      done
    fi
    sleep $CHECK_INTERVAL
  done
}

# Menu
main() {
  echo "==============================="
  echo "     TEMPMAIL CLI TOOL"
  echo "==============================="
  generate_email

  while true; do
    echo -e "\nOptions:"
    echo "1. Check Inbox"
    echo "2. Read Message by ID"
    echo "3. Start Auto-Refresh"
    echo "4. Show Email"
    echo "5. Exit"
    read -p "Select: " opt
    case $opt in
      1) get_inbox ;;
      2) read_email ;;
      3) auto_refresh_inbox ;;
      4) echo "📧 $email" ;;
      5) echo "👋 Goodbye!"; break ;;
      *) echo "❗ Invalid option" ;;
    esac
  done
}

main
