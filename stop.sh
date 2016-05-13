ps ux| grep kbPlatform.py | grep -v "grep" | awk '{print $2}' | xargs kill -9
