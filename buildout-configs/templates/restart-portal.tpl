### BEGIN INIT INFO
# Provides:          restart-portal
# Required-Start:
# Required-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Plone
# Description:       Start pound, memcache, zeo and 8 zope clients at boot time
### END INIT INFO

. /lib/lsb/init-functions

RETVAL=0
SUCMD='su -s /bin/bash ${parts.configuration['effective-user']} -c'
PREFIX=${parts.buildout.directory}
INSTANCES=("www1" "www2")

PIDFILE_ZEO="$$PREFIX/var/zeoserver.pid"
PIDFILE_POUND="$$PREFIX/parts/poundconfig/var/pound.pid"
PIDFILE_MEMCACHED="$$PREFIX/var/memcached.pid.${parts.configuration['memcache-port']}"

test -f $$PREFIX/bin/zeoserver || exit 5
test -f $$PREFIX/bin/memcached || exit 5
test -f $$PREFIX/bin/poundctl || exit 5
for name in "$${INSTANCES[@]}"; do
    test -f $$PREFIX/bin/$$name || exit 5
done

start_all() {
    if [ -e $$PIDFILE_ZEO ]; then
        log_failure_msg "Zeoserver not started"
    else
        $$SUCMD "$$PREFIX/bin/zeoserver start"
        log_success_msg "Zeosever started"
    fi
    for name in "$${INSTANCES[@]}"; do
        PIDFILE_ZOPE="$$PREFIX/var/$$name.pid"
        if [ -e $$PIDFILE_ZOPE ]; then
            log_failure_msg "Zope $$name not started"
        else
            $$SUCMD "$$PREFIX/bin/$$name start"
            log_success_msg "Zope $$name started"
        fi
    done
    if [ -e $$PIDFILE_POUND ]; then
        log_failure_msg "Pound not started"
    else
        $$SUCMD "$$PREFIX/bin/poundctl start"
        log_success_msg "Pound started"
    fi
    if [ -e $$PIDFILE_MEMCACHED ]; then
        log_failure_msg "Memcached not started"
    else
        $$SUCMD "$$PREFIX/bin/memcached start"
        log_success_msg "Memcached started"
    fi
}

stop_all() {
    if [ -e $$PIDFILE_MEMCACHED ]; then
        $$SUCMD "$$PREFIX/bin/memcached stop"
        log_success_msg "Memcached stopped"
    else
        log_failure_msg "Memcached not stopped"
    fi
    if [ -e $$PIDFILE_POUND ]; then
        $$SUCMD "$$PREFIX/bin/poundctl stop"
        log_success_msg "Pound stopped"
    else
        log_failure_msg "Pound not stopped"
    fi
    for name in "$${INSTANCES[@]}"; do
        PIDFILE_ZOPE="$$PREFIX/var/$$name.pid"
        if [ -e $$PIDFILE_ZOPE ]; then
            $$SUCMD "$$PREFIX/bin/$$name stop"
            log_success_msg "Zope $$name stopped"
        else
            log_failure_msg "Zope $$name not stopped"
        fi
    done
    if [ -e $$PIDFILE_ZEO ]; then
        $$SUCMD "$$PREFIX/bin/zeoserver stop"
        log_success_msg "Zeosever stopped"
    else
        log_failure_msg "Zeoserver not stopped"
    fi
}

status_all() {
    if [ -e $$PIDFILE_ZEO ]; then
        $$PREFIX/bin/zeoserver status
        log_success_msg "Zeosever"
    else
        log_failure_msg "Zeoserver"
    fi
    for name in "$${INSTANCES[@]}"; do
        PIDFILE_ZOPE="$$PREFIX/var/$$name.pid"
        if [ -e $$PIDFILE_ZOPE ]; then
            log_success_msg "Zope $$name"
            $$PREFIX/bin/$$name status
        else
            log_failure_msg "Zope $$name"
        fi
    done
    if [ -e $$PIDFILE_POUND ]; then
        $$SUCMD "$$PREFIX/bin/poundctl status"
        log_success_msg "Pound"
    else
        log_failure_msg "Pound"
    fi
    if [ -e $$PIDFILE_POUND ]; then
        $$SUCMD "$$PREFIX/bin/memcached status"
        log_success_msg "Memcached"
    else
        log_failure_msg "Memcached"
    fi
}

case "$$1" in
  start)
        start_all
        ;;
  stop)
        stop_all
        ;;
  status)
        status_all
        ;;
  restart)
        stop_all
        start_all
        ;;
  *)
        echo "Usage: $$0 {start|stop|status|restart}"
        RETVAL=1
esac
exit $$RETVAL
