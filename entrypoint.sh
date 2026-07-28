#!/bin/sh
# Alpine ships busybox sh, not bash. The previous #!/bin/bash worked only because
# the old base image happened to include bash.

exec bin/super_perfundo start
