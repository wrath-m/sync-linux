#!/bin/bash

if [[ ! -f /root/start.bash ]]; then
    touch /root/start.bash
    echo -e '#!/bin/bash\n' >> /root/start.bash
fi
cat /root/start.source.bash >> /root/start.bash
echo "" >> /root/start.bash