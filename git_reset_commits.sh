# Define function that will echo array elements line by line
function echo_array() {
  # ("$@") is used to capture all array elements being passed to function;
  # had previously tried "$1", but that only captures first element 
  local array=("$@")
  for element in "${array[@]}"; do
    echo "$element"
  done
}

# Create empty user_and_repos array
user_and_repos=()

# mapfile is designed specifically for multi-line input, the -t switch tells it 
# to ignore newline characters in the input when adding elements to the array
mapfile -t user_and_repos < <(gh repo list -L 120 | awk '{print $1}')

# TEST
echo "user_and_repos:"
echo_array "${user_and_repos[@]}"
echo

# Slice user_and_repos to exclude the first 6 repos, then assign to variable
new_user_and_repos=("${user_and_repos[@]:6}")

# TEST
echo "new_user_and_repos:"
echo_array "${new_user_and_repos[@]}"
echo

# Define function that splits the full URL to each repo to leave only the repo name
function split_url() {
  # Receive the username/repo-name string
  local user_repo="$1"
  # Set IFS to the delimiter '/'; split user_repo string using read with -a 
  # (array) option, then assign output to split_string with '<<<'
  IFS="/" read -a split_string <<< "$user_repo"
  # split_string[1] is everything after the "/", i.e. the repo-name
  local repo="${split_string[1]}"
  # echo is used in bash instead of return to pass a string back to the caller
  echo "${repo}"
}

# git_operations function to make all required changes to repo, then push
function git_operations() {
  local repo="$1"
  local full_url="$2"
  # We cd into the cloned repo to make the changes
  cd "$repo"
  rm -rf .git
  git init
  git remote add origin "$full_url"
  git add .
  git commit -m "Cleaned up commits."
  git push -fu origin main
  echo "$repo has had its commits cleared and changes pushed to $full_url"
  # We need to cd back into bash-git-reset-commits/ to continue the chain
  cd ..
}

# Define function that will clone the repo, make the changes, and force push
function clone_repo() {
  # Receive the full URL the repo as first argument
  local full_url="$1"
  # Receive username/repo-name string as second argument
  local user_repo="$2"
  git clone "$full_url"
  # Create repo variable, pass output of split_url() function to it
  local repo=$(split_url "$user_repo")
  #cd "$repo"
  # Call git_operations function to make all required changes to repo, then push
  git_operations "$repo" "$full_url"
}

# Define function that will iterate over new_user_and_repos, splice the strings
# to create the full URL, clone the repo, make the changes, commit and push
function join_url_strings() {
  # n will keep track of how many repos get updated, '-i' means integer
  local -i n=0
  # Define base GitHub URL
  local gh_url="https://github.com/"
  # Capture all array elements passed to the function
  local new_user_repos=("$@")
  for user_repo in "${new_user_repos[@]}"; do
  # Added this because I was getting "GitHub.com" as the first repo for some reason  
  if [[ "$url" != "$user_repo" ]]; then
      local full_url="$gh_url$user_repo"
      # Call the clone_repo() function, the other functions are nested in it
      clone_repo "$full_url" "$user_repo"
      n+=1
    fi
  done
  echo "$n repos in total have been updated."
}

# Call join_url_strings function
join_url_strings "${new_user_and_repos[@]}"
