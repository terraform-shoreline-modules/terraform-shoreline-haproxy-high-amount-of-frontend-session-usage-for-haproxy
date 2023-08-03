if [ "$(systemctl is-active haproxy.service)" = "active" ]; then

    echo "HAProxy service restarted successfully"

else

    echo "Failed to restart HAProxy service"

fi