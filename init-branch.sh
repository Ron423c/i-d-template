#!/usr/bin/env bash

set -e

branch="$1"
shift
tmp=$(mktemp -d /tmp/init-branch-"$branch"-XXXXX)
function cleanup() {
    rm -rf "$tmp"
}
trap cleanup ERR EXIT

echo "Initializing $branch branch"
git clone -n . "$tmp"
git -C "$tmp" checkout -q --orphan "$branch"
git -C "$tmp" rm -rfq .

echo Creating circle.yml, .gitignore and initial files
echo 'general:' >"$tmp"/circle.yml
echo '  branches:' >>"$tmp"/circle.yml
echo '    ignore:' >>"$tmp"/circle.yml
echo "      - $branch" >>"$tmp"/circle.yml
echo lib > "$tmp"/.gitignore
echo venv >> "$tmp"/.gitignore
echo .refcache >> "$tmp"/.gitignore
for f in "$@"; do
    touch "$tmp"/"$f"
done

echo Commit and push to origin/"$branch"
commit=(commit)
git config --global --get user.name >/dev/null || commit+=(-c user.name='ID Bot')
git config --global --get user.email >/dev/null || commit+=(-c user.email='idbot@example.com')

git -C "$tmp" add circle.yml .gitignore "$@"
git -C "$tmp" "${commit[@]}" -m "Automatic setup of $branch."
git -C "$tmp" push origin "$branch"
git push --set-upstream origin "$branch"
