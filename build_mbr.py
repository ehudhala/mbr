import os
import sys

from subprocess import call


OUTPUT_FILE_NAME = 'mbr.bin'
SRC_FILE_NAME = 'mbr.asm'

SECTOR_SIZE = 512

# The template is 510 NOPs, and the magic.
MBR_TEMPLATE = '\x90' * (SECTOR_SIZE -2) + '\x55\xAA'


def insert_mbr_code_into_template(mbr_file_name):
    with open(mbr_file_name, 'rb') as mbr_file:
        mbr_code = mbr_file.read()

    mbr_code = mbr_code + MBR_TEMPLATE[len(mbr_code):]
    with open(mbr_file_name, 'wb') as output_file:
        output_file.write(mbr_code)


def build_mbr(src_file_name, output_file_name):
    call('nasm -f bin -o {} {} -Wall'.format(output_file_name, src_file_name))

    if not os.path.isfile(output_file_name):
        raise RuntimeError("Couldn't assemble {}".format(src_file_name))

    insert_mbr_code_into_template(output_file_name)

    print 'Success !'


if __name__ == '__main__':
    src_file_name = sys.argv[1] if len(sys.argv) > 1 else SRC_FILE_NAME
    output_file_name = sys.argv[2] if len(sys.argv) > 2 else OUTPUT_FILE_NAME

    build_mbr(src_file_name, output_file_name)

