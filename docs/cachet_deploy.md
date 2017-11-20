how to deploy cachet:

(following steps will be bash driven)

1. prereqs (install or verify installed)
php 5.6.4+
apache
postgres for test db, create test user and database
composer

1. clone repo
2. checkout latest tag
3. rename .env.example to .env, replace values for db dialect, name, user, pass
4. generate app key
5. install
6. create new apache VirtualHost
7. how to verify this thing is running correctly? TBD