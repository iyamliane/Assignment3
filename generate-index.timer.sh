[Unit]
Description=The generate_index script is ran daily at 5:00AM.

[Timer]
OnCalendar=*-*-* 05:00:00
Unit=generate-index.service
Persistent=true

[Install]
WantedBy=timers.target