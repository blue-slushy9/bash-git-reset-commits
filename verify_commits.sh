# This Bash script will verify that the cloned repos were updated successfully
for item in ./*; do
  if [[ -d "$item" ]]; then
    echo "Searching the commits of $item..."
    cd "$item"
    status=$(git log | grep "ra.cruz971@gmail.com")
    if [ -z "$status" ]; then
      echo "Nothing of note found in the commits of $item. Moving on..."
    else
      echo "Please check the commits of $item." 
    #cd ..
    fi
    cd ..
  fi
done
