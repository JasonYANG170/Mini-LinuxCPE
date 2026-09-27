#!/usr/bin/env python3
"""Select the Linux SPI Flash ceiling without changing the upstream board."""
import re
import sys
from pathlib import Path

source = Path(sys.argv[1])
variant = sys.argv[2]
rates = {'standard': 10000000, 'spi38m': 38333333,
         'full': 10000000, 'full-spi38m': 38333333}
if variant not in rates:
    raise SystemExit(f'Unknown firmware variant: {variant}')
board = source / 'target/linux/ramips/dts/mt7628an_yang_minilinux-cpe.dts'
text, count = re.subn(r'spi-max-frequency = <\d+>;',
                      f'spi-max-frequency = <{rates[variant]}>;',
                      board.read_text(encoding='utf-8'))
if count != 1:
    raise SystemExit(f'Expected one SPI Flash frequency, found {count}')
board.write_text(text, encoding='utf-8')
print(f'{variant}: Linux SPI Flash maximum {rates[variant]} Hz; Breed unchanged.')
