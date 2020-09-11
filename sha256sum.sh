find . -path ./sitestatic -prune -o -type f \( -name '*.py' -o -name '*.js' -o -name '*.html' \) -print0 | sort -z | xargs -0 sha256sum | sha256sum 2>&1 | tee SHA256SUMS.txt
