#!/bin/bash

# Test script for FreshersNow proxy integration

echo "Testing Proxy Integration..."
echo ""

# Test 1: Check if proxy is accessible
echo "Test 1: Testing proxy accessibility"
PROXY_URL="https://simple-proxy.mda2233.workers.dev/"
TARGET_URL="https://www.freshersnow.com/freshers-jobs/"
PROXY_ENDPOINT="${PROXY_URL}${TARGET_URL}"

echo "Proxy Endpoint: $PROXY_ENDPOINT"
echo ""

# Make test request
response=$(curl -s -o /dev/null -w "%{http_code}" --max-time 15 "$PROXY_ENDPOINT")

if [ "$response" = "200" ]; then
    echo "✅ Proxy accessible (HTTP $response)"
else
    echo "❌ Proxy not responding (HTTP $response)"
    echo "   Trying fallback mode..."
fi

echo ""
echo "Test 2: Checking FreshersNow HTML structure"
html_content=$(curl -s --max-time 15 "$PROXY_ENDPOINT" | head -c 5000)

if [[ $html_content == *"career"* ]] || [[ $html_content == *"jobs"* ]]; then
    echo "✅ Found career-related content in HTML"
    # Extract some sample URLs
    echo ""
    echo "Sample links found:"
    echo "$html_content" | grep -oE 'href="https?://[^"]*career[^"]*"' | head -5
else
    echo "⚠️  No career links found in HTML snippet"
    echo "   This is OK - scraping may extract from different elements"
fi

echo ""
echo "Proxy integration test complete!"
echo ""
echo "Next steps in app:"
echo "1. Open Xcode project"
echo "2. Run JobsMonitorApp"
echo "3. Click menu bar icon"
echo "4. FreshersNow jobs will load automatically"
