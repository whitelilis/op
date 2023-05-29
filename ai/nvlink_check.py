import re
import subprocess
import time
import json


def check_one(all):
    if len(all) < 2:
        return
    else:
        last = all[-1]
        first = all[0]
        summary = {}
        ts_diff = last['ts'] - first['ts']

        for k in last.keys():
            summary[k] = (last[k] - first[k]) / ts_diff
        to_write = {'raw': all, 'sum': summary}
        json.dump(to_write, open('/tmp/nv.json', 'w'))
        print(summary)


cmd = 'nvidia-smi nvlink -gt d'.split(' ')
all = []

sleep_sec = 5
times = 20

for f in range(times):
    outl = str(subprocess.check_output(cmd)).split('\\n')
    k1 = ""
    ret = {"ts": time.time()}

    for line in outl:
        line = line.strip()
        parts = re.split('\s+', line)
        if parts[0] == ('GPU'):
            k1 = parts[1]
        if parts[-1] == 'KiB':
            k2 = parts[-3]
            v = int(parts[-2])
            if len(k1) > 1:
                k = k1 + "_" + k2
                if k in ret:
                    ret[k] = ret[k] + v
                else:
                    ret[k] = v

    all.append(ret)
    check_one(all)
    time.sleep(sleep_sec)

check_one(all)
