#!/bin/bash
set -e

wait_for_dbms_init () {
  : ${DB_INIT_DELAY:=8}
  echo 'giving RDBMS time for init'
  sleep "$DB_INIT_DELAY"
  echo 'contuing, assuming RDBMS is ready'
}

app_setup () {
  : ${APP_DIR:=/osqa}
  cd $APP_DIR
  python manage.py syncdb --all --noinput
  python manage.py migrate forum --fake --noinput
}



if [ "$1" = 'django' ]; then
  wait_for_dbms_init
  app_setup
  : ${APP_PORT:=80}  
  touch /osqa/log/django.osqa.log
  tail -f /osqa/log/django.osqa.log &
  exec python manage.py runserver "0.0.0.0:$APP_PORT"
elif [ "$1" = 'apache' ]; then
  wait_for_dbms_init
  app_setup
  a2enmod wsgi
  a2dissite 000-default
  a2ensite osqa-dbpedia
  chown -R osqa:www-data /var/www/osqa
  chmod -R g+w /var/www/osqa/forum/upfiles
  chmod -R g+w /var/www/osqa/log
  service apache2 start
  exec tail -fn10000 /var/log/apache2/*
elif [ "$1" = 'sshd' ]; then
  mkdir /var/run/sshd
  echo 'root:rubchack' | chpasswd
  sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
  exec /usr/sbin/sshd -D
fi

exec "$@"
