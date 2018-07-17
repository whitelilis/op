#!/usr/bin/env python
# This file is part of tcollector.
# Copyright (C) 2010  The tcollector Authors.
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or (at your
# option) any later version.  This program is distributed in the hope that it
# will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
# General Public License for more details.  You should have received a copy
# of the GNU Lesser General Public License along with this program.  If not,
# see <http://www.gnu.org/licenses/>.

import sys
import time

try:
    import json
except ImportError:
    json = None

from collectors.lib import utils
from collectors.lib.hadoop_http import HadoopHttp


REPLACEMENTS = {
    "rpcdetailedactivityforport": ["rpc_activity"],
    "rpcactivityforport": ["rpc_activity"]
}


class HadoopResourceManager(HadoopHttp):
    """
    Class that will retrieve metrics from an Apache Hadoop DataNode's jmx page.

    This requires Apache Hadoop 1.0+ or Hadoop 2.0+.
    Anything that has the jmx page will work but the best results will com from Hadoop 2.1.0+
    """

    def __init__(self):
        super(HadoopResourceManager, self).__init__('hadoop', 'resourcemanager', 'mainrm.master.adh', 8088)

    def emit(self):
        current_time = int(time.time())
        metrics = self.poll()
        #with open("/tmp/last_rm", "w") as fd:
        for context, metric_name, value in metrics:
            for k, v in REPLACEMENTS.iteritems():
                if any(c.startswith(k) for c in context):
                    context = v
            if ',' in context[0]:
                c_tmp = context[0] # 'mmm,aa=3,bb=4'
                c_parts = c_tmp.split(',')
                c2 = c_parts[0]
                flags = {}
                for kvp in c_parts:
                    if '=' in kvp:
                        kvp_r = kvp.split('=')
                        flags[kvp_r[0]] = kvp_r[1]
                self.emit_metric([c2], current_time, metric_name, value, flags)
                #fd.write("%s #### %s : %s : %s\n" % (c2, metric_name, value, str(flags)))
            else:
                self.emit_metric(context, current_time, metric_name, value)
                #fd.write("%s --- %s : %s\n" % (len(context), metric_name, value))


def main(args):
    utils.drop_privileges()
    if json is None:
        utils.err("This collector requires the `json' Python module.")
        return 13  # Ask tcollector not to respawn us
    rm_node_service = HadoopResourceManager()
    while True:
        rm_node_service.emit()
        time.sleep(90)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))

