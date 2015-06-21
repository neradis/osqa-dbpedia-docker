#!/bin/bash
set -e

if [ "$1" = 'django' ]; then
  : ${APP_PORT:=80}  
  : ${APP_DIR:=/osqa}
  : ${DB_INIT_DELAY:=8}

  cd $APP_DIR
  echo 'giving RDBMS time for init'
  sleep "$DB_INIT_DELAY"
  echo 'contuing, assuming RDBMS is ready'
  python manage.py syncdb --all --noinput
  python manage.py migrate forum --fake --noinput
  touch /osqa/log/django.osqa.log
  tail -f /osqa/log/django.osqa.log &
  exec python manage.py runserver "0.0.0.0:$APP_PORT"
elif [ "$1" = 'sshd' ]; then
  exec /usr/sbin/sshd -D
fi

exec "$@"
