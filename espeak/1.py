#! /usr/bin/env python
from subprocess import call
call(['espeak -ves "Bienvenido al futuro de la mano de Orange Pi" 2>/dev/null'], shell=True)
