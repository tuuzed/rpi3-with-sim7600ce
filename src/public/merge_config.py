#! /usr/bin/python3
import sys


def split_config(config):
    with open(diff_config, mode='r') as f:
        lines = f.readlines()
    d = {}
    for line in lines:
        if not line.startswith('#') and '=' in line:
            op = line.split('=')
            d[op[0]] = op[1]
    return d

def merge_config(diff_config, raw_config, out_config):

    diff = split_config(diff_config)

    raw = split_config(raw_config)

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

    with open(out_config, mode='w') as f:
        f.writelines(lines)

    with open(out_config, mode='r') as f:
       print(f.readlines())

if __name__ == '__main__':
    # diff_config, raw_config, out_config
    merge_config(sys.argv[1], sys.argv[2], sys.argv[3])