#!/bin/sh

set -e

BASE_URL="http://pulsar-manager:7750/pulsar-manager"
USER="pulsar"
PASS="pulsar123"

echo "Waiting Pulsar Manager..."
until curl -sf $BASE_URL/csrf-token > /dev/null; do
  sleep 2
done

# CSRF TOKEN
echo "Getting CSRF token..."
CSRF_TOKEN=$(curl -s -c cookies.txt $BASE_URL/csrf-token)

# CREATE USER
echo "Creating user..."

USER_RESPONSE=$(curl -s -b cookies.txt -c cookies.txt -w "%{http_code}" -o /tmp/user_resp.json \
  -X PUT $BASE_URL/users/superuser \
  -H "X-XSRF-TOKEN: $CSRF_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"$USER\",\"password\":\"$PASS\",\"description\":\"admin\",\"email\":\"admin@test.com\"}")

echo "Response:"
cat /tmp/user_resp.json
echo ""

if [ "$USER_RESPONSE" = "200" ]; then
  echo "User created"
elif [ "$USER_RESPONSE" = "409" ]; then
  echo "User already exists"
else
  echo "Failed to create user (HTTP $USER_RESPONSE)"
  exit 1
fi

echo "Done!"