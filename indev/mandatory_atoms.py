# WARNING: Does not find in-data duplicates of atoms, only in a short range
#          You need to specify the offsets manually in case it is incorrect

def main():
    print("__mp4_moov_atom__")
    file = open("2022-10-04 19-11-45-duplicate-moov.mp4", "rb")
    o = 0xE90F3EBB # just find "moov" alongside "mvhd" in HxD Hex Editor
    n = 1406923 # > moov_size usually found at the end of the video file
    #file = open("2022-10-03 20-12-41.mp4", "rb")
    #o = 0x8CCDBE
    #n = n
    file.seek(0, 2)
    sz = file.tell()
    print(sz / 1024 / 1024 / 1024, "GB")
    file.seek(0)
    short = file.read(n)
    file.seek(o)
    data = file.read(n)
    file.close()

    atoms = \
    [
        "moov", "mvhd", "trak", "tkhd", "mdia", "mdhd", "hdlr", "minf",
        "vmhd", "dinf", "dref", "url", "stbl", "stsd", "avc1", "avcC",
        "stts", "stss", "ctts", "stsc", "stsz", "stco", "mdat"
    ]

    for atom in atoms:
        atom = atom.encode()
        print(str(atom) + ": " +
              str(data.count(atom)) + " | " + 
              str(short.count(atom)))

if __name__ == "__main__":
    main()

""" # Working Video File #
__mp4_moov_atom__
0.00863316934555769 GB
b'moov': 1 | 0
b'mvhd': 1 | 0
b'trak': 2 | 0
b'tkhd': 2 | 0
b'mdia': 2 | 0
b'mdhd': 2 | 0
b'hdlr': 3 | 0
b'minf': 2 | 0
b'vmhd': 1 | 0
b'dinf': 2 | 0
b'dref': 2 | 0
b'url': 2 | 0
b'stbl': 2 | 0
b'stsd': 2 | 0
b'avc1': 1 | 1
b'avcC': 1 | 0
b'stts': 2 | 0
b'stss': 1 | 0
b'ctts': 1 | 0
b'stsc': 2 | 0
b'stsz': 2 | 0
b'stco': 2 | 0
b'mdat': 0 | 1
"""

""" # Corrupt Video File #
__mp4_moov_atom__
3.6428657807409763 GB
b'moov': 1 | 0
b'mvhd': 1 | 0
b'trak': 2 | 0
b'tkhd': 2 | 0
b'mdia': 2 | 0
b'mdhd': 2 | 0
b'hdlr': 3 | 0
b'minf': 2 | 0
b'vmhd': 1 | 0
b'dinf': 2 | 0
b'dref': 2 | 0
b'url': 2 | 0
b'stbl': 2 | 0
b'stsd': 2 | 0
b'avc1': 1 | 1
b'avcC': 1 | 0
b'stts': 2 | 0
b'stss': 1 | 0
b'ctts': 1 | 0
b'stsc': 2 | 0
b'stsz': 2 | 0
b'stco': 2 | 0
b'mdat': 0 | 1
"""

# There are more undetected duplicates within the video data in the corrupt file. It's 3GB.
