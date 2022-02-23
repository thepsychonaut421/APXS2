#!/bin/sh

# APSX2 Setup Script

# Save the current working directory so we can return the user to it
SWD=$PWD

# --------------------- 1. NAVIGATE TO THE PROJECT ROOT ---------------------- #

# Navigate to the script directory
cd $(dirname "$0")

# Navigate up two levels to the project directory
cd ../../

# Set the directory name as the default package name
PKG=${PWD##*/}

# ------------------ 2. LOAD VALUES FROM THE SETUP.CNF FILE ------------------ #

CNF="$PWD/private/etc/setup.cnf"

COMPANY_NAME=$(awk '/^COMPANY_NAME/ {$1=$2=""; print $0}' "$CNF" | awk '{$1=$1};1')
PACKAGE_NAME=$(awk '/^PACKAGE_NAME/ {print $3; exit}' "$CNF")
PACKAGE_DESC=$(awk '/^PACKAGE_DESC/ {$1=$2=""; print $0}' "$CNF" | awk '{$1=$1};1')
SERVER_NAME=$(awk '/^SERVER_NAME/ {print $3; exit}' "$CNF")
SERVER_ADMIN=$(awk '/^SERVER_ADMIN/ {print $3; exit}' "$CNF")

# ---------- 3. ASK FOR USER INPUT IF SETUP.CNF STILL HAS DEFAULTS ----------- #

if [ "$COMPANY_NAME" = "ASPX2" ]; then
  read -p "Org Name (Used for Copyright): " ORG
else
  ORG=$COMPANY_NAME
fi

if [ "$PACKAGE_NAME" = "apxs2-vhost" ]; then
  read -p "Package Name: ($PKG) " EPN

  # If empty, use the default value already in $PKG
  if [ "$EPN" != "" ]; then
    PKG=$EPN
  fi
else
  PKG=$COMPANY_NAME
fi

if [ "$PACKAGE_DESC" = "Apache HTTPD Server VirtualHost Template" ]; then
  read -p "Package Description: " DSC
else
  DSC=$PACKAGE_DESC
fi

if [ "$SERVER_NAME" = "www.example.com" ]; then
  read -p "Server Name (i.e. host.domain.tld): " SRV
else
  SRV=$SERVER_NAME
fi

if [ "$SERVER_ADMIN" = "you@example.com" ]; then
  read -p "Server Admin (i.e. you@domain.tld): " ADM
else
  ADM=$SERVER_ADMIN
fi

YEA=$(date +%Y)

# 4. ---------------- MAKE A COPY OF THE HTTPD CONF TEMPLATE ----------------- #

if [ -f private/etc/httpd.conf ]; then
  echo "httpd.conf file exists -- not overwriting"
else
  echo "httpd.conf does not exist -- copying template"
  cp private/etc/httpd.template.conf private/etc/httpd.conf
  sed -i '' "s+/path/to/project+$PWD+" private/etc/httpd.conf
  sed -i '' "s+www.example.com+$SRV+" private/etc/httpd.conf
  sed -i '' "s/you@example.com/$ADM/" private/etc/httpd.conf
fi

# ------------------------- 5. CREATE THE LOG FILES -------------------------- #

# If necessary create the log directory
if [ -d private/log ]; then
  echo "log directory exists"
else
  echo "log directory does not exist, creating it"
  mkdir -p "$PWD/private/log/"
fi

# 
# Create the access log file
if [ -f "$PWD/private/log/access.log" ]; then
  echo "access log exists, leaving intact"
else
  echo "access log does not exist, creating it"
  touch "$PWD/private/log/access.log"
fi

# Create the error log file
if [ -f "$PWD/private/log/error.log" ]; then
  echo "error log exists, leaving intact"
else
  echo "error log does not exist, creating it"
  touch "$PWD/private/log/error.log"
fi

# ---------------- 6. UPDATE LICENSE, README AND SITE INDEX ------------------ #

sed -i '' "s/apxs2-vhost/$PKG/" README.md

sed -i '' "s/Apache HTTPD Server VirtualHost Template/$DSC/" README.md

sed -i '' "s/APXS2/$ORG/" LICENSE

sed -i '' "s/2020/$YEA/" LICENSE

sed -i '' "s/Example/$PKG/" public/index.php

sed -i '' "s/An example index file/$DSC/" public/index.php

sed -i '' "s/2020/$YEA/" public/index.php

sed -i '' "s/APXS2/$ORG/" public/index.php

# ------ 7. INCLUDE THE NEW HTTPD.CONF FILE IN THE MAIN HTTPD.CONF FILE ------ #

LCF=$(apachectl -t -D DUMP_INCLUDES | grep '*' | cut -d" " -f4)

printf "\nInclude $PWD/private/etc/httpd.conf\n" >> $LCF

# Check the syntax

RES=$(apachectl configtest)

if [ "$RES" = "Syntax OK" ]; then
  echo "Setup Complete"
  open http://$SRV
else
  echo $RES
fi

# Return the user to the starting point
cd $SWD
