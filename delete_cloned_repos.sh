# This Bash script will delete the cloned repos, which I no longer need
for item in ./*; do
  if [[ -d "$item" ]]; then
    rm -rf "$item"
    echo "$item and all its contents have been deleted. Moving on..."
  fi
done
