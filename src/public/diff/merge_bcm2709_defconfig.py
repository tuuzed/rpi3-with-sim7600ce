#! /usr/bin/python3
import os

def merge_bcm2709_defconfig(kernel_version):
    with open('bcm2709_defconfig.diff') as f:
        lines = f.readlines()
        
    diff = {}
    for line in lines:
        if not line.startswith('#'):
            op = line.split('=')
            diff[op[0]] = op[1]

    raw = {}
    with open(os.path.join('../../' + kernel_version + '/raw','bcm2709_defconfig.raw')) as f:
        lines = f.readlines()
    for line in lines:
        if not line.startswith('#'):
            op = line.split('=')
            raw[op[0]] = op[1]

    ret = {}
    for key in raw:
        value = raw[key]
        if key in diff:
            value = diff[key]
        ret[key]=value

    for key in diff:
        if key not in ret:
            ret[key] = diff[key]

    lines = []
    for key in ret:
        value = ret[key]
        if value.endswith('\n'):
            lines.append(key + '=' + ret[key])
        else:
            lines.append(key + '=' + ret[key] + '\n')

    with open(os.path.join('../../' + kernel_version,'bcm2709_defconfig'), mode='w') as f:
        f.writelines(lines)

if __name__ == "__main__":
    merge_bcm2709_defconfig('rpi-4.9.y')
    merge_bcm2709_defconfig('rpi-4.9.y-stable')
    merge_bcm2709_defconfig('rpi-4.13.y')