REPO_NAME=$(basename $(pwd))
SITE_NAME=$(basename $(ls -d */ | grep -vF "docs/
requirements/"))

echo '-- Creating a new python virtual environment'
mkvirtualenv -q "$REPO_NAME"
workon "$REPO_NAME"

echo '-- Installing pip packages in virtual environment'
pip install -q django
pip install -q south
pip install -q unipath
pip install -q nose
pip install -r requirements/local.txt

echo '-- Making manage.py executable'
chmod +x "$SITE_NAME/manage.py"

echo '-- Saving pip requirements to requirements.txt'
pip freeze >> requirements/local.txt

export INSTRUCTIONS=$(cat <<EOF
-------------------------------------------------------
$SITE_NAME project set up. Now what?
-------------------------------------------------------
- Change DJANGO_SECRET_KEY in ~/.virtualenvs/$SITE_NAME/postactivate (followed by re-activating the virtual environment)
- Run 'workon $SITE_NAME' to activate your new virtual environment (then 'deactivate' to exit).
- Run dev server with grunt serve
- Create new settings classes in ${SITE_NAME}_project/$SITE_NAME/$SITE_NAME/settings that inherit from base.py
- Activate a settings class by altering DJANGO_CONFIGURATION in ~/.virtualenvs/$SITE_NAME/postactivate (followed by re-activating the virtual environment)
- Add configuration settings outside of version control in ~/.virtualenvs/$SITE_NAME/postactivate (followed by re-activating the virtual environment)
EOF
)

echo "-- Saving instructions in README.rst"
echo "$INSTRUCTIONS" >> README.txt

echo '-- Initializing git repo'
echo '*.pyc' >> .gitignore
echo '*~' >> .gitignore
echo '.*swp' >> .gitignore
git init

echo '-- Setting git pre-commit script for pep8 compliance'
cat > pre-commit.sh <<EOF
#!/bin/sh
# To make this script execute before each git commit, run:
# From: https://wiki.wgtn.cat-it.co.nz/wiki/Python
# ln -s pre-commit.sh .git/hooks/pre-commit

# bail if there's no pep8 binary
if ! command -v pep8 > /dev/null 2>&1; then
    echo "Please install the Python PEP-8 code checker: sudo apt-get install pep8"
    exit 1
fi

# bail with success if we're in the middle of merging or rebasing
if [ -d .git/rebase-merge ]; then
    exit 0
fi

# PEP-8 check any files being committed
FILES=`git diff --cached --name-status|grep -oP '^[^D]\s+\K.*?\.py$'`
if [ -n "$FILES" ]; then
    pep8 -r --ignore=E501 $FILES || exit 1
fi
EOF
ln -s pre-commit.sh .git/hooks/pre-commit

echo '-- Making initial git commit'
git add .
git commit -qm 'Initial commit.'

echo '-- Configuring virtualenv postactivate and predactivate scripts'
cat >> ~/.virtualenvs/$REPO_NAME/bin/postactivate <<EOF
export DJANGO_CONFIGURATION='Local'
export SECRET_KEY='CHANGEME!!!'
EOF
cat >> ~/.virtualenvs/$REPO_NAME/bin/predeactivate <<EOF
unset DJANGO_CONFIGURATION
unset SECRET_KEY
EOF

echo '-- Reloading virtual environment'
workon "$REPO_NAME"

echo '-- Syncing database'
"$SITE_NAME/manage.py" syncdb

if [ $? != 0 ]; then
    echo '*** Database could not be synced ***'
    echo "*** You can try to sync the database again with '$SITE_NAME/manage.py syncdb'."
    exit 3
else
    git add .
    git commit -qm 'Synced database for the first time.'
fi

echo "


$INSTRUCTIONS
"
