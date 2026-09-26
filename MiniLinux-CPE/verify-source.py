#!/usr/bin/env python3
"""Check device isolation after applying the custom firmware patches."""
import re
import subprocess
import sys
from pathlib import Path

source = Path(sys.argv[1]).resolve()


def original(path):
    return subprocess.check_output(
        ['git', 'show', 'HEAD:' + path], cwd=source
    ).decode('utf-8')


def current(path):
    return (source / path).read_text(encoding='utf-8')


def require(condition, message):
    if not condition:
        raise SystemExit(message)


old_dts = 'target/linux/ramips/dts/mt7628an_hilink_hlk-7628n.dts'
require(current(old_dts) == original(old_dts),
        'The upstream HLK-7628N device tree was modified; use a fresh source tree.')
image_path = 'target/linux/ramips/image/mt76x8.mk'
profile = r'^define Device/hilink_hlk-7628n\n.*?^TARGET_DEVICES \+= hilink_hlk-7628n$'
before = re.search(profile, original(image_path), re.M | re.S)
after = re.search(profile, current(image_path), re.M | re.S)
require(before and after and before.group() == after.group(),
        'The upstream HLK-7628N image definition must remain unchanged.')
require('define Device/yang_minilinux-cpe\n' in current(image_path),
        'The standalone MiniLinux-CPE image definition is missing.')
board = current('target/linux/ramips/dts/mt7628an_yang_minilinux-cpe.dts')
require('compatible = "yang,minilinux-cpe", "mediatek,mt7628an-soc";' in board,
        'MiniLinux-CPE must use its own board identifier.')
require('hilink' not in board.lower(), 'MiniLinux-CPE must not inherit another board identifier.')
require('mediatek,ephy-digital-mask = <0x18>;' in board,
        'The SD PORT3/4 digital-mode configuration is missing.')
require('mediatek,cd-poll;' in board,
        'MiniLinux-CPE requires SD polling to bypass unreliable hardware card detection.')
network = current('target/linux/ramips/mt76x8/base-files/etc/board.d/02_network')
require(network.count('yang,minilinux-cpe') == 2,
        'MiniLinux-CPE network and MAC-address defaults are required.')
require('yang,minilinux-cpe)' in current(
    'target/linux/ramips/mt76x8/base-files/etc/board.d/01_leds'),
    'MiniLinux-CPE LED defaults are required.')
print('MiniLinux-CPE device isolation verified; upstream HLK-7628N definitions unchanged.')
