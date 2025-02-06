# This Bash script will verify that the cloned repos were updated successfully
# by searching through their commits for a string
for item in ./*; do
  # If the item is a directory
  if [[ -d "$item" ]]; then
    echo "Searching the commits of $item..."
    cd "$item"
    # Capture output of the command inside of () and assign to status
    status=$(git log | grep string)
    # If status is an empty/unset variable, i.e. if the string was not found with grep
    if [ -z "$status" ]; then
      echo "Nothing of note found in the commits of $item. Moving on..."
    # Else if the string was found
    else
      echo "Please check the commits of $item." 
    fi
    cd ..
  fi
done
