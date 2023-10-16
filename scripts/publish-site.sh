#! /usr/bin/env bash

repo_slug=${1}
repo_user=${2}
repo_password=${3}

# declare -r this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
# declare -r root_dir=$(cd ${this_dir}/.. && pwd)

# should've been handled by GitHub Action but without this it throws an error
git config --global --add safe.directory '/__w/joshgav.github.io/joshgav.github.io'

repo_url="https://${repo_user}:${repo_password}@github.com/${repo_slug}"
github_publish_branch=${GITHUB_PUBLISH_BRANCH:-publish}

# get latest commit on master branch to compare with current published site
master_commit_hash=$(git log --format='%H' -1)
master_commit_subject=$(git log --format='%s' -1)

echo "INFO: discovered current master commit: ${master_commit_hash}"

git config --global user.name "${repo_user}"
git config --global user.email "${repo_user}@users.noreply.github.com"

echo "INFO: getting currently-deployed site"
git clone ${repo_url} --branch ${github_publish_branch} _site

# compare last published hash to hash from master commit
pushd _site
set +e
git log -1 --oneline | grep -q "${master_commit_hash}"
if [[ $? == 0 ]]; then
    echo "INFO: latest commit already published"
    exit 0
else
    echo "INFO: new commit to publish!"
fi
set -e
popd

echo "INFO: generating fresh version of static site"
export JEKYLL_ENV=production
bundle install
bundle exec jekyll build
if [[ -e "CNAME" ]]; then cp "CNAME" "_site/CNAME"; fi

pushd _site
echo "INFO: pushing fresh version of static site"
git add .
git commit -m "source commit: ${master_commit_hash}" -m "original subject: ${master_commit_subject}"
git push ${repo_url} ${github_publish_branch}
