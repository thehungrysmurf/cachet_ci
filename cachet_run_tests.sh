#!/bin/bash

mv .env.example .env

echo "Installing PHP dependencies..."
composer install -o > /dev/null 2>&1

if test "$?" -ne 0; then
  echo "Failed to install dependencies: 'composer install -o' failed. Job is stopping"
    exit 1
fi

php artisan key:generate

sed -i 's/DB_DATABASE=cachet/DB_DATABASE=cachet_db/' ".env"
sed -i 's/DB_USERNAME=homestead/DB_USERNAME=cachet_user/' ".env"
sed -i 's/DB_PASSWORD=secret/DB_PASSWORD=password/' ".env"

echo "Refreshing PHP dependencies to reflect current environment..."
composer install -o > /dev/null 2>&1

if test "$?" -ne 0; then
  echo "Failed to refresh dependencies: 'composer install -o' failed. Job is stopping"
    exit 1
fi

echo "Installing the app..."
php artisan app:install > /dev/null 2>&1

if test "$?" -ne 0; then
  echo "Failed to install the app: 'php artisan app:install' failed. Job is stopping"
    exit 1
fi

echo "Adding paratest to prepare for test run..."
composer require brianium/paratest > /dev/null 2>&1

if test "$?" -ne 0; then
  echo "Failed to install paratest: 'composer require brianium/paratest' failed. Job is stopping"
    exit 1
fi

mkdir reports

echo "Running all tests..."
vendor/bin/paratest -p10 tests --log-junit reports/results.xml

echo "Test run complete!"
