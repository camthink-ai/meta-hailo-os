# Ship /etc/timezone + /etc/localtime pointing at the factory zone so
# timedatectl set-timezone works out of the box (the image previously had a
# dangling /etc/localtime symlink and no zoneinfo at all in production).
DEFAULT_TIMEZONE = "Asia/Shanghai"
